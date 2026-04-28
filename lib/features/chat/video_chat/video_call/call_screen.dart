// lib/features/chat/video_chat/video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:manager/features/chat/video_chat/video_call/call_view_model.dart';
import 'package:manager/features/chat/video_chat/widgets/control_bar.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_grid.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_tile.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/features/chat/video_chat/widgets/floating_call_service.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:provider/provider.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomName;
  final String token;
  final bool isVoice;
  final String name;

  final String? contactName;
  final String? contactNumber;
  final String? contactInitials;
  final String? roomId;
  final String? ticketId;
  final String? ticketStatus;
  final String? userRole;
  final String? flag;

  const VideoCallScreen({
    required this.roomName,
    required this.token,
    this.isVoice = false,
    this.contactName,
    this.contactNumber,
    required this.name,
    this.contactInitials,
    this.roomId,
    this.ticketId,
    this.ticketStatus,
    this.userRole,
    this.flag,
    super.key,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final CallViewModel _viewModel;
  final FloatingCallService _floatingService = FloatingCallService();

  @override
  void initState() {
    super.initState();
    _viewModel =
        CallViewModel()..initCall(
          roomName: widget.roomName,
          token: widget.token,
          isVoice: widget.isVoice,
        );
    _viewModel.addListener(_onParticipantsChanged);
  }

  void _onParticipantsChanged() {
    // If someone else ended call or event received
    if (_viewModel.shouldPop) {
      _floatingService.removeFloatingCall();
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onParticipantsChanged);
    if (!_floatingService.isFloating) {
      _viewModel.disconnect();
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _minimizeToFloating() {
    final floatingService = FloatingCallService();
    floatingService.showFloatingCall(
      context: context,
      viewModel: _viewModel,
      isVoice: widget.isVoice,
      roomName: widget.roomName,
      token: widget.token,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Consumer<CallViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isConnecting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Voice aur Video dono same UI - sirf control bar different
              return _buildCallUI(viewModel);
            },
          ),
        ),
      ),
    );
  }

  // ============ COMMON CALL UI (Voice + Video same) ============
  Widget _buildCallUI(CallViewModel viewModel) {
    return Column(
      children: [
        _buildTopBar(viewModel),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCallLayout(viewModel),
          ),
        ),
        // Voice call: without video button, Video call: with video button
        widget.isVoice
            ? _buildVoiceControlBar(viewModel)
            : ControlBar(
              isMicOn: viewModel.isMicOn,
              isVideoOn: viewModel.isVideoOn,
              onMicPressed: viewModel.toggleMic,
              onVideoPressed: viewModel.toggleVideo,
              onEndCallPressed: () {
                _viewModel.endCall();
              },
            ),
      ],
    );
  }

  Widget _buildTopBar(CallViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primarySuperLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(AppImages.vc_profile_2user),
            ),
          ),
          Column(
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.callDuration,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primarySuperLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: GestureDetector(
              onTap: _minimizeToFloating,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AppImages.vc_import),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _displayNameFor(CallParticipant cp, CallViewModel viewModel) {
    final p = cp.participant;
    final isLocal =
        p is LocalParticipant || p == viewModel.room?.localParticipant;
    if (isLocal) return null; // ParticipantTile will show 'You'
    return widget.name; // Contact name for remote participants
  }

  Widget _buildCallLayout(CallViewModel viewModel) {
    final participants = viewModel.participants;

    if (participants.isEmpty) {
      return const Center(child: Text("Waiting for participants..."));
    }

    final count = participants.length;

    // 👇 1 USER
    if (count == 1) {
      return ParticipantTile(
        participantState: participants[0],
        displayName: _displayNameFor(participants[0], viewModel),
      );
    }

    // 👇 2 USERS (TOP-BOTTOM)
    if (count == 2) {
      return Column(
        children: List.generate(count, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ParticipantTile(
                participantState: participants[index],
                displayName: _displayNameFor(participants[index], viewModel),
              ),
            ),
          );
        }),
      );
    }

    // 👇 3 USERS (1 BIG + 2 SMALL)
    if (count == 3) {
      return Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ParticipantTile(
                participantState: participants[0],
                displayName: _displayNameFor(participants[0], viewModel),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ParticipantTile(
                      participantState: participants[index + 1],
                      displayName: _displayNameFor(
                        participants[index + 1],
                        viewModel,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    // 👇 4+ USERS (AUTO GRID 🔥)
    int crossAxisCount = 2;

    if (count > 4) crossAxisCount = 3;
    if (count > 9) crossAxisCount = 4;

    return GridView.builder(
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return ParticipantTile(
          participantState: participants[index],
          displayName: _displayNameFor(participants[index], viewModel),
        );
      },
    );
  }

  // ============ VOICE CONTROL BAR (No Video Button) ============
  Widget _buildVoiceControlBar(CallViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mic button
          _buildControlButton(
            icon: viewModel.isMicOn ? Icons.mic : Icons.mic_off,
            // isActive: viewModel.isMicOn,
            onPressed: viewModel.toggleMic,
            backgroundColor: AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),

          // Speaker button
          _buildControlButton(
            icon: viewModel.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            // isActive: viewModel.isSpeakerOn,
            onPressed: viewModel.toggleSpeaker,
            backgroundColor: AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),

          // End call button
          Container(
            width: 80,
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              color: Colors.red,
            ),
            child: IconButton(
              icon: const Icon(Icons.call_end, color: Colors.white),
              onPressed: () {
                _viewModel.endCall();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: iconColor,
        iconSize: 28,
      ),
    );
  }
}
