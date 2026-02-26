import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/chat/video_chat/demo/call_screen.dart';
import 'package:manager/features/tickets/tickets_list/tickets_list.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../core/locator.dart';
import '../../core/models/hive/user/user.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../services/api.service.dart';
import '../../services/chat.service.dart';
import '../../services/dialogs.service.dart';
import '../../services/language.service.dart';
import '../../services/socket_service.dart';
import '../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../resources/enums/chat_enum.dart';
import 'model/chat_message_model.dart';

enum ChatRoomScreenType { mainChat, contactChat }

enum MessageType {
  text,
  image,
  audio,
  video,
  document,
  location,
  link;

  @override
  String toString() {
    return name;
  }
}

class ChatViewModel extends ReactiveViewModel {
  final _chatService = locator<ChatService>();
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final SocketService _socketService = SocketService();
  final ImagePicker _imagePicker = ImagePicker();
  ChatMessageModel? replyMessage;
  ChatMessageModel? replyTo;
  String? editingMessageId;
  // State variables
  bool _isSendingMessage = false;
  bool _isUploadingImage = false;
  bool _isSearchMode = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentSearchIndex = -1;

  // Media preview variables (images and videos)
  List<String> _selectedMediaPaths = [];
  List<String> _selectedMediaNames = [];
  List<String> _selectedMediaTypes = []; // 'image' or 'video'

  // Pagination variables
  bool _isLoading = false;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  int _totalMessages = 0;
  int _limit = 20;
  bool _hasMoreMessages = true;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasMoreMessages => _hasMoreMessages;

  int get totalMessages => _totalMessages;
  ChatRoomScreenType _chatRoomScreenType = ChatRoomScreenType.mainChat;
  ChatRoomScreenType get chatRoomScreenType => _chatRoomScreenType;
  final TicketsListViewModel ticketDetailsViewModel = locator<TicketsListViewModel>();
  // Messages list
  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => _messages.toList();

  // Getters
  bool get isSendingMessage => _isSendingMessage;

  bool get isUploadingImage => _isUploadingImage;

  bool _isReplyMode = false;
  bool get isReplyMode => _isReplyMode;

  bool _isTicketDetailsExpanded = false;
  bool get isTicketDetailsExpanded => _isTicketDetailsExpanded;

  set isTicketDetailsExpanded(bool value) {
    _isTicketDetailsExpanded = value;
    notifyListeners();
  }

  bool get isSearchMode => _isSearchMode;

  String get searchQuery => _searchQuery;

  TextEditingController get searchController => _searchController;

  int get currentSearchIndex => _currentSearchIndex;

  List<String> get selectedMediaPaths => _selectedMediaPaths;

  List<String> get selectedMediaNames => _selectedMediaNames;

  List<String> get selectedMediaTypes => _selectedMediaTypes;

  bool get hasImagePreview => _selectedMediaPaths.isNotEmpty;

  bool get isEditMode => editingMessageId != null;

  User userData = getUser();
  String roomId = "default_room";

  Map<String, dynamic> chatEvents = {
    "contactChat": {
      'register': "ContactRegisterUser",
      'join': "joinContactRoom",
      'send': "ContactSendMessage",
      'newMessage': "ContactNewMessage",
    },
    "mainChat": {
      'register': "registerUser",
      'join': "joinRoom",
      'send': "sendMessage",
      "newMessage": "newMessage",
    },
  };

  /// Handle new incoming messages
  void _handleNewMessage(dynamic data) {
    print("🎯 _handleNewMessage called with: $data");
    if (data is Map<String, dynamic>) {
      try {
        final message = ChatMessageModel.fromJson(data);
        print("✅ Message parsed successfully: ${message.content}");

        if (message.sender.id == userData.id) {
          // This is our own message echoed back by server.
          // Remove the optimistic local copy (matched by content) and replace with server version.
          message.isSentByMe = true;
          final localIdx = _messages.indexWhere(
                (m) =>
            m.isSentByMe &&
                m.content == message.content &&
                m.id != message.id,
          );
          if (localIdx != -1) {
            _messages[localIdx] = message;
          } else {
            _messages.insert(0, message);
          }
        } else {
          message.isSentByMe = false;
          _messages.insert(0, message);
        }

        notifyListeners();
        print("📝 Message added to list. Total messages: ${_messages.length}");
      } catch (e) {
        print("❌ Error parsing message: $e");
      }
    } else {
      print("⚠️ Received data is not a Map: ${data.runtimeType}");
    }
  }

