import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manager/features/chat/chat_list.vm.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:stacked/stacked.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import '../../core/models/chat_list_model.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../widgets/common/select_user_option_diealog.dart';
import 'chat.vm.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;
  int selectedTabIndex = 0;
  String _statusFilter = 'all';
  String _sortFilter = 'latest';
  final Set<String> _expiredTicketIds = {};
  final ScrollController _scrollController = ScrollController();
  late ChatListViewModel _model;
  BorderRadius _dynamicBorder = BorderRadius.only(
    topLeft: Radius.circular(AppSizes.v45),
    bottomLeft: Radius.circular(AppSizes.v45),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (mounted) {
        _model.loadMoreChatRooms();
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ChatListViewModel model,
      ) {
    return GradientAppBar(
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => model.navigateToHome(),
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
      ),
      titleKey: 'messages',
      actions: [
        InkWell(
          onTap: _toggleSearch,
          child: Image.asset(
            AppImages.search,
            width: 23,
            height: 23,
            color: AppColors.white,
          ),
        ),
        SizedBox(width: 15),
        InkWell(
          onTap: () => model.navigateToArchivedChats(),
          child: Image.asset(
            AppImages.archive,
            width: 23,
            height: 23,
            color: AppColors.white,
          ),
        ),
        PopupMenuButton<String>(
          icon: Stack(
            children: [
              Image.asset(
                AppImages.filter,
                width: 23,
                height: 23,
                color: AppColors.white,
              ),
              if (_statusFilter != 'all' ||
                  (_sortFilter != 'latest' && _statusFilter == 'all'))
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          menuPadding: EdgeInsets.zero,
          offset: Offset(-10, 40),
          onSelected: (String value) {
            setState(() {
              if (value == 'in_progress' || value == 'on_hold') {
                // Toggle status filter - if same filter is selected, remove it
                if (_statusFilter == value) {
                  _statusFilter = 'all';
                } else {
                  _statusFilter = value;
                }
                // Reset sort filter when status filter changes
                _sortFilter = 'latest';
              } else if (value == 'latest' || value == 'oldest') {
                // Toggle sort filter - if same filter is selected, reset to default
                if (_sortFilter == value) {
                  _sortFilter = 'latest';
                } else {
                  _sortFilter = value;
                }
                // Reset status filter when sort filter changes
                _statusFilter = 'all';
              }
            });
          },
          itemBuilder:
              (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'in_progress',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_statusFilter == 'in_progress')
                      Icon(Icons.check, color: AppColors.primary, size: 20),
                    if (_statusFilter == 'in_progress') SizedBox(width: 8),
                    Text(
                      'In Progress',
                      style: TextStyle(
                        color:
                        _statusFilter == 'in_progress'
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                        _statusFilter == 'in_progress'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuDivider(height: 0),
            PopupMenuItem<String>(
              value: 'on_hold',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_statusFilter == 'on_hold')
                      Icon(Icons.check, color: AppColors.primary, size: 20),
                    if (_statusFilter == 'on_hold') SizedBox(width: 8),
                    Text(
                      'On Hold',
                      style: TextStyle(
                        color:
                        _statusFilter == 'on_hold'
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                        _statusFilter == 'on_hold'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuDivider(height: 0),
            PopupMenuItem<String>(
              value: 'latest',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_sortFilter == 'latest' && _statusFilter == 'all')
                      Icon(Icons.check, color: AppColors.primary, size: 20),
                    if (_sortFilter == 'latest' && _statusFilter == 'all')
                      SizedBox(width: 8),
                    Text(
                      'Latest to Oldest',
                      style: TextStyle(
                        color:
                        (_sortFilter == 'latest' &&
                            _statusFilter == 'all')
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                        (_sortFilter == 'latest' &&
                            _statusFilter == 'all')
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuDivider(height: 0),
            PopupMenuItem<String>(
              value: 'oldest',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_sortFilter == 'oldest' && _statusFilter == 'all')
                      Icon(Icons.check, color: AppColors.primary, size: 20),
                    if (_sortFilter == 'oldest' && _statusFilter == 'all')
                      SizedBox(width: 8),
                    Text(
                      'Oldest to Latest',
                      style: TextStyle(
                        color:
                        (_sortFilter == 'oldest' &&
                            _statusFilter == 'all')
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                        (_sortFilter == 'oldest' &&
                            _statusFilter == 'all')
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatListViewModel>.reactive(
      viewModelBuilder: () => ChatListViewModel(),
      onViewModelReady: (model) {
        _model = model;
        model.init();
      },
      builder:
          (context, model, child) => Scaffold(
        appBar: _buildAppBar(context, model),
        body: Container(
          color: AppColors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Animated search bar
                SlideTransition(
                  position: _slideAnimation,
                  child:
                  _isSearchVisible
                      ? _buildSearchBar(context, model)
                      : const SizedBox.shrink(),
                ),
                // Tab Bar
                Container(
                  color: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w20,
                    vertical: AppSizes.h16,
                  ),
                  child: CustomSlidingSegmentedControl<int>(
                    height: 40,
                    innerPadding: EdgeInsets.zero,
                    initialValue: selectedTabIndex,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.v45),
                    ),
                    padding: AppSizes.v4,
                    isStretch: true,
                    children: {
                      0: Text(
                        LanguageService.get("tickets"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                          selectedTabIndex == 0
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      1: Text(
                        LanguageService.get("departmental"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                          selectedTabIndex == 1
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      2: Text(
                        LanguageService.get("external"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                          selectedTabIndex == 2
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                    },
                    fromMax: true,
                    thumbDecoration: BoxDecoration(
                      borderRadius: _dynamicBorder,
                      color: AppColors.primary,
                    ),
                    onValueChanged: (int value) {
                      model.setTab(value);
                      setState(() {
                        selectedTabIndex = value;
                        // Update dynamic border radius based on selected segment
                        switch (value) {
                          case 0:
                            _dynamicBorder = BorderRadius.only(
                              topLeft: Radius.circular(AppSizes.v45),
                              bottomLeft: Radius.circular(AppSizes.v45),
                            );
                            break;
                          case 1:
                            _dynamicBorder = BorderRadius.circular(0);
                            break;
                          case 2:
                            _dynamicBorder = BorderRadius.only(
                              topRight: Radius.circular(AppSizes.v45),
                              bottomRight: Radius.circular(AppSizes.v45),
                            );
                            break;
                        }
                      });
                    },
                  ),
                ),
                // Tab Content
                Expanded(
                  child: Container(
                    color: AppColors.scaffoldBackground,
                    child:
                    model.isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                        : _buildFilteredChatList(context, model),
                  ),
                ),
              ],
            ),
          ),
        ),
        // floatingActionButton: model.currentTab=='external'?FloatingActionButton(
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v50)),
        //
        //     backgroundColor: AppColors.primary,
        //     child: Icon(Icons.add),
        //     onPressed: (){
        //       showCustomAddMenuDialog(
        //
        //           alignment:Alignment.bottomRight,
        //           context: context, dialogTitle: 'Add New Contact'.lang, itemLenth:2, menuItems: [
        //         CustomMenuItem(onTap: (){
        //           model.onScanFromCamera(context);
        //         }),
        //         CustomMenuItem(onTap: (){
        //           model.onSearchByPhone(context);
        //         })
        //       ]);
        //     }):null,
      ),
    );
  }

  Widget _buildFilteredChatList(BuildContext context, ChatListViewModel model) {
    List<dynamic> filteredChats;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    // Filter by tab type using the model's methods
    switch (selectedTabIndex) {
      case 0: // Tickets
        filteredChats = model.getFilteredTicketChats();
        emptyTitle = LanguageService.get("no_ticket_conversations");
        emptySubtitle = LanguageService.get("ticket_chats_appear_here");
        emptyIcon = Icons.support_agent;
        break;
      case 1: // Departmental
        filteredChats = model.getFilteredDepartmentalChats();
        emptyTitle = LanguageService.get("no_departmental_conversations");
        emptySubtitle = LanguageService.get("departmental_chats_appear_here");
        emptyIcon = Icons.business;
        break;
      case 2:
        filteredChats = model.getFilteredExternalChats();
        emptyTitle = LanguageService.get("no_external_conversations");
        emptySubtitle = LanguageService.get("external_chats_appear_here");
        emptyIcon = Icons.public;
        break;
      default:
        filteredChats = model.allChats;
        emptyTitle = "No conversations";
        emptySubtitle = "No chats available";
        emptyIcon = Icons.chat;
    }

    // Apply status filter
    if (_statusFilter != 'all') {
      filteredChats =
          filteredChats.where((chat) {
            final status = chat.ticket?.status?.toLowerCase() ?? '';
            switch (_statusFilter) {
              case 'in_progress':
                return status == 'active';
              case 'on_hold':
                return status == 'on hold';
              default:
                return true;
            }
          }).toList();
    }

    // Apply sort filter
    if (_sortFilter == 'oldest') {
      filteredChats = filteredChats.reversed.toList();
    }

    if (filteredChats.isEmpty) {
      return _buildEmptyState(context, emptyTitle, emptySubtitle, emptyIcon);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: () async {
        await model.getChatRooms();
      },
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 0),
          );
        },

        itemCount: filteredChats.length + (model.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredChats.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          // + Warna, chat item dikhayein
          final chatRoom = filteredChats[index];
          return _buildChatItem(context, model, chatRoom);
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ChatListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_conversations"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
          suffixIcon:
          _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.gray),
            onPressed: () {
              _searchController.clear();
              model.clearSearch();
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(BuildContext context, Chats model) {
    final fullName = model.chatWith.fullName.trim();
    final safeName = fullName.isEmpty ? 'VG' : fullName;
    final initials =
    safeName.substring(0, safeName.length >= 2 ? 2 : 1).toUpperCase();

    final flagPath = model.chatWith.flag?.trim();
    final flagUrl =
    (flagPath == null || flagPath.isEmpty || flagPath.toLowerCase() == 'null')
        ? null
        : flagPath.prefixWithBaseUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.v16),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ),
        if (flagUrl != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SvgPicture.network(
                flagUrl,
                width: 17,
                height: 17,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatItem(
      BuildContext context,
      ChatListViewModel model,
      Chats chatRoom,
      )
  {
    final chatTitle = _getChatTitle(chatRoom);
    // final lastMessage = _getLastMessagePreview(chatRoom);
    final subText = _getSubText(chatRoom);
    final rawTicketNumber = chatRoom.ticket.ticketNumber.trim();
    final ticketNumber = rawTicketNumber.isNotEmpty ? "#$rawTicketNumber" : '';
    final status =
    chatRoom.ticket.status.trim().isEmpty ? 'Unknown' : chatRoom.ticket.status;
    final chatWithName =
    chatRoom.chatWith.fullName.toString().capitalizeWords.trim().isEmpty
        ? 'Unknown'
        : chatRoom.chatWith.fullName.toString().capitalizeWords;

    return InkWell(
      onTap: () {
        ChatRoomScreenType screen = ChatRoomScreenType.mainChat;
        bool isContactChat =
            model.currentTab == 'department' || model.currentTab == 'external';
        String roomId = chatRoom.id;
        if (isContactChat) {
          roomId = chatRoom.chatWith.id;
          screen = ChatRoomScreenType.contactChat;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ChatView(
              isVisible: !isContactChat,
              contactName: chatWithName,
              contactNumber:
              isContactChat ? chatRoom.chatWith.email : ticketNumber,
              contactInitials:
              chatWithName.isNotEmpty
                  ? chatWithName.substring(0, 1).toUpperCase()
                  : 'U',
              roomId: roomId,
              ticketId:
              chatRoom.ticket.id.trim().isEmpty ? null : chatRoom.ticket.id,
              ticketStatus: chatRoom.ticket.status,
              updatedAt: chatRoom.ticket.updatedAt.formatReadableDate(),
              flag: chatRoom.chatWith.flag?.prefixWithBaseUrl,
              screen: screen,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.h15,
          horizontal: AppSizes.w16,
        ),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCountryFlag(context, chatRoom),
            SizedBox(width: AppSizes.w10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Text(
                          chatTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // if (chatRoom.ticket?.status == "On Hold") _buildCountdownTimer(chatRoom, model),
                      // SizedBox(width: 10),
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                      //   decoration: BoxDecoration(
                      //     color: _getStatusColor(status).withValues(alpha: 0.1),
                      //     borderRadius: BorderRadius.circular(AppSizes.v6),
                      //   ),
                      //   child: Text(status, style: TextStyle(color: _getStatusColor(status), fontSize: AppSizes.v12)),
                      // ),
                      if (model.currentTab == 'ticket') ...[
                        if (chatRoom.ticket?.status == "On Hold")
                          _buildCountdownTimer(chatRoom, model),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.w8,
                            vertical: AppSizes.h2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.v6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontSize: AppSizes.v12,
                            ),
                          ),
                        ),
                      ],

                      if (model.currentTab != 'ticket') ...[
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(
                                chatRoom.lastMessage?.createdAt ??
                                    DateTime.now(),
                              ),
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: AppSizes.v12,
                              ),
                            ),
                            if (((chatRoom.unreadCount ?? 0) > 0))
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.w5,
                                  vertical: AppSizes.h2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor,
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(AppSizes.v70),
                                ),
                                child: Text(
                                  (chatRoom.unreadCount ?? 0).toString(),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: AppSizes.v12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Text(
                          subText,
                          style:
                          (chatRoom.unreadCount ?? 0) > 0
                              ? TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          )
                              : TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        ticketNumber,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'rejected' || 'inactive':
        return Colors.red;
      case 'on hold':
        return Colors.red;
      case 'waiting for accept':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getLastMessagePreview(Chats chat) {
    final content = chat.lastMessage?.content.trim();
    if (content != null && content.isNotEmpty) return content;

    final name = chat.chatWith.fullName.trim();
    if (name.isNotEmpty) return "Chat with ${name.capitalizeWords}";

    return LanguageService.get("no_messages_yet");
  }


  String _getSubText(Chats chat) {
    final ticket = chat.ticket;
    final status = ticket.status.trim().toLowerCase();
    final updatedAt = ticket.updatedAt.formatReadableDate();
    final hasTicket = ticket.id.trim().isNotEmpty;

    // 🎯 If ticket exists and is resolved
    if (hasTicket && status == "resolved") {
      return updatedAt.isNotEmpty ? "Resolved In $updatedAt" : "Resolved";
    }

    // 🎯 If ticket exists but not resolved
    if (hasTicket) {
      return updatedAt.isNotEmpty ? "Pending Since $updatedAt" : "Pending";
    }

    // 🎯 If no ticket, show email
    final email = chat.chatWith.email.trim();
    if (email.isNotEmpty) {
      return email;
    }

    return LanguageService.get("no_messages_yet");
  }

  Widget _buildCountdownTimer(Chats chatRoom, ChatListViewModel model) {
    final ticket = chatRoom.ticket;
    final DateTime? scheduledAt = ticket.rescheduleUpdateTime;

    if (ticket.id.trim().isEmpty || scheduledAt == null) {
      return Text(
        '-',
        style: TextStyle(
          color: _getStatusColor(ticket.status),
          fontSize: AppSizes.v12,
        ),
      );
    }

    final DateTime rescheduleTime = scheduledAt;

    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        if (now.isAfter(rescheduleTime)) {
          // Trigger background refresh when timer expires (only once per ticket)
          final ticketId = ticket.id;
          if (ticketId.isNotEmpty && !_expiredTicketIds.contains(ticketId)) {
            _expiredTicketIds.add(ticketId);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              model.getChatRooms();
            });
          }
          return Text(
            'Expired',
            style: TextStyle(color: AppColors.error, fontSize: AppSizes.v12),
          );
        }

        final difference = rescheduleTime.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        String timeString;
        if (hours > 0) {
          timeString = '${hours}h ${minutes}m ${seconds}s';
        } else if (minutes > 0) {
          timeString = '${minutes}m ${seconds}s';
        } else {
          timeString = '${seconds}s';
        }

        return Text(
          timeString,
          style: TextStyle(
            color: _getStatusColor(ticket.status),
            fontSize: AppSizes.v12,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }

  String _getChatTitle(dynamic chat) {
    if (chat.chatWith?.fullName != null) {
      return chat.chatWith!.fullName?.toString().capitalizeWords ?? '';
    } else if (chat.ticket?.ticketNumber != null) {
      return "Ticket #${chat.ticket!.ticketNumber!}";
    }
    return "${LanguageService.get("chat")} #${chat.id?.substring(0, 6) ?? 'unknown'}";
  }
}
