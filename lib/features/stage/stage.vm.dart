import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/chat/video_chat/video_call/call_screen.dart';
import 'package:manager/features/home/organization_home/organization_home.view.dart';
import 'package:manager/features/profile/home/profile.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/features/stage/widgets/call_requiest_dialog.dart';
import 'package:manager/features/tickets/tickets_list/tickets_list.view.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/profile.service.dart';
import 'package:manager/services/socket_service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:manager/widgets/dialogs/confirmation/confirmation_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/locator.dart';
import '../../core/models/hive/user/user.dart';
import '../../services/ticket.service.dart';
import '../chat/chat_list.view.dart';
import '../contacts/contacts_list.dart';
// import '../contacts/chat_list/contacts_list.view.dart'; // File doesn't exist

class StageViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _stageService = locator<StageService>();
  final _chatService = locator<ChatService>();
  final _dialogService = locator<DialogService>();
  final _ticketService = locator<TicketService>();
  final profileService = locator<ProfileService>();
  final SocketService _socketService = SocketService();

  bool get isCloseTicketDialogOpen =>
      _stageService.isCloseTicketDialogOpen.value;
  String get requestedTicketId => _stageService.requestedTicketId.value ?? '';

  int get selectedBottomNavIndex => _stageService.selectedBottomNavIndex.value;

  List<Widget> get bottomNavItems => [
    OrganizationHomeView(),
    TicketsListView(),
    ChatListView(),
    ContactsListView(),
    ProfileView(),
  ];

  User userData = getUser();

  String _readFirstNonEmpty(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '';
  }

  bool _isTrueish(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  void init(StageViewAttributes attributes) {
    // Defer to next frame to avoid "markNeedsBuild called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSelectedBottomNavIndex(attributes.selectedBottomNavIndex);
    });
    initializeSocket();
    profileService.initializeProfile();
  }

  updateSelectedBottomNavIndex(int index) {
    _stageService.updateSelectedBottomNavIndex(index);
  }

  void navigateToRoute(String route) async {
    await _navigationService.navigateTo(route);
  }

  resolveTicket(String ticketId) async {
    await _ticketService.resolveTicket(id: ticketId);
    closeDialog();
  }

  rejectTicket(String ticketId) async {
    await _ticketService.rejectResolveTicket(id: ticketId);
    closeDialog();
  }

  closeDialog() {
    _stageService.setCloseTicketDialogOpen(false, null);
  }

  // New method to handle back button press
  Future<bool> handleBackPress(BuildContext context) async {
    // If you're using stacked_services DialogService
    final dialogResponse = await _dialogService.showCustomDialog(
      variant: DialogType.confirmation,
      data: ConfirmationDialogAttributes(
        title: 'Exit App',
        description: 'Are you sure you want to exit the manager?',
        confirmText: 'Yes',
        cancelText: 'No',
      ),
    );

    return dialogResponse?.confirmed ?? false;
  }

  Future<void> initializeSocket() async {
    print("🚀 Initializing call-event socket connection...");

    // Initialize socket connection
    _socketService.initializeSocket(
      serverUrl: '${Configurations().url}/',
      extraHeaders: {'Authorization': "${userData.token}"},
      onDisconnected: () {
        _socketService.off('call-event');
      },
      onConnected: () {
        _socketService.emit('register', userData.id ?? 'default_user');

        _socketService.on('incoming-call', (data) {
          _onChatRequest(data);
          AppLogger.info('incoming-call =  ${data}');
        });
      },
    );
  }

  _onChatRequest(Map data) {
    String roomid = data['roomName'];
    String profile = '';
    String sender_name = _readFirstNonEmpty(data, [
      'sender_name',
      'senderName',
    ]);
    final bool isGroupCall = _isTrueish(data['isGroupCall']);
    final String groupName = _readFirstNonEmpty(data, [
      'groupTitle',
      'groupName',
      'group_name',
      'title',
      'name',
    ]);
    final String displayName =
        isGroupCall && groupName.isNotEmpty ? groupName : sender_name;
    String receiver_name = data['receiver_name'];
    String call_type = data['callType'];
    String flag = data['flag'];
    String token = data['token'];
    String status = data['eventType'];
    String userId = data['user_id'] ?? '';
    print(
      "stage vm stage vm stage vm stage vm stage vm stage vm stage vm stage vm stage vm stage vm stage vm ",
    );

    bool isVoice = call_type == 'audio';

    if (status == 'call-request') {
      WidgetsBinding.instance.addPostFrameCallback((c) {
        showCallRequestDialog(
          profile: profile,
          name: displayName.isNotEmpty ? displayName : sender_name,
          call_type: call_type,
          flag: flag,
          onAccept: () {
            print("stage vm id passsd");
            openVideoChat(
              roomid,
              status: 'call-accept',
              isGroup: isGroupCall,
              isVoice: isVoice,
              token: token,
              userId: userId,
              receiver_name: receiver_name,
            );
          },
          onDecline: () {
            openVideoChat(
              roomid,
              status: 'call-decline',
              isGroup: isGroupCall,
              isVoice: isVoice,
              token: token,
              userId: userId,
              receiver_name: receiver_name,
            );
          },
        );
      });
    }
  }

  Future<void> openVideoChat(
    String roomId, {
    String status = 'call-request',
    required bool isVoice,
    required String token,
    String userId = '',
    required String receiver_name,
    required bool isGroup,
  }) async {
    final effectiveUserId = userId.isNotEmpty ? userId : (userData.id ?? '');
    if (status == 'call-accept') {
      final tokenResponce = await _chatService.sendVChatStatus(
        roomName: roomId,
        status: status,
        callType: isVoice ? 'audio' : 'video',
        name: userData.name ?? 'User',
        users: effectiveUserId,
        isGroup: isGroup,
        identity: userData.id.toString(),
      );

      if (tokenResponce['success']) {
        Get.back();
        Get.to(
          () => VideoCallScreen(
            roomName: roomId,
            token: tokenResponce['token'],
            isVoice: isVoice,
            name: receiver_name,
          ),
        );
      }
    } else if (status == 'call-decline') {
      await _chatService.sendVChatStatus(
        roomName: roomId,
        status: status,
        callType: isVoice ? 'audio' : 'video',
        name: receiver_name,
        users: effectiveUserId,
        isGroup: isGroup,
        identity: 'identity',
      );
      Get.back();
    }
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_stageService];
}