  void _handleReaction(dynamic data) {
    final messageId = data['messageId'];
    final emoji = data['emoji'];
    final userId = data['user'] ?? userData.id ?? '';

    final index = _messages.indexWhere((m) => m.id == messageId);

    if (index != -1) {
      // Remove existing reaction from same user, then add new one
      _messages[index].reactions.removeWhere((r) => r.user == userId);
      if (emoji != null && emoji.toString().isNotEmpty) {
        _messages[index].reactions.add(Reaction(user: userId, emoji: emoji));
      }
      notifyListeners();
    }
  }

  Future<void> fetchInitialData({
    required String? roomId1,
    ChatRoomScreenType? screen,
  }) async {
    _isLoading = true;
    _currentPage = 1;
    _hasMoreMessages = true;
    _messages.clear();
    notifyListeners();

    _chatRoomScreenType = screen ?? ChatRoomScreenType.mainChat;
    roomId = roomId1 ?? roomId;
    await Future.wait([initializeSocket(), loadMessages()]);

    _isLoading = false;
    notifyListeners();
  }

  /// Socket implementation
  Future<void> initializeSocket() async {
    print("🚀 Initializing socket connection...");

    // Initialize socket connection
    _socketService.initializeSocket(
      serverUrl: '${Configurations().url}/',
      queryParams: {'userId': userData.id ?? 'default_user', 'roomId': roomId},
      extraHeaders: {'Authorization': "${userData.token}"},
      onDisconnected: () {
        _socketService.off(chatEvents[chatRoomScreenType.name]['newMessage']);
        _socketService.off(chatEvents[chatRoomScreenType.name]['join']);
      },
      onConnected: () {
        // Register user
        print("👤 Registering user: ${userData.id ?? 'default_user'}");
        _socketService.registerUser(
          userData.id ?? 'default_user',
          chatEvents[chatRoomScreenType.name]['register'],
        );

        _socketService.joinRoom(
          roomId,
          chatEvents[chatRoomScreenType.name]['join'],
        );

        // Listen for incoming messages
        print("👂 Setting up message listener...");
        _socketService.onNewMessage(
          _handleNewMessage,
          chatEvents[chatRoomScreenType.name]['newMessage'],
        );

        _socketService.on("messageReacted", _handleReaction);
      },
    );
  }

