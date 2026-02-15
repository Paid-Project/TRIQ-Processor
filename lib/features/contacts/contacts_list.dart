import 'package:flutter/material.dart';
import 'package:manager/core/models/contact_chat.model.dart';
import 'package:manager/features/chat/chat.vm.dart';
import 'package:manager/features/contacts/contact_list.vm.dart';
import 'package:manager/features/contacts/create_group/create_group.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/animated_floting_button.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:stacked/stacked.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

import '../../widgets/common/select_user_option_diealog.dart';

class ContactsListView extends StatefulWidget {
  const ContactsListView({super.key});

  @override
  State<ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView>
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
  late ContactListViewModel _model;
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
    ContactListViewModel model,
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
      titleKey: 'Contact',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContactListViewModel>.reactive(
      viewModelBuilder: () => ContactListViewModel(),
      onViewModelReady: (model) {
        _model = model;
        model.init();
      },
      builder:
          (context, model, child) => Scaffold(
            appBar: _buildAppBar(context, model),
            body: Container(
              color: AppColors.appBarBackground,
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
                            LanguageService.get("departmental"),
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
                            LanguageService.get("external"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  selectedTabIndex == 1
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
                          setState(() {
                            selectedTabIndex = value;
                            model.setTab(selectedTabIndex);
                            switch (value) {
                              case 0:
                                _dynamicBorder = BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.v45),
                                  bottomLeft: Radius.circular(AppSizes.v45),
                                );
                                break;
                              case 1:
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
                    AppGaps.h14,
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
            floatingActionButton:
                model.currentTab == 'department'
                    ? null
                    : StatefulBuilder(
                      builder: (context, set) {
                        return FloatingActionButton(
                          key: ValueKey(
                            model.isFloatingOpen,
                          ), // <<< BAS YEH EK LINE KAAFI HAI
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.v50),
                          ),
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            model.isFloatingOpen ? Icons.clear : Icons.add,
                          ),
                          onPressed: () async {
                            model.toggleFloating();
                            set(() {});

                            await showCustomAddMenuDialog(
                              alignment: Alignment.bottomRight,
                              context: context,
                              dialogTitle: 'Add New Contact'.lang,
                              itemLenth: 2,
                              menuItems: [
                                CustomMenuItem(
                                  onTap: () => model.onScanFromCamera(context),
                                ),
                                CustomMenuItem(
                                  onTap: () => model.onSearchByPhone(context),
                                ),
                              ],
                            );

                            model.toggleFloating();
                            set(() {});
                          },
                        );
                      },
                    ),
          ),
    );
  }

  Widget _buildFilteredChatList(
    BuildContext context,
    ContactListViewModel model,
  ) {
    List<dynamic> filteredChats;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    // Filter by tab type using the model's methods
    switch (selectedTabIndex) {
      // case 0: // Tickets
      //   filteredChats =
      //   emptyTitle = LanguageService.get("no_ticket_conversations");
      //   emptySubtitle = LanguageService.get("ticket_chats_appear_here");
      //   emptyIcon = Icons.support_agent;
      //   break;
      case 0:
        filteredChats = model.getFilteredTicketChats();
        emptyTitle = LanguageService.get("no_departmental_contact");
        emptySubtitle = '';
        emptyIcon = Icons.business;
        break;
      case 1: // External
        filteredChats = model.getFilteredDepartmentalChats();
        emptyTitle = LanguageService.get("no_external_contact");
        emptySubtitle = '';
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

  Widget _buildSearchBar(BuildContext context, ContactListViewModel model) {
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

  Widget _buildCountryFlag(BuildContext context, ContactChat model) {
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
            "${model.name.length > 1 ? "${model.name ?? 'VG'}".substring(0, 2) : model.name}"
                .toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ),
        if (model.flag != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SvgPicture.network(
                "${model.flag?.prefixWithBaseUrl ?? ''}",
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
    ContactListViewModel model,
    ContactChat chatRoom,
  ) {
    final chatTitle = _getChatTitle(chatRoom);
    // final lastMessage = _getLastMessagePreview(chatRoom);
    final subText = _getSubText(chatRoom);
    final ticketNumber = chatRoom.phone;
    final status = (chatRoom.status ?? 'Unknown').toLowerCase();
    final chatWithName = chatRoom.name ?? 'Unknown';

    return InkWell(
      onTap: () {
        // Navigate to chat screen with real data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ChatView(
                  contactName: chatWithName,
                  contactNumber: ticketNumber,
                  contactInitials:
                      chatWithName.isNotEmpty
                          ? chatWithName.substring(0, 1).toUpperCase()
                          : 'U',
                  roomId: chatRoom.chatRoom.roomId ?? '',
                  ticketId: '',
                  ticketStatus: '',
                  flag: chatRoom.flag?.prefixWithBaseUrl,
                  screen: ChatRoomScreenType.contactChat,
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

                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.w10,
                          vertical: AppSizes.h5,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                        ),
                        child: Text(
                          status.capitalize(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: AppSizes.v12,
                          ),
                        ),
                      ),

                      // if(( (chatRoom.unreadCount??0) > 0))
                      //   Container(
                      //     padding: EdgeInsets.symmetric(horizontal: AppSizes.w5, vertical: AppSizes.h2),
                      //     decoration: BoxDecoration(
                      //         color: context.theme.primaryColor,
                      //         shape: BoxShape.circle
                      //       // borderRadius: BorderRadius.circular(AppSizes.v70),
                      //     ),
                      //     child: Text((chatRoom.unreadCount??0).toString(), style: TextStyle(color:AppColors.white, fontSize: AppSizes.v12)),
                      //   ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    subText.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSubText(ContactChat chat) {
    String text = chat.designation ?? '';
    return text;
    return LanguageService.get("no_messages_yet");
  }

  String _getChatTitle(ContactChat chat) {
    return "${chat.name}";
    return "${LanguageService.get("chat")} #${chat.id.substring(0, 6) ?? 'unknown'}";
  }
}
