import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/models/viewers_model.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/chat/video_chat/demo/call_screen.dart';
import 'package:manager/features/tickets/tickets_list/tickets_list.vm.dart';
import 'package:manager/routes/routes.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../core/locator.dart';
import '../../core/models/hive/user/user.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../services/api.service.dart';
import '../../services/chat.service.dart';
import '../../services/dialogs.service.dart';
import '../../services/file_picker.service.dart';
import '../../services/language.service.dart';
import '../../services/socket_service.dart';
import '../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../resources/enums/chat_enum.dart';
import 'model/chat_message_model.dart';
import 'video_chat/demo/location_service.dart';

enum ChatRoomScreenType { mainChat, contactChat,   groupChat, }

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
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();
  final _filePickerService = locator<FilePickerService>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final SocketService _socketService = SocketService();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  String? _activeRecordingPath;
  ChatMessageModel? replyMessage;
  ChatMessageModel? replyTo;
  String? editingMessageId;
  // State variables
  String? _remoteTypingUserId;
  bool _isSendingMessage = false;
  bool _isUploadingImage = false;
  bool _isRecordingAudio = false;
  Duration _recordingDuration = Duration.zero;
  double _recordingSlideOffset = 0;
  bool _isSearchMode = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentSearchIndex = -1;
  bool get isRemoteUserTyping => _remoteTypingUserId != null;
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  // Media preview variables (images and videos)
  List<String> _selectedMediaPaths = [];
  List<String> _selectedMediaNames = [];
  List<String> _selectedMediaTypes = []; // 'image' or 'video'
  String get _viewerTypeForSelectedTab => _selectedTab == 0 ? 'unseen' : 'seen';
  // Pagination variables
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Timer? _typingDebounceTimer;
  Timer? _remoteTypingResetTimer;
  Timer? _seenRefreshDebounceTimer;
  int _currentPage = 1;
  int _totalMessages = 0;
  final int _limit = 20;
  bool _hasMoreMessages = true;
  bool _showAttachment = false;

  static const double recordingCancelThreshold = 120;
  List<ViewUser> _allViewers = [];

  List<ViewUser> get allViewers => _allViewers;
  String _viewerId = '';
  String get viewerId => _viewerId;
  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasMoreMessages => _hasMoreMessages;

  int get totalMessages => _totalMessages;
  ChatRoomScreenType _chatRoomScreenType = ChatRoomScreenType.mainChat;
  ChatRoomScreenType get chatRoomScreenType => _chatRoomScreenType;
  final TicketsListViewModel ticketDetailsViewModel = locator<TicketsListViewModel>();
  Future<void> selectTabs(index) async {
    if (_selectedTab == index) return;
    _selectedTab = index;
    // notifyListeners();
    if (_viewerId.trim().isNotEmpty) {
      await getViewers();
    }
  }
  void selectId(id){
    _viewerId = id?.toString() ?? '';
  }
  // Messages list
  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => _messages.toList();

  String senderDisplayName(ChatMessageModel message) {
    final directName = message.sender.fullName.trim();
    if (directName.isNotEmpty) {
      return directName;
    }

    for (final existingMessage in _messages.reversed) {
      if (existingMessage.sender.id != message.sender.id) {
        continue;
      }

      final cachedName = existingMessage.sender.fullName.trim();
      if (cachedName.isNotEmpty) {
        return cachedName;
      }
    }

    if (message.sender.id == (userData.id ?? '')) {
      final myName = (userData.name ?? userData.fullName ?? '').trim();
      if (myName.isNotEmpty) {
        return myName;
      }
      return 'You';
    }

    return 'Unknown User';
  }

  // Getters
  bool get isSendingMessage => _isSendingMessage;
  bool get showAttachment => _showAttachment;

  bool get isUploadingImage => _isUploadingImage;
  bool get isRecordingAudio => _isRecordingAudio;
  Duration get recordingDuration => _recordingDuration;
  double get recordingSlideOffset => _recordingSlideOffset;
  double get recordingCancelProgress {
    if (_recordingSlideOffset >= 0) {
      return 0;
    }
    final progress = (-_recordingSlideOffset) / recordingCancelThreshold;
    return progress.clamp(0.0, 1.0).toDouble();
  }

  bool get shouldCancelRecording =>
      _recordingSlideOffset <= -recordingCancelThreshold;

  final bool _isReplyMode = false;
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
    "groupChat": { // ✅ new add
      'register': "registerUser",
      'join': "joinRoom",
      'send': "sendMessage",
      "newMessage": "newMessage",
    },
  };
  void navigateToGroupInfoChats() {
    _navigationService.navigateTo(Routes.groupInfoScreen);
  }
  void toggleAttachment() {
    if (_isRecordingAudio) return;
    _showAttachment = !_showAttachment;
    notifyListeners();
  }

  void toggleAttachmentSelect(bool select) {
    _showAttachment = select;
    notifyListeners();
  }

  Future<void> getViewers({String? type}) async {
    _isLoading = true;
    _allViewers = [];
    notifyListeners();

    try {
      final viewerType =
      (type?.trim().isNotEmpty ?? false) ? type!.trim() : _viewerTypeForSelectedTab;

      final result = await _chatService.getViewers(type: viewerType, msgId: _viewerId);
      result.fold(
            (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _allViewers = [];

          Fluttertoast.showToast(
            msg: "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
          );
        },
            (response) {
          final rawUsers = _extractViewersListFromResponse(response);
          _allViewers = _mapViewers(rawUsers);

          AppLogger.info(
            'Successfully loaded ${_allViewers.length} viewers for type $viewerType (Message: $_viewerId)',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching all chats: $e');
      _allViewers = [];
      Fluttertoast.showToast(
        msg: LanguageService.get("error_loading_chats"),
        // ... (baki toast properties)
      );
    } finally {
      if (_chatService.isRefreshing) {
        _chatService.resetRefreshFlag();
      }
      // + Loading state false karein
      _isLoading = false;
    }

    notifyListeners();
  }
  List<ViewUser> _mapViewers(List<dynamic> rawUsers) {
    return rawUsers
        .whereType<Map>()
        .map((user) => ViewUser.fromJson(Map<String, dynamic>.from(user)))
        .toList();
  }
  Future<List<ViewUser>> fetchViewersData({
    required String type,
    String? messageId,
  })
  async {
    final targetMessageId = (messageId ?? _viewerId).trim();
    if (targetMessageId.isEmpty) return const [];

    final result = await _chatService.getViewers(
      type: type.trim(),
      msgId: targetMessageId,
    );

    return result.fold(
          (failure) {
        AppLogger.error('Failed to get viewers: ${failure.message}');
        Fluttertoast.showToast(
          msg: "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
        );
        return <ViewUser>[];
      },
          (response) {
        final rawUsers = _extractViewersListFromResponse(response);
        return _mapViewers(rawUsers);
      },
    );
  }
  List<dynamic> _extractViewersListFromResponse(Map<String, dynamic> response) {
    if (response['users'] is List) return response['users'] as List<dynamic>;
    if (response['viewers'] is List) return response['viewers'] as List<dynamic>;

    final rootData = response['data'];
    if (rootData is List) return rootData;

    if (rootData is Map) {
      final dataMap = Map<String, dynamic>.from(rootData);
      if (dataMap['users'] is List) return dataMap['users'] as List<dynamic>;
      if (dataMap['viewers'] is List) return dataMap['viewers'] as List<dynamic>;
      if (dataMap['data'] is List) return dataMap['data'] as List<dynamic>;
    }

    return const [];
  }
  Future<void> sendLocationMessage({
    Position? position,
    double? latitude,
    double? longitude,
    bool isLiveLocation = false,
  }) async {
    try {
      final selectedPosition =
          position ?? await LocationService.getCurrentLocation();

      final lat = latitude ?? selectedPosition?.latitude;
      final lng = longitude ?? selectedPosition?.longitude;

      if (lat == null || lng == null) {
        Fluttertoast.showToast(
          msg: 'Location available nahi hai. Permission/GPS check karein.',
        );
        return;
      }

      final locationUrl = 'https://maps.google.com/?q=$lat,$lng';
      final content =
      isLiveLocation ? 'Live location: $locationUrl' : locationUrl;
      final clientMessageId = _createClientMessageId();

      _socketService.sendMessage(
        roomId: roomId,
        content: content,
        event: chatEvents[chatRoomScreenType.name]['send'],
        messageType: MessageType.location.name,
        clientMessageId: clientMessageId,
      );

      _addLocalMessage(
        content,
        messageType: MessageType.location.name,
        clientMessageId: clientMessageId,
      );
    } catch (e) {
      AppLogger.error('Failed to send location message: $e');
      Fluttertoast.showToast(msg: 'Location send nahi ho paya.');
    }
  }



  void onComposerTextChanged(String value) {
    if (value.trim().isEmpty) return;

    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(milliseconds: 450), () {
      _socketService.typing(roomId);
    });
  }
  /// Handle new incoming messages
  void _handleNewMessage(dynamic data) {

    print("SOCKET MESSAGE RECEIVED: $data");

    dynamic payload = data;
    if (payload is String) {
      try {
        payload = jsonDecode(payload);
      } catch (_) {
        // Ignore, will fail validation below.
      }
    }

    if (payload is! Map) {
      AppLogger.warning(
        'Received unsupported message payload: ${payload.runtimeType}',
      );
      return;
    }

    try {
      final rootMap = Map<String, dynamic>.from(payload);
      final dynamic inner =
      (rootMap['data'] is Map)
          ? rootMap['data']
          : (rootMap['message'] is Map)
          ? rootMap['message']
          : (rootMap['payload'] is Map)
          ? rootMap['payload']
          : rootMap;

      if (inner is! Map) {
        AppLogger.warning(
          'Received unsupported message inner payload: ${inner.runtimeType}',
        );
        return;
      }

      final normalizedMessagePayload = _normalizeIncomingMessagePayload(
        rootMap,
        Map<String, dynamic>.from(inner),
      );
      final message = ChatMessageModel.fromJson(normalizedMessagePayload);
      // ✅ DUPLICATE CHECK
      final exists = _messages.any((m) => m.id == message.id);
      if (exists) {
        print("⚠️ Duplicate message skipped: ${message.id}");
        return;
      }
      message.isSentByMe = message.sender.id == userData.id;
      final shouldAutoScroll = true;

      if (message.isSentByMe) {
        final localIndex = _findOptimisticMessageIndex(message);
        if (localIndex != -1) {
          _messages[localIndex] = message;
        } else {
          _messages.add(message);
        }
      } else {
        // Insert in chronological order (oldest -> newest).
        final insertAt = _messages.indexWhere(
              (m) => m.createdAt.isAfter(message.createdAt),
        );
        if (insertAt == -1) {
          _messages.add(message);
        } else {
          _messages.insert(insertAt, message);
        }
        _markMessageAsSeen(message);
      }
      notifyListeners();
      _resolveReplyReferences();
      notifyListeners();
      // BAAD MEIN — thoda aur delay do media ke liye:
      if (shouldAutoScroll) {
        // Extra delay when message has attachments (images/videos need time to layout)
        final hasMedia = message.attachments.isNotEmpty;
        if (hasMedia) {
          Future.delayed(const Duration(milliseconds: 150), () {
            _scrollToBottom(animated: true);
          });
        } else {
          _scrollToBottom(animated: true);
        }
      }
    } catch (e) {
      AppLogger.error('Error parsing incoming message: $e');
    }
  }

  Map<String, dynamic> _normalizeIncomingMessagePayload(
      Map<String, dynamic> rootMap,
      Map<String, dynamic> messageMap,
      )
  {
    final normalized = Map<String, dynamic>.from(messageMap);
    final rawRootSender = rootMap['sender'];
    final rootSender =
    rawRootSender is Map ? Map<String, dynamic>.from(rawRootSender) : null;
    final rawMessageSender = normalized['sender'];
    final fallbackSenderName = _firstNonEmptyString([
      normalized['senderName'],
      normalized['sender_name'],
      normalized['userName'],
      rootSender?['fullName'],
      rootSender?['name'],
      rootMap['senderName'],
      rootMap['sender_name'],
      rootMap['userName'],
      rootMap['name'],
    ]);

    if (rawMessageSender is Map ||
        rootSender != null ||
        rawMessageSender != null ||
        rawRootSender != null ||
        fallbackSenderName.isNotEmpty) {
      final senderMap =
      rawMessageSender is Map
          ? Map<String, dynamic>.from(rawMessageSender)
          : <String, dynamic>{};

      if (rootSender != null) {
        senderMap['_id'] ??= rootSender['_id'] ?? rootSender['id'];
        senderMap['id'] ??= rootSender['id'] ?? rootSender['_id'];
        senderMap['email'] ??= rootSender['email'];
      }

      if (rawMessageSender is! Map && rawMessageSender != null) {
        senderMap['_id'] ??= rawMessageSender.toString();
        senderMap['id'] ??= rawMessageSender.toString();
      }

      if (rawRootSender is! Map && rawRootSender != null) {
        senderMap['_id'] ??= rawRootSender.toString();
        senderMap['id'] ??= rawRootSender.toString();
      }

      if (fallbackSenderName.isNotEmpty) {
        senderMap['fullName'] ??= fallbackSenderName;
        senderMap['name'] ??= fallbackSenderName;
        normalized['senderName'] ??= fallbackSenderName;
        normalized['sender_name'] ??= fallbackSenderName;
      }

      if (senderMap.isNotEmpty) {
        normalized['sender'] = senderMap;
      }
    }

    return normalized;
  }

  String _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }

  int _findOptimisticMessageIndex(ChatMessageModel serverMessage) {
    return _messages.indexWhere((localMessage) {
      if (!localMessage.isSentByMe || localMessage.id == serverMessage.id) {
        return false;
      }

      if (serverMessage.clientMessageId != null &&
          localMessage.clientMessageId == serverMessage.clientMessageId) {
        return true;
      }

      if (localMessage.messageType != serverMessage.messageType) {
        return false;
      }

      if (localMessage.content.trim() != serverMessage.content.trim()) {
        return false;
      }

      if (localMessage.attachments.length != serverMessage.attachments.length) {
        return false;
      }

      for (var index = 0; index < localMessage.attachments.length; index++) {
        final localAttachment = localMessage.attachments[index];
        final serverAttachment = serverMessage.attachments[index];
        if (localAttachment.url != serverAttachment.url ||
            localAttachment.type != serverAttachment.type) {
          return false;
        }
      }

      return true;
    });
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
  })
  async {
    _isLoading = true;
    _currentPage = 1;
    _hasMoreMessages = true;
    _messages.clear();
    notifyListeners();
    _socketService.off(chatEvents[chatRoomScreenType.name]['newMessage']);
    _socketService.off('userTyping');
    _socketService.off('messageReactionUpdated');
    _socketService.off('messageReacted');
    _socketService.off('seenMessage');
    _socketService.off('error');
    _chatRoomScreenType = screen ?? ChatRoomScreenType.mainChat;
    roomId = roomId1 ?? roomId;
    await Future.wait([initializeSocket(), loadMessages()]);

    _isLoading = false;
    notifyListeners();

    // WhatsApp-like: keep the latest message visible at the bottom.
    _scrollToBottom(animated: false);

// 👇 ADD THIS
    _markAllIncomingMessagesAsSeen();
  }

  /// Socket implementation
  Future<void> initializeSocket() async {
    print("Ã°Å¸Å¡â‚¬ Initializing socket connection...");

    // Initialize socket connection
    _socketService.initializeSocket(
      serverUrl: '${Configurations().url}/',
      queryParams: {},
      extraHeaders: {'Authorization': "${userData.token}"},
      onDisconnected: () {
        _socketService.off(chatEvents[chatRoomScreenType.name]['newMessage']);
        _socketService.off('userTyping');
        _socketService.off('messageReactionUpdated');
        _socketService.off('messageReacted');
        _socketService.off('seenMessage');
        _socketService.off('error');
      },
      onConnected: () {
        // Register user
        print("Ã°Å¸â€˜Â¤ Registering user: ${userData.id ?? 'default_user'}");
        _socketService.registerUser(
          userData.id ?? 'default_user',
          chatEvents[chatRoomScreenType.name]['register'],
        );

        _socketService.joinRoom(
          roomId,
          chatEvents[chatRoomScreenType.name]['join'],
        );

        // Listen for incoming messages
        print("Ã°Å¸â€˜â€š Setting up message listener...");
        _socketService.onNewMessage(
          _handleNewMessage,
          chatEvents[chatRoomScreenType.name]['newMessage'],
        );

        _socketService.onUserTyping(_handleUserTyping);
        _socketService.onMessageReactionUpdated(_handleMessageReactionUpdated);
        // Backward-compatible event name (if backend still uses it).
        _socketService.on('messageReacted', (data) {
          if (data is! Map) return;
          final map = Map<String, dynamic>.from(data);
          final messageId = map['messageId']?.toString().trim() ?? '';
          if (messageId.isEmpty) return;

          final emoji = map['emoji']?.toString();
          final user = map['user']?.toString();
          if (emoji == null || emoji.isEmpty || user == null || user.isEmpty) {
            return;
          }

          _handleMessageReactionUpdated(messageId, [
            {'user': user, 'emoji': emoji},
          ]);
        });
        _socketService.onErrorMessage(_handleSocketError);
        _socketService.onSeenMessageUpdated(_handleSeenMessageUpdated);
      },
    );
  }
  void _handleSeenMessageUpdated(String messageId, List<String> readBy) {
    if (messageId.trim().isEmpty) return;

    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final current = _messages[index].readBy;
    if (readBy.isEmpty) return;

    // Merge, keeping unique ids.
    for (final id in readBy) {
      final userId = id.trim();
      if (userId.isEmpty) continue;
      if (!current.contains(userId)) {
        current.add(userId);
      }
    }

    notifyListeners();
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
  void _markLatestIncomingMessageAsSeen() {
    // Backward compatible name (used in older code paths).
    _markAllIncomingMessagesAsSeen();
  }
  void _markAllIncomingMessagesAsSeen() {
    if (_messages.isEmpty) return;
    final myUserId = userData.id ?? '';
    if (myUserId.isEmpty) return;

    var markedAny = false;
    for (final message in _messages) {
      if (message.sender.id == myUserId) continue;
      if (message.readBy.contains(myUserId)) continue;
      _markMessageAsSeen(message);
      markedAny = true;
    }

    if (markedAny) {
      _scheduleChatListRefreshForSeenUpdates();
    }
  }
  void _markMessageAsSeen(ChatMessageModel message) {
    final myUserId = userData.id ?? '';
    if (myUserId.isEmpty) return;
    if (message.sender.id == myUserId) return;
    if (message.readBy.contains(myUserId)) return;

    // Optimistically update local state for immediate UI effect.
    message.readBy.add(myUserId);
    notifyListeners();

    _socketService.seenMessage(message.id);
    _scheduleChatListRefreshForSeenUpdates();
  }

  void _handleUserTyping(String userId) {
    if (userId.isEmpty) return;
    if (userId == (userData.id ?? '')) return;

    _remoteTypingUserId = userId;
    notifyListeners();

    _remoteTypingResetTimer?.cancel();
    _remoteTypingResetTimer = Timer(const Duration(seconds: 2), () {
      _remoteTypingUserId = null;
      notifyListeners();
    });
  }

  void _handleMessageReactionUpdated(
      String messageId,
      List<Map<String, dynamic>> reactions,
      )
  {
    if (messageId.isEmpty) return;
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    _messages[index].reactions =
        reactions
            .map((e) => Reaction.fromJson(e))
            .where((r) => r.user.isNotEmpty && r.emoji.isNotEmpty)
            .toList();
    notifyListeners();
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
          _markLatestIncomingMessageAsSeen();
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
  void _handleSocketError(String message) {
    AppLogger.error('Socket error event: $message');
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
        String messageType = 'text',
        String? clientMessageId,
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
      messageType: messageType,
      content: content,
      translatedContent: content,
      attachments: attachments,
      readBy: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 0,
      isSentByMe: true,
      replyTo: replyTo,
      clientMessageId: clientMessageId,
      status: MessageStatus.sent,
      isDeleted: false,
    );
    _messages.add(localMessage);
    notifyListeners();
    _scrollToBottom(animated: true);
  }
  void _scheduleChatListRefreshForSeenUpdates() {
    _seenRefreshDebounceTimer?.cancel();
    _seenRefreshDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      _chatService.triggerRefresh();
    });
  }
  /// Send a text message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty && !hasImagePreview) {
      AppLogger.warning('Cannot send empty message');
      return;
    }

    try {
      _isSendingMessage = true;
      notifyListeners();

      if (editingMessageId != null) {
        final messageText = messageController.text.trim();
        if (messageText.isEmpty) return;

        await _chatService.editChat(
          content: messageText,
          messageId: editingMessageId!,
        );

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

      if (hasImagePreview && _selectedMediaPaths.isNotEmpty) {
        final selectedMediaPaths = List<String>.from(_selectedMediaPaths);
        final selectedMediaTypes = List<String>.from(_selectedMediaTypes);

        _selectedMediaPaths.clear();
        _selectedMediaNames.clear();
        _selectedMediaTypes.clear();

        await _sendMediaWithText(
          selectedMediaPaths,
          selectedMediaTypes,
          messageText,
        );
      } else {
        final clientMessageId = _createClientMessageId();
        _socketService.sendMessage(
          roomId: roomId,
          content: messageText,
          replyTo: replyMessage?.id,
          event: chatEvents[chatRoomScreenType.name]['send'],
          messageType: MessageType.text.name,
          clientMessageId: clientMessageId,
        );
        _addLocalMessage(
          messageText,
          replyTo: replyMessage,
          messageType: MessageType.text.name,
          clientMessageId: clientMessageId,
        );
        replyMessage = null;
        AppLogger.info('Text message sent');
      }
    } catch (e) {
      AppLogger.error('Error sending message: $e');
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }
  // BAAD MEIN — double frame trick lao:
  void _scrollToBottom({bool animated = true}) {
    if (!scrollController.hasClients) return;

    // First frame: layout starts building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Second frame: image/video widgets have rendered & list has final height
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final target = scrollController.position.maxScrollExtent;
        if (animated) {
          scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(target);
        }
        _markAllIncomingMessagesAsSeen();
      });
    });
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

  Future<void> pickAudioFileAndSend() async {
    if (_isRecordingAudio || _isSendingMessage || _isUploadingImage) {
      return;
    }

    if (_showAttachment) {
      _showAttachment = false;
      notifyListeners();
    }

    final result = await _filePickerService.pickAudioFile();

    await result.fold(
          (failure) async {
        final message = failure.message.trim();
        if (message == 'No audio selected') {
          return;
        }

        AppLogger.error('Error picking audio file: ${failure.message}');
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      },
          (file) async {
        if (!await file.exists()) {
          Fluttertoast.showToast(
            msg: 'Selected audio file is not available',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
          return;
        }

        final duration = await _resolveAudioDuration(file.path);
        await _uploadAndSendAudioMessage(
          file.path,
          duration,
          deleteFileAfterUpload: false,
        );
      },
    );
  }

  Future<Duration?> _resolveAudioDuration(String audioPath) async {
    final audioPlayer = AudioPlayer();
    StreamSubscription<Duration>? durationSubscription;

    try {
      final durationCompleter = Completer<Duration?>();

      durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
        if (!durationCompleter.isCompleted && duration > Duration.zero) {
          durationCompleter.complete(duration);
        }
      });

      await audioPlayer.setSourceDeviceFile(audioPath);

      final directDuration = await audioPlayer.getDuration();
      if (directDuration != null && directDuration > Duration.zero) {
        return directDuration;
      }

      return await durationCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
    } catch (e) {
      AppLogger.warning('Unable to resolve audio duration for $audioPath: $e');
      return null;
    } finally {
      await durationSubscription?.cancel();
      unawaited(audioPlayer.dispose());
    }
  }

  String _resolveAudioMimeType(String audioPath, [String? mimeType]) {
    final normalizedMimeType = mimeType?.trim();
    if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
      return normalizedMimeType;
    }

    switch (path.extension(audioPath).toLowerCase()) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.aac':
        return 'audio/aac';
      case '.amr':
        return 'audio/amr';
      case '.opus':
        return 'audio/opus';
      case '.webm':
        return 'audio/webm';
      case '.flac':
        return 'audio/flac';
      case '.m4a':
      default:
        return 'audio/mp4';
    }
  }

  List<Map<String, dynamic>> _extractUploadedFilesFromResponse(
      Map<String, dynamic> response,
      ) {
    final rawFiles =
        response['files'] ??
            response['data'] ??
            response['file'] ??
            response['urls'] ??
            response['fileUrls'] ??
            response['uploadedFiles'];

    if (rawFiles is List) {
      return rawFiles
          .map<Map<String, dynamic>?>((file) {
        if (file is Map) {
          return Map<String, dynamic>.from(file);
        }
        if (file is String && file.trim().isNotEmpty) {
          return {'url': file.trim()};
        }
        return null;
      })
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    if (rawFiles is Map) {
      return [Map<String, dynamic>.from(rawFiles)];
    }

    final url = response['url']?.toString();
    if (url != null && url.isNotEmpty) {
      return [
        {
          'url': url,
          'name': response['name'],
          'mimeType': response['mimeType'] ?? response['mime_type'],
        },
      ];
    }

    return const [];
  }

  String _resolveUploadedFileUrl(Map<String, dynamic> file) {
    const candidates = ['url', 'fileUrl', 'path', 'location'];

    for (final key in candidates) {
      final value = file[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  String _resolveUploadedFileName(
      Map<String, dynamic> file,
      String fallbackPath,
      ) {
    const candidates = ['name', 'fileName', 'filename', 'originalname'];

    for (final key in candidates) {
      final value = file[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return path.basename(fallbackPath);
  }

  String? _resolveUploadedFileMimeType(Map<String, dynamic> file) {
    const candidates = ['mimeType', 'mime_type', 'contentType'];

    for (final key in candidates) {
      final value = file[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  Future<void> startAudioRecording() async {
    if (_isRecordingAudio || _isSendingMessage || _isUploadingImage) {
      return;
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        Fluttertoast.showToast(
          msg: 'Microphone permission is required to record audio',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
        return;
      }

      final tempDirectory = await getTemporaryDirectory();
      final recordingPath = path.join(
        tempDirectory.path,
        'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: recordingPath,
      );

      _activeRecordingPath = recordingPath;
      _recordingDuration = Duration.zero;
      _recordingSlideOffset = 0;
      _isRecordingAudio = true;
      _showAttachment = false;
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
      notifyListeners();
    } catch (e) {
      _resetRecordingState();
      AppLogger.error('Error starting audio recording: $e');
      Fluttertoast.showToast(
        msg: 'Unable to start audio recording',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  void updateRecordingDrag(double horizontalDelta) {
    if (!_isRecordingAudio) return;
    _recordingSlideOffset = horizontalDelta > 0 ? 0 : horizontalDelta;
    notifyListeners();
  }

  Future<void> completeRecordingGesture() async {
    if (!_isRecordingAudio) return;
    if (shouldCancelRecording) {
      await cancelAudioRecording();
      return;
    }
    await stopAndSendAudioMessage();
  }

  Future<void> cancelAudioRecording() async {
    if (!_isRecordingAudio) return;

    final recordingPath = _activeRecordingPath;
    try {
      final cancelledPath = await _audioRecorder.stop();
      if (cancelledPath != null) {
        await _deleteTemporaryFile(cancelledPath);
      }
    } catch (e) {
      AppLogger.error('Error cancelling audio recording: $e');
    } finally {
      if (recordingPath != null) {
        await _deleteTemporaryFile(recordingPath);
      }
      _resetRecordingState();
      notifyListeners();
    }
  }

  Future<void> stopAndSendAudioMessage() async {
    if (!_isRecordingAudio) return;

    final duration = _recordingDuration;
    String? recordingPath;

    try {
      recordingPath = await _audioRecorder.stop();
    } catch (e) {
      AppLogger.error('Error stopping audio recording: $e');
    } finally {
      _resetRecordingState();
      notifyListeners();
    }

    if (recordingPath == null || recordingPath.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Audio recording was not saved',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
      return;
    }

    if (duration < const Duration(seconds: 1)) {
      await _deleteTemporaryFile(recordingPath);
      Fluttertoast.showToast(
        msg: 'Recording is too short',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
      return;
    }

    await _uploadAndSendAudioMessage(
      recordingPath,
      duration,
      deleteFileAfterUpload: true,
    );
  }

  Future<void> _uploadAndSendAudioMessage(
      String audioPath,
      Duration? duration, {
        bool deleteFileAfterUpload = false,
      }) async {
    final clientMessageId = _createClientMessageId();
    final durationInSeconds =
    duration != null && duration > Duration.zero ? duration.inSeconds : null;

    try {
      _isUploadingImage = true;
      notifyListeners();

      final result = await _chatService.uploadChatFiles(
        [audioPath],
        chatRoomScreenType.name,
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to upload audio: ${failure.message}');
          Fluttertoast.showToast(
            msg: 'Failed to upload audio: ${failure.message}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (response) {
          final files = _extractUploadedFilesFromResponse(response);
          if (files.isEmpty) {
            throw Exception('Invalid audio upload response');
          }

          final uploadedAudio = files.first;
          final uploadedAudioUrl = _resolveUploadedFileUrl(uploadedAudio);
          if (uploadedAudioUrl.isEmpty) {
            throw Exception('Uploaded audio URL is missing');
          }

          final resolvedMimeType = _resolveAudioMimeType(
            audioPath,
            _resolveUploadedFileMimeType(uploadedAudio),
          );
          final attachmentPayload = {
            'url': uploadedAudioUrl,
            'name': _resolveUploadedFileName(uploadedAudio, audioPath),
            'type': MessageType.audio.name,
            'mimeType': resolvedMimeType,
            if (durationInSeconds != null) 'durationInSeconds': durationInSeconds,
          };

          _socketService.sendMessage(
            roomId: roomId,
            content: '',
            attachments: [attachmentPayload],
            replyTo: replyMessage?.id,
            event: chatEvents[chatRoomScreenType.name]['send'],
            messageType: MessageType.audio.name,
            clientMessageId: clientMessageId,
          );

          _addLocalMessage(
            '',
            attachments: [
              Attachment(
                type: MessageType.audio.name,
                url: attachmentPayload['url'] as String,
                name: attachmentPayload['name'] as String,
                mimeType: resolvedMimeType,
                durationInSeconds: durationInSeconds,
              ),
            ],
            replyTo: replyMessage,
            messageType: MessageType.audio.name,
            clientMessageId: clientMessageId,
          );

          replyMessage = null;
          AppLogger.info('Audio message sent successfully');
        },
      );
    } catch (e) {
      AppLogger.error('Error sending audio message: $e');
      Fluttertoast.showToast(
        msg: 'Failed to send audio message',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    } finally {
      if (deleteFileAfterUpload) {
        await _deleteTemporaryFile(audioPath);
      }
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> openVideoChat(screen) async {
    final tokenResponse = await _chatService.sendVChatStatus(
      roomName: roomId,
      status: 'call-request',
      callType: 'video',
      identity: "identity",
      name: userData.name ?? 'User',
      users: userData.id ?? '',
        isGroup: ChatRoomScreenType.groupChat == screen?true:false
    );

    if (tokenResponse['success'] && tokenResponse['token'] != null) {
      Get.to(
            () => VideoCallScreen(roomName: roomId, token: tokenResponse['token'],),
      );
    }
  }

  Future<void> openAudioChat(screen) async {
    final tokenResponse = await _chatService.sendVChatStatus(
      roomName: roomId,
      status: 'call-request',
      callType: 'audio',
      name: userData.name ?? 'User',
      identity: "identity",
      users: userData.id ?? '',
        isGroup: ChatRoomScreenType.groupChat == screen?true:false
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
      )
  async {
    final clientMessageId = _createClientMessageId();

    try {
      _isUploadingImage = true;
      notifyListeners();

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
          final files = _extractUploadedFilesFromResponse(response);

          if (files.isEmpty) {
            throw Exception('Invalid response from server');
          }

          final attachments = <Map<String, dynamic>>[];
          for (var index = 0; index < files.length; index++) {
            final file = files[index];

            final mediaType =
            index < mediaTypes.length ? mediaTypes[index] : 'image';

            final uploadedFileUrl = _resolveUploadedFileUrl(file);
            if (uploadedFileUrl.isEmpty) continue;

            // 👇 extension se detect karo (important for document)
            final fileName = _resolveUploadedFileName(file, '');
            final extension = fileName.split('.').last.toLowerCase();

            String finalType = mediaType;

            // ✅ DOCUMENT DETECTION
            if ([
              'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'
            ].contains(extension)) {
              finalType = 'document';
            }

            attachments.add({
              'url': uploadedFileUrl,
              'name': fileName,
              'type': finalType, // ✅ yaha document bhi aa sakta hai
            });
          }
          if (attachments.isEmpty) {
            throw Exception('Uploaded file URLs are missing');
          }

          final resolvedMessageType = _resolveOutgoingMessageType(attachments);

          _socketService.sendMessage(
            roomId: roomId,
            content: text,
            attachments: attachments,
            event: chatEvents[chatRoomScreenType.name]['send'],
            messageType: resolvedMessageType,
            clientMessageId: clientMessageId,
          );

          final localAttachments =
          attachments
              .map(
                (attachment) => Attachment(
              type: attachment['type']?.toString() ?? 'image',
              url: attachment['url']?.toString() ?? '',
              name: attachment['name']?.toString(),
            ),
          )
              .toList();

          _addLocalMessage(
            text,
            attachments: localAttachments,
            replyTo: replyMessage,
            messageType: resolvedMessageType,
            clientMessageId: clientMessageId,
          );

          replyMessage = null;
          AppLogger.info('Media with text message sent successfully');
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

  String _resolveOutgoingMessageType(List<Map<String, dynamic>> attachments) {
    if (attachments.isEmpty) {
      return MessageType.text.name;
    }
    return (attachments.first['type'] ?? MessageType.text.name).toString();
  }

  String _createClientMessageId() {
    return 'local_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _deleteTemporaryFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      AppLogger.warning('Unable to delete temporary audio file: $e');
    }
  }

  void _resetRecordingState() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _activeRecordingPath = null;
    _isRecordingAudio = false;
    _recordingDuration = Duration.zero;
    _recordingSlideOffset = 0;
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
      final contentMatch = message.previewText.toLowerCase().contains(
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
      final contentMatch = message.previewText.toLowerCase().contains(
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
            rethrow;
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
    _socketService.off(chatEvents[chatRoomScreenType.name]['newMessage']);
    _socketService.off('userTyping');                    // <-- add
    _socketService.off('messageReactionUpdated');        // <-- add
    _socketService.off('messageReacted');                // <-- add
    _socketService.off('seenMessage');                   // <-- add
    _socketService.off('error');                         // <-- add
    _socketService.dispose();


    _recordingTimer?.cancel();
    unawaited(_audioRecorder.dispose());

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
      // 1Ã¯Â¸ÂÃ¢Æ’Â£ Optimistically mark as deleted locally (WhatsApp style)
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index].isDeleted = true;
        _messages[index].content = 'This message was deleted';
        notifyListeners();
      }

      // 2Ã¯Â¸ÂÃ¢Æ’Â£ Call API
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

















