import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/attachments_model.dart';
import 'package:manager/core/models/chat_list_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/chat.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../routes/routes.dart';

class GroupInfoViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();

  bool _isMembersLoading = false;
  bool get isMembersLoading => _isMembersLoading;

  bool _isAttachmentsLoading = false;
  bool get isAttachmentsLoading => _isAttachmentsLoading;

  String? _membersLoadError;
  String? get membersLoadError => _membersLoadError;

  String? _attachmentsLoadError;
  String? get attachmentsLoadError => _attachmentsLoadError;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;



  final List<ChatWith> _groupMembers = [];
  List<ChatWith> get groupMembers => _groupMembers;

  final List<AttachmentsDatum> _attachmentsDatum = [];
  List<AttachmentsDatum> get attachmentsDatum => _attachmentsDatum;

  List<AttachmentsDatum> get imageAttachments =>
      _attachmentsDatum.where((attachment) => attachment.isImage).toList(
        growable: false,
      );

  Future<void> init({String? rootID}) async {
    await Future.wait([
      if (rootID != null && rootID.trim().isNotEmpty) fetchGroupMembers(roomId: rootID),
      if (rootID != null && rootID.trim().isNotEmpty)
        getAttachmentsData(roomId: rootID),
    ]);
  }
  List<ChatWith> get filteredMembers {
    if (_searchQuery.trim().isEmpty) return groupMembers;
    final q = _searchQuery.toLowerCase();
    return groupMembers.where((m) =>
    m.fullName.toLowerCase().contains(q) ||
        m.email.toLowerCase().contains(q) ||
        m.countryCode.toLowerCase().contains(q)
    ).toList();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) _searchQuery = '';
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _searchQuery = value;
    notifyListeners();
  }
  Future<void> leaveGroup(String groupId) async {
    try {
      final response = await _chatService.leaveGroup(groupId: groupId);

      response.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message);
          _navigationService.clearStackAndShow(Routes.chatsList);
        },
            (_) async {
          Fluttertoast.showToast(msg: 'Successfully left group');
          _navigationService.clearStackAndShow(Routes.chatsList);
        },
      );
    } catch (e) {
      AppLogger.error('Error leaving group: $e');
      _navigationService.back();
      _navigationService.back();
    }
  }

  Future<void> fetchGroupMembers({required String roomId}) async {
    _isMembersLoading = true;
    _membersLoadError = null;
    notifyListeners();

    try {
      // We don't have a dedicated "room details" endpoint in this app.
      // So we fetch chats and resolve members for the current roomId.
      const page = 1;
      const limit = 200;
      final result = await _chatService.getAllChats(page: page, limit: limit);

      result.fold((failure) {
        _groupMembers
          ..clear();
        _membersLoadError = failure.message;
      }, (data) {
        final chatsRaw = data['chats'] ?? data['data'] ?? data['rooms'];
        final model = ChatListModel.fromJson({
          'message': data['message'] ?? '',
          'total': data['total'] ?? data['count'] ?? 0,
          'chats': chatsRaw is List ? chatsRaw : const [],
        });

        final room = model.chats.firstWhere(
          (c) => c.id == roomId,
          orElse: () => Chats(
            id: '',
            type: '',
            ticket: Ticket.fromJson(const {}),
            chatWith: ChatWith.fromJson(const {}),
            members: const [],
            lastMessage: null,
            unreadCount: 0,
            updatedAt: DateTime.now(),
          ),
        );

        final members = room.id.isEmpty ? const <ChatWith>[] : room.members;
        _groupMembers
          ..clear()
          ..addAll(members);
      });
    } catch (e) {
      AppLogger.error('Error fetching group members: $e');
      _groupMembers.clear();
      _membersLoadError = 'Failed to load group members';
    }

    _isMembersLoading = false;
    notifyListeners();
  }

  Future<void> getAttachmentsData({required String roomId}) async {
    _isAttachmentsLoading = true;
    _attachmentsLoadError = null;
    notifyListeners();

    try {
      final response = await _chatService.getAttachments(roomId: roomId);

      response.fold(
            (exception) {
          _attachmentsDatum.clear();
          _attachmentsLoadError = exception.message;
        },
            (attachmentsModel) {
          _attachmentsDatum
            ..clear()
            ..addAll(attachmentsModel.data);
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching attachments data: $e');
      _attachmentsDatum.clear();
      _attachmentsLoadError = 'Failed to load media';
    }

    _isAttachmentsLoading = false;
    notifyListeners();
  }
}
