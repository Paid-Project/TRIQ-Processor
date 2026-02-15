import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';

// Dummy archived chat data model
class DummyArchivedChatData {
  final String id;
  final String title;
  final String lastMessage;
  final String time;
  final String status;
  final String type;
  final int unreadCount;
  final String archivedDate;

  DummyArchivedChatData({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.status,
    required this.type,
    required this.unreadCount,
    required this.archivedDate,
  });
}

class ArchivedChatList extends StatefulWidget {
  const ArchivedChatList({super.key});

  @override
  State<ArchivedChatList> createState() => _ArchivedChatListState();
}

class _ArchivedChatListState extends State<ArchivedChatList> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GradientAppBar(
        titleKey: 'archived_messages',
        leading: IconButton(
          icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon:
                _isSearchVisible
                    ? Icon(Icons.close, color: AppColors.white, size: 24)
                    : Image.asset(AppImages.search, width: 24, height: 24, color: AppColors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context) : const SizedBox.shrink()),
          Expanded(child: _buildArchivedChatList(context)),
        ],
      ),
    );
  }

  Widget _buildArchivedChatList(BuildContext context) {
    final archivedChats = _getDummyArchivedChats();

    if (archivedChats.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      onRefresh: () async {
        // Simulate refresh delay
        await Future.delayed(Duration(seconds: 1));
      },
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Divider(height: 0));
        },
        itemCount: archivedChats.length,
        itemBuilder: (context, index) {
          final chatRoom = archivedChats[index];
          return _buildChatItem(context, chatRoom);
        },
      ),
    );
  }

  List<DummyArchivedChatData> _getDummyArchivedChats() {
    return [
      DummyArchivedChatData(
        id: '1',
        title: 'Ticket #12340',
        lastMessage: 'Issue resolved successfully. Thank you for your patience.',
        time: 'Dec 15, 2023 • 2:30 PM',
        status: 'Resolved',
        type: 'ticket',
        unreadCount: 0,
        archivedDate: 'Dec 15, 2023',
      ),
      DummyArchivedChatData(
        id: '2',
        title: 'Old Support Team',
        lastMessage: 'This conversation has been archived due to inactivity',
        time: 'Dec 10, 2023 • 1:45 PM',
        status: 'Archived',
        type: 'departmental',
        unreadCount: 0,
        archivedDate: 'Dec 10, 2023',
      ),
      DummyArchivedChatData(
        id: '3',
        title: 'External Partner - Old Corp',
        lastMessage: 'Project completed. All deliverables sent.',
        time: 'Dec 8, 2023 • 12:20 PM',
        status: 'Completed',
        type: 'external',
        unreadCount: 0,
        archivedDate: 'Dec 8, 2023',
      ),
      DummyArchivedChatData(
        id: '4',
        title: 'Ticket #12335',
        lastMessage: 'Customer confirmed issue was resolved',
        time: 'Dec 5, 2023 • 11:15 AM',
        status: 'Closed',
        type: 'ticket',
        unreadCount: 0,
        archivedDate: 'Dec 5, 2023',
      ),
      DummyArchivedChatData(
        id: '5',
        title: 'Legacy Team Chat',
        lastMessage: 'Team discussion about old project requirements',
        time: 'Dec 1, 2023 • 10:30 AM',
        status: 'Archived',
        type: 'departmental',
        unreadCount: 0,
        archivedDate: 'Dec 1, 2023',
      ),
      DummyArchivedChatData(
        id: '6',
        title: 'Client - Old Industries',
        lastMessage: 'Contract ended. All services completed.',
        time: 'Nov 28, 2023 • 9:45 AM',
        status: 'Completed',
        type: 'external',
        unreadCount: 0,
        archivedDate: 'Nov 28, 2023',
      ),
      DummyArchivedChatData(
        id: '7',
        title: 'Ticket #12330',
        lastMessage: 'Issue was escalated and resolved by senior team',
        time: 'Nov 25, 2023 • 8:20 AM',
        status: 'Resolved',
        type: 'ticket',
        unreadCount: 0,
        archivedDate: 'Nov 25, 2023',
      ),
      DummyArchivedChatData(
        id: '8',
        title: 'Old Management Discussion',
        lastMessage: 'Monthly review meeting notes from last quarter',
        time: 'Nov 20, 2023 • 4:15 PM',
        status: 'Archived',
        type: 'departmental',
        unreadCount: 0,
        archivedDate: 'Nov 20, 2023',
      ),
    ];
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          // Add search functionality if needed
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_archived_conversations"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.v24),
              decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: Icon(Icons.archive_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.7)),
            ),
            SizedBox(height: AppSizes.h16),
            Text(
              LanguageService.get("no_archived_conversations"),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: AppSizes.h8),
            Text(
              LanguageService.get("archived_conversations_appear_here"),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, DummyArchivedChatData chatRoom) {
    return InkWell(
      onTap: () {
        // Navigate to archived chat screen with dummy data
        print('Tapped on archived chat: ${chatRoom.title}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.h15, horizontal: AppSizes.w16),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCountryFlag(context),
            SizedBox(width: AppSizes.w10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                        decoration: BoxDecoration(color: AppColors.redBack.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v6)),
                        child: Text("Archived", style: TextStyle(color: AppColors.redBack, fontSize: AppSizes.v12)),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('${LanguageService.get("Resolved In")} : ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                            Text(chatRoom.archivedDate, style: TextStyle(fontSize: 11, color: AppColors.black)),
                          ],
                        ),
                      ),
                      Text(chatRoom.id, style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold)),
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

  Widget _buildCountryFlag(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v16)),
          alignment: Alignment.center,
          child: Text(
            "VG - Van Group".substring(0, 2).toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, width: 17, height: 17, fit: BoxFit.cover)),
        ),
      ],
    );
  }
}