  void reactToMessage(String messageId, String emoji) {
    // Emit to server
    _socketService.reactToMessage(messageId: messageId, emoji: emoji);

    // Optimistically update local reactions list so UI updates instantly
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final userId = userData.id ?? '';
      _messages[index].reactions.removeWhere((r) => r.user == userId);
      _messages[index].reactions.add(Reaction(user: userId, emoji: emoji));
      notifyListeners();
    }
  }

  /// Fetch all messages
  Future<void> loadMessages() async {
    try {
      final result = await _chatService.getPaginatedChatMessages(
        roomId: roomId,
        page: _currentPage,
        limit: _limit,
        screen: chatRoomScreenType.name,
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to fetch messages: ${failure.message}');
          Fluttertoast.showToast(
            msg:
            "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (response) {
          final List<dynamic> messagesData = response['messages'] ?? [];
          final List<ChatMessageModel> newMessages =
          messagesData.map((e) => ChatMessageModel.fromJson(e)).toList();

          // Set isSentByMe for each message
          for (var message in newMessages) {
            message.isSentByMe = message.sender.id == userData.id;
          }

          if (_currentPage == 1) {
            _messages.clear();
            _messages.addAll(newMessages);
          } else {
            // For pagination, add older messages to the end of the list
            _messages.addAll(newMessages);
          }

          // Resolve reply references (replyToId -> replyTo object)
          _resolveReplyReferences();

          // Update pagination state
          _totalMessages = response['total'] ?? 0;
          _hasMoreMessages = _messages.length < _totalMessages;

          AppLogger.info(
            'Loaded ${newMessages.length} messages (Page $_currentPage)',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error loading messages: $e');
    }
  }

  /// Resolve replyToId string references to actual ChatMessageModel objects
  void _resolveReplyReferences() {
    for (var message in _messages) {
      if (message.replyTo == null && message.replyToId != null) {
        final replyMsg =
            _messages.where((m) => m.id == message.replyToId).firstOrNull;
        if (replyMsg != null) {
          message.replyTo = replyMsg;
        }
      }
    }
  }

  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    await loadMessages();

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> getAllChatMessages() async {
    try {
      final result = await _chatService.getAllChatMessages(roomId: roomId);

      result.fold(
            (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _messages.clear();

          Fluttertoast.showToast(
            msg:
            "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (response) {
          final result =
          response.map((element) {
            element.isSentByMe = element.sender.id == userData.id;
            return element;
          }).toList();

          _messages.clear();
          _messages.addAll(result);
          AppLogger.info('Chat Messages loaded ${response.length} messages');
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching chat rooms: $e');
    }
  }

  /// Locally add a sent message for optimistic UI update
  void _addLocalMessage(
      String content, {
        List<Attachment> attachments = const [],
        ChatMessageModel? replyTo,
      }) {
    final localMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      sender: Sender(
        id: userData.id ?? '',
        fullName: userData.name ?? '',
        email: userData.email ?? '',
      ),
      senderType: '',
      content: content,
      translatedContent: content,
      attachments: attachments,
      readBy: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 0,
      isSentByMe: true,
      replyTo: replyTo,
      status: MessageStatus.sent,
      isDeleted: false,
    );
    _messages.insert(0, localMessage);
    notifyListeners();
  }

  /// Send a text message
  Future<void> sendMessage() async {
    // final messageText = messageController.text.trim();
    if (messageController.text.trim().isEmpty && !hasImagePreview) {
      AppLogger.warning('Cannot send empty message');
      return;
    }

    try {
      _isSendingMessage = true;
      notifyListeners();

      /// 🔥 EDIT MODE CHECK
      if (editingMessageId != null) {
        final messageText = messageController.text.trim();
        if (messageText.isEmpty) return;

        final response = await _chatService.editChat(
          content: messageText,
          messageId: editingMessageId!,
        );

        // ✅ API success hone ke baad local list update karo
        final index = _messages.indexWhere((m) => m.id == editingMessageId);

        if (index != -1) {
          _messages[index].content = messageText;
        }

        editingMessageId = null;
        messageController.clear();
        notifyListeners();
        return;
      }
      final messageText = messageController.text.trim();
      messageController.clear();

      // If there are media files, send them with text
      if (hasImagePreview && _selectedMediaPaths.isNotEmpty) {
        List<String> selectedMediaPaths = List.from(_selectedMediaPaths);
        List<String> selectedMediaTypes = List.from(_selectedMediaTypes);

        _selectedMediaPaths.clear();
        _selectedMediaNames.clear();
        _selectedMediaTypes.clear();

        await _sendMediaWithText(
          selectedMediaPaths,
          selectedMediaTypes,
          messageText,
        );
      } else {
        // Send text-only message via socket
        _socketService.sendMessage(
          roomId: roomId,
          content: messageText,
          replyTo: replyMessage?.id,
          event: chatEvents[chatRoomScreenType.name]['send'],
        );
        // Optimistically add the message to local list so it shows instantly
        _addLocalMessage(messageText, replyTo: replyMessage);
        // Clear reply after sending
        replyMessage = null;
        AppLogger.info('Text message sent');
      }
    } catch (e) {
      AppLogger.error('Error sending message: $e');
      // Optionally, update the temporary message to show a 'failed' state.
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// Pick multiple media (images and videos) from album
  Future<void> pickMultipleMediaFromAlbum() async {
    try {
      final List<XFile> media = await _imagePicker.pickMultipleMedia(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (media.isNotEmpty) {
        _selectedMediaPaths = media.map((file) => file.path).toList();
        _selectedMediaNames = media.map((file) => file.name).toList();
        _selectedMediaTypes =
            media.map((file) {
              // Determine if it's a video or image based on file extension
              final extension = file.name.toLowerCase().split('.').last;
              return [
                'mp4',
                'mov',
                'avi',
                'mkv',
                'webm',
                '3gp',
              ].contains(extension)
                  ? 'video'
                  : 'image';
            }).toList();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error picking multiple media: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pick media',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  /// Pick image from camera and add to multiple selection
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        _selectedMediaPaths.add(image.path);
        _selectedMediaNames.add(image.name);
        _selectedMediaTypes.add('image');
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error taking photo: $e');
      Fluttertoast.showToast(
        msg: 'Failed to take photo',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  Future<void> openVideoChat() async {
    final tokenResponse = await _chatService.sendVChatStatus(
      roomName: roomId,
      status: 'call-request',
      callType: 'video',
      name: userData.name ?? 'User',
      users: userData.id ?? '',
    );

    if (tokenResponse['success'] && tokenResponse['token'] != null) {
      Get.to(
            () => VideoCallScreen(roomName: roomId, token: tokenResponse['token']),
      );
    }
  }

  Future<void> openAudioChat() async {
    final tokenResponse = await _chatService.sendVChatStatus(
      roomName: roomId,
      status: 'call-request',
      callType: 'audio',
      name: userData.name ?? 'User',
      users: userData.id ?? '',
    );

    if (tokenResponse['success'] && tokenResponse['token'] != null) {
      Get.to(
            () => VideoCallScreen(
          roomName: roomId,
          token: tokenResponse['token'],
          isVoice: true,
        ),
      );
    }
  }

  /// Remove multiple media previews
  void removeMultipleImagePreviews() {
    _selectedMediaPaths.clear();
    _selectedMediaNames.clear();
    _selectedMediaTypes.clear();
    notifyListeners();
  }

  /// Remove specific media from multiple selection
  void removeImageFromMultiple(int index) {
    if (index >= 0 && index < _selectedMediaPaths.length) {
      _selectedMediaPaths.removeAt(index);
      _selectedMediaNames.removeAt(index);
      _selectedMediaTypes.removeAt(index);
      notifyListeners();
    }
  }

  /// Send media (images and videos) with optional text
  Future<void> _sendMediaWithText(
      List<String> mediaPaths,
      List<String> mediaTypes,
      String text,
      ) async {
    try {
      _isUploadingImage = true;
      notifyListeners();

      // Upload media files to server
      final result = await _chatService.uploadChatFiles(
        mediaPaths,
        chatRoomScreenType.name,
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to upload media: ${failure.message}');
          Fluttertoast.showToast(
            msg: 'Failed to upload media: ${failure.message}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (response) {
          // Extract files info from response
          final List<dynamic> files = response['files'] ?? [];

          if (files.isNotEmpty) {
            // Convert to attachment format with proper types
            final List<Map<String, dynamic>> attachments = [];
            for (int i = 0; i < files.length; i++) {
              final file = files[i];
              final mediaType = i < mediaTypes.length ? mediaTypes[i] : 'image';
              attachments.add({
                'url': file['url'] ?? '',
                'name':
                file['name'] ??
                    (mediaType == 'video' ? 'video.mp4' : 'image.jpg'),
                'type': mediaType,
              });
            }

            // Send message with media attachments and text via socket
            _socketService.sendMessage(
              roomId: roomId,
              content: text, // Include text content
              attachments: attachments,
              event: chatEvents[chatRoomScreenType.name]['send'],
            );

            // Optimistically add media message locally
            final localAttachments =
            attachments
                .map(
                  (a) => Attachment(
                type: a['type'] ?? 'image',
                url: a['url'] ?? '',
              ),
            )
                .toList();
            _addLocalMessage(text, attachments: localAttachments);

            AppLogger.info('Media with text message sent successfully');
          } else {
            throw Exception('Invalid response from server');
          }
        },
      );
    } catch (e) {
      AppLogger.error('Error sending media with text: $e');
      Fluttertoast.showToast(
        msg: 'Failed to send media',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Toggle search mode
  void toggleSearchMode() {
    _isSearchMode = !_isSearchMode;
    if (!_isSearchMode) {
      _searchQuery = '';
      _searchController.clear();
      _currentSearchIndex = -1;
    }
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _currentSearchIndex = -1; // Reset search index when query changes
    notifyListeners();
  }

  /// Get filtered messages based on search query
  List<ChatMessageModel> get filteredMessages {
    if (_searchQuery.isEmpty) {
      return _messages;
    }

    return _messages.where((message) {
      // Search in message content
      final contentMatch = message.content.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // Search in attachment names (if any)
      final attachmentMatch = message.attachments.any(
            (attachment) =>
        attachment.url.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (attachment.url
                .split('/')
                .last
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())),
      );

      return contentMatch || attachmentMatch;
    }).toList();
  }

  /// Get search results with indices
  List<Map<String, dynamic>> get searchResults {
    if (_searchQuery.isEmpty) return [];

    List<Map<String, dynamic>> results = [];
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      final contentMatch = message.content.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      if (contentMatch) {
        results.add({'message': message, 'index': i, 'type': 'content'});
      }

      // Check attachments
      for (int j = 0; j < message.attachments.length; j++) {
        final attachment = message.attachments[j];
        final attachmentMatch =
            attachment.url.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (attachment.url
                    .split('/')
                    .last
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));

        if (attachmentMatch) {
          results.add({
            'message': message,
            'index': i,
            'type': 'attachment',
            'attachmentIndex': j,
          });
        }
      }
    }

    return results;
  }

  /// Navigate to next search result
  void nextSearchResult() {
    final results = searchResults;
    if (results.isNotEmpty) {
      _currentSearchIndex = (_currentSearchIndex + 1) % results.length;
      _scrollToSearchResult(results[_currentSearchIndex]['index']);
      notifyListeners();
    }
  }

  /// Navigate to previous search result
  void previousSearchResult() {
    final results = searchResults;
    if (results.isNotEmpty) {
      _currentSearchIndex =
      _currentSearchIndex <= 0
          ? results.length - 1
          : _currentSearchIndex - 1;
      _scrollToSearchResult(results[_currentSearchIndex]['index']);
      notifyListeners();
    }
  }

  /// Scroll to specific search result
  void _scrollToSearchResult(int messageIndex) {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          final double targetPosition = (messageIndex + 1) * 100.0;
          final double maxScroll = scrollController.position.maxScrollExtent;
          final double scrollPosition =
          targetPosition > maxScroll ? maxScroll : targetPosition;
          scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchController.clear();
    _currentSearchIndex = -1;
    notifyListeners();
  }

  Future<void> sendAttachment({
    required String fileUrl,
    required MessageType messageType,
    required String fileName,
  }) async {
    // This method is broken and needs to be updated for ChatMessageModel
  }

  /// Resolve chat by updating ticket status
  Future<bool> resolveChat(String ticketId, String engineerRemark) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        message: 'Resolving chat...',
        task: () async {
          try {
            final response = await _apiService.put(
              url: 'ticket/update/$ticketId',
              data: {'status': 'Resolved', 'engineerRemark': engineerRemark},
            );

            if (response.statusCode == 200) {
              AppLogger.info('Ticket resolved successfully');
              return 'success';
            } else {
              throw Exception(
                'Failed to resolve ticket: ${response.statusCode}',
              );
            }
          } catch (e) {
            AppLogger.error('Error resolving chat: $e');
            throw e;
          }
        },
      ),
    );
    if (response?.confirmed == true) {
      Fluttertoast.showToast(
        msg: 'Chat resolved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to resolve chat: ${response?.data ?? 'Unknown error'}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
      return false;
    }
  }

  /// Resolve chat by updating ticket status
  // Future<bool> engineerRemark(String ticketId, String engineerRemark) async {
  //   final response = await _dialogService.showCustomDialog(
  //     variant: DialogType.loader,
  //     data: LoaderDialogAttributes(
  //       message: 'Resolving chat...',
  //       task: () async {
  //         try {
  //           final response = await _apiService.put(url: 'ticket/update/$ticketId', data: {'engineerRemark': engineerRemark});
  //
  //           if (response.statusCode == 200) {
  //             AppLogger.info('Engineer remarked successfully');
  //             return 'success';
  //           } else {
  //             throw Exception('Failed to Engineer Remark: ${response.statusCode}');
  //           }
  //         } catch (e) {
  //           AppLogger.error('Error Engineer Remark: $e');
  //           throw e;
  //         }
  //       },
  //     ),
  //   );
  //   if (response?.confirmed == true) {
  //     Fluttertoast.showToast(
  //       msg: 'Engineer remark successfully',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: AppColors.success,
  //       textColor: AppColors.white,
  //     );
  //     return true;
  //   } else {
  //     Fluttertoast.showToast(
  //       msg: 'Failed to Engineer Remark: ${response?.data ?? 'Unknown error'}',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: AppColors.error,
  //       textColor: AppColors.white,
  //     );
  //     return false;
  //   }
  // }

  @override
  void dispose() {
    // Clean up socket listeners
    _socketService.off(chatEvents[chatRoomScreenType.name]['newMessage']);
    _socketService.dispose();

    // Dispose controllers
    messageController.dispose();
    scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  /// Update ticket status to "On Hold"
  Future<bool> updateTicketStatusToActive(String ticketId) async {
    try {
      AppLogger.info('Updating ticket status to On Hold for ticket: $ticketId');

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.put(
                url: '${ApiEndpoints.updateTicket}/$ticketId',
                data: {'status': 'Active'},
              );

              AppLogger.info("Update ticket API Response: ${apiResponse.data}");

              if (apiResponse.statusCode == 200) {
                AppLogger.info('Successfully updated ticket status to On Hold');
                return true;
              } else {
                AppLogger.error(
                  'Failed to update ticket status: ${apiResponse.statusCode}',
                );
                throw Exception(
                  apiResponse.data?['message'] ??
                      'Failed to update ticket status',
                );
              }
            } catch (e) {
              AppLogger.error("Error updating ticket status: $e");
              rethrow;
            }
          },
          message: 'Updating ticket status...',
        ),
      );

      if (response?.confirmed == true && response?.data == true) {
        return true;
      } else {
        throw Exception(
          response?.data?.toString() ?? 'Failed to update ticket status',
        );
      }
    } catch (e) {
      AppLogger.error("Error in updateTicketStatusToOnHold: $e");
      rethrow;
    }
  }

  void setReplyMessage(ChatMessageModel message) {
    replyMessage = message;
    notifyListeners();
  }

  void cancelReply() {
    replyMessage = null;
    notifyListeners();
  }

  Future<void> editMessage(ChatMessageModel message) async {
    messageController.text = message.content;
    editingMessageId = message.id;
    notifyListeners();
  }

  void cancelEdit() {
    editingMessageId = null;
    messageController.clear();
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      // 1️⃣ Optimistically mark as deleted locally (WhatsApp style)
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index].isDeleted = true;
        _messages[index].content = 'This message was deleted';
        notifyListeners();
      }

      // 2️⃣ Call API
      await _chatService.deleteChat(messageId: messageId);
    } catch (e) {
      AppLogger.error('Error deleting message: $e');
      // Revert on failure
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index].isDeleted = false;
        notifyListeners();
      }
    }
  }
}
