import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/models/chat_list_model.dart';
import 'package:manager/core/models/contact_chat.model.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/contact.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/socket_service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../core/models/hive/user/user.dart';
import '../contacts/search_external_contact/search_external_contact_view.dart';
import '../profile/scan_code/scan_code.view.dart';
import '../profile/scan_code/scan_code.vm.dart';

class ChatListViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();
  final _chatContactService = locator<ContactService>();
  final _stageService = locator<StageService>();
  final SocketService _socketService = SocketService();
  List<ChatListModel> _chatRooms = [];

  List<ChatListModel> get chatRooms => _chatRooms;

  List<ChatListModel> _allChats = [];

  List<ChatListModel> get allChats => _allChats;

  List<ChatListModel> _archivedChatRooms = [];

  List<ChatListModel> get archivedChatRooms => _archivedChatRooms;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  StreamSubscription? _refreshSubscription;
  // int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  bool _isLastPage = false;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  // Filter methods for different chat types based on ticket type
  List<ChatListModel> getTicketChats() {
    return _allChats;
  }

  List<ChatListModel> getDepartmentalChats() {
    // API not ready yet - return empty list
    return _allChats;
  }

  List<ChatListModel> getExternalChats() {
    // API not ready yet - return empty list
    return _allChats;
  }

  void navigateToHome() {
    _stageService.updateSelectedBottomNavIndex(0);
  }

  // Count methods for badges
  int get ticketChatsCount => getTicketChats().length;

  int get departmentalChatsCount => getDepartmentalChats().length;

  int get externalChatsCount => getExternalChats().length;

  int get totalChatsCount => _chatRooms.length;

  // Archived filter methods - Note: These methods are not implemented as the API doesn't support archived chats yet
  List<ChatListModel> getArchivedTicketChats() {
    return [];
  }

  List<ChatListModel> getArchivedDepartmentalChats() {
    return [];
  }

  List<ChatListModel> getArchivedExternalChats() {
    return [];
  }

  // Archived count methods
  int get archivedTicketChatsCount => getArchivedTicketChats().length;

  int get archivedDepartmentalChatsCount =>
      getArchivedDepartmentalChats().length;

  int get archivedExternalChatsCount => getArchivedExternalChats().length;

  int get totalArchivedChatsCount => _archivedChatRooms.length;

  // Search functionality
  String _searchQuery = '';

  String get searchQuery => _searchQuery;
  String currentTab = 'ticket';
  Map<String, int> _currentPage = {'department': 1, 'external': 1, 'ticket': 1};

  void setTab(int index) {
    if (index == 0) {
      currentTab = 'ticket';
      getChatRooms();
    } else if (index == 1) {
      currentTab = 'department';
      getOtherChatRooms();
    } else {
      currentTab = 'external';
      getOtherChatRooms();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Filtered search results for each tab
  List<ChatListModel> getFilteredTicketChats() {
    final tickets = getTicketChats();
    if (_searchQuery.isEmpty) return tickets;

    return tickets
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<ChatListModel> getFilteredDepartmentalChats() {
    final departmental = getDepartmentalChats();
    if (_searchQuery.isEmpty) return departmental;

    return departmental
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  List<ChatListModel> getFilteredExternalChats() {
    final external = getExternalChats();
    if (_searchQuery.isEmpty) return external;

    return external
        .where(
          (chat) =>
              _getChatTitle(chat).toLowerCase().contains(_searchQuery) ||
              _getLastMessagePreview(chat).toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void init() async {
    _isLoading = true;
    notifyListeners();

    await getChatRooms(); // Yeh ab page 1 load karega

    _isLoading = false;
    notifyListeners();

    _refreshSubscription = _chatService.refreshStream.listen((trigger) {
      if (trigger && !_chatService.isRefreshing) {
        AppLogger.highlight("Received refresh trigger, refreshing chats list");
        getChatRooms();
      }
    });
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    User userData = getUser();
    _socketService.initializeSocket(
      serverUrl: '${Configurations().url}/',
      queryParams: {},
      extraHeaders: {'Authorization': "${userData.token}"},
      onDisconnected: () {
        _socketService.off('updateChatList');
      },
      onConnected: () {
        _socketService.registerUser(userData.id ?? 'default_user');

        _socketService.on('updateChatList', (data) {
          _handleChatListUpdate(data);
        });
      },
    );
    AppLogger.info("Socket listener 'updateChatList' setup.");
  }

  void _handleChatListUpdate(dynamic data) {
    AppLogger.info("Socket 'updateChatList' received data: $data");
    if (data == null) return;

    try {
      final updatedChat = ChatListModel.fromJson(data);
      if (updatedChat.id == null) return;

      // List mein existing chat dhoondhein
      final index = _allChats.indexWhere((chat) => chat.id == updatedChat.id);

      if (index != -1) {
        // Agar mil gaya, to replace karein
        _allChats[index] = updatedChat;
        AppLogger.info("Socket update: Replaced chat ${updatedChat.id}");
      } else {
        // Agar naya chat hai, to list mein sabse upar add karein
        _allChats.insert(0, updatedChat);
        AppLogger.info("Socket update: Inserted new chat ${updatedChat.id}");
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error("Failed to parse socket chat update: $e");
    }
  }

  Future<void> getChatRooms() async {
    // + Reset pagination
    _currentPage = {'department': 1, 'external': 1, 'ticket': 1};
    _isLastPage = false;

    // + UI ko batayein ki initial loading ho rahi hai
    _isLoading = true;
    notifyListeners();

    try {
      // + Service call ko page aur limit ke saath update karein
      final result = await _chatService.getAllChats(page: 1, limit: _limit);

      result.fold(
        (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _allChats = []; // Failure par list empty karein
          Fluttertoast.showToast(
            msg:
                "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
            // ... (baki toast properties)
          );
        },
        (response) {
          // 'response' ab Map<String, dynamic> hai
          // + Paginated data parse karein
          final List<dynamic> responseData = response['data'] ?? [];
          _allChats =
              responseData.map((e) => ChatListModel.fromJson(e)).toList();

          _currentPage[currentTab] = response['page'] ?? 1;
          _totalPages = response['totalPages'] ?? 1;
          _isLastPage = (_currentPage[currentTab] ?? 1) >= _totalPages;

          AppLogger.info(
            'Successfully loaded ${response.length} chats for page $_currentPage',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching all chats: $e');
      _allChats = [];
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

  Future<void> getOtherChatRooms() async {
    // + Reset pagination
    _currentPage = {'department': 1, 'external': 1, 'ticket': 1};
    _isLastPage = false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _chatContactService.getAllContact(
        page: 1,
        limit: _limit,
        tab: currentTab,
        screen: 'chat',
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to get all chats: ${failure.message}');
          _allChats.clear();
          Fluttertoast.showToast(
            msg:
                "${LanguageService.get("failed_to_load_chats")}: ${failure.message}",
          );
        },
        (response) {
          final List<dynamic> responseData = response['data'] ?? [];
          _allChats =
              responseData
                  .map((e) => ContactChat.fromJson(e))
                  .toList()
                  .map(
                    (contactChat) => ChatListModel(
                      id: contactChat.id,
                      ticket: Ticket(
                        status:
                            contactChat.chatRoom.exists ? 'Active' : 'Inactive',
                      ),

                      unreadCount: contactChat.chatRoom.unreadCount ?? 0,
                      lastMessage: LastMessage(
                        content: contactChat.chatRoom.lastMessage ?? '',
                        createdAt:
                            contactChat.chatRoom.lastMessageTime != null
                                ? DateTime.parse(
                                  contactChat.chatRoom.lastMessageTime!,
                                )
                                : DateTime.now(),
                      ),
                      chatWith: ChatWith(
                        id: contactChat.chatRoom.roomId,
                        fullName: contactChat.name,
                        email: contactChat.designation.toString().toUpperCase(),
                        flag: contactChat.flag,
                      ),
                    ),
                  )
                  .toList();

          _currentPage[currentTab] = response['page'] ?? 1;
          _totalPages = response['totalPages'] ?? 1;
          _isLastPage = (_currentPage[currentTab] ?? 1) >= _totalPages;

          AppLogger.info(
            'Successfully loaded ${response.length} chats for page $_currentPage',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching all chats: $e');
      _allChats = [];
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

  Future<void> loadArchivedChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Note: Archived chats are not supported by the API yet
      // final result = await _chatService.getArchivedChatRooms();
      final result = Right<Failure, List<ChatListModel>>([]);

      result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get archived chat rooms: ${failure.message}',
          );
          _archivedChatRooms = [];

          Fluttertoast.showToast(
            msg: LanguageService.get("failed_to_load_archived_chats"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
        (response) {
          _archivedChatRooms = response;
          AppLogger.info(
            'Successfully loaded ${response.length} archived chat rooms',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching archived chat rooms: $e');
      _archivedChatRooms = [];

      Fluttertoast.showToast(
        msg: LanguageService.get("error_loading_archived_chats"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void navigateToChat(ChatListModel chatRoom) async {
    await _navigationService.navigateTo(Routes.chat, arguments: chatRoom);
    init();
  }

  void navigateToArchivedChats() {
    _navigationService.navigateTo(Routes.archivedChats);
  }

  // Helper methods for search functionality
  String _getChatTitle(ChatListModel chat) {
    if (chat.ticket?.ticketNumber != null) {
      return "Ticket #${chat.ticket!.ticketNumber!}";
    } else if (chat.chatWith?.fullName != null) {
      return chat.chatWith!.fullName!;
    }
    return "${LanguageService.get("chat")} #${chat.id?.substring(0, 6) ?? 'unknown'}";
  }

  String _getLastMessagePreview(ChatListModel chat) {
    if (chat.ticket?.problem != null) {
      return chat.ticket!.problem!;
    } else if (chat.chatWith?.fullName != null) {
      return "Chat with ${chat.chatWith!.fullName!}";
    }
    return LanguageService.get("no_messages_yet");
  }

  bool hasUnreadMessages(ChatListModel chat) {
    return (chat.id?.hashCode ?? 0) % 3 == 0;
  }

  int getUnreadMessageCount(ChatListModel chat) {
    if (hasUnreadMessages(chat)) {
      return ((chat.id?.hashCode ?? 0) % 10) + 1;
    }
    return 0;
  }

  Future<void> refreshChatType(String chatType) async {
    AppLogger.info('Refreshing chats for type: $chatType');
    await getChatRooms();
  }

  Future<void> loadMoreChatRooms() async {
    if (_isLoadingMore || _isLastPage || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage[currentTab] = (_currentPage[currentTab] ?? 1) + 1;

    try {
      final result = await _chatService.getAllChats(
        page: (_currentPage[currentTab] ?? 1),
        limit: _limit,
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to load more chats: ${failure.message}');
          _currentPage[currentTab] = (_currentPage[currentTab] ?? 1) - 1;
        },
        (response) {
          final List<dynamic> responseData = response['data'] ?? [];
          final newChats =
              responseData.map((e) => ChatListModel.fromJson(e)).toList();

          _allChats.addAll(newChats);
          _currentPage[currentTab] = response['page'] ?? _currentPage;
          _totalPages = response['totalPages'] ?? 1;
          _isLastPage = (_currentPage[currentTab] ?? 1) >= _totalPages;

          AppLogger.info('Successfully loaded ${newChats.length} more chats');
        },
      );
    } catch (e) {
      AppLogger.error('Error loading more chats: $e');
      _currentPage[currentTab] = (_currentPage[currentTab] ?? 1) - 1;
    } finally {
      _isLoadingMore = false;
    }

    notifyListeners();
  }

  void onScanFromCamera(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ScanCodeView(
              attributes: ScanCodeViewAttributes(
                screen: ScanScreenType.externalContact,
              ),
            ),
      ),
    );

    // If customer was edited from scan code, refresh the customers list
    if (result == true) {
      // await _loadCustomers();
    }
  }

  void onSearchByPhone(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchExternalContactView(),
      ),
    );

    // If customer was edited from search organization, refresh the customers list
    if (result == true) {
      // await _loadCustomers();
    }
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    _socketService.off("updateChatList");
    AppLogger.info("Socket listener 'updateChatList' removed.");
    super.dispose();
  }
}
