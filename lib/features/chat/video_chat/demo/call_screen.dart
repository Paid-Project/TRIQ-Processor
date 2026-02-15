// lib/features/chat/video_chat/video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:manager/features/chat/video_chat/demo/call_view_model.dart';
import 'package:manager/features/chat/video_chat/widgets/control_bar.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_grid.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_tile.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/features/chat/video_chat/widgets/floating_call_service.dart';
import 'package:provider/provider.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomName;
  final String token;
  final bool isVoice;

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
    _viewModel = CallViewModel()
      ..initCall(
        roomName: widget.roomName,
        token: widget.token,
        isVoice: widget.isVoice,
      );
  }

  @override
  void dispose() {
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
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
            _floatingService.removeFloatingCall();
            viewModel.disconnect();
            if (Navigator.canPop(context)) Navigator.pop(context);
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
            child: IconButton(
              icon: const Icon(Icons.group_outlined),
              onPressed: () {},
            ),
          ),
          Column(
            children: [
              Text(
                widget.isVoice ? 'Voice Call' : 'Video Call',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            child: IconButton(
              icon: const Icon(Icons.picture_in_picture_alt),
              onPressed: _minimizeToFloating,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLayout(CallViewModel viewModel) {
    final mainParticipantState = viewModel.mainParticipant;
    final otherParticipants = viewModel.otherParticipants;

    if (viewModel.participants.isEmpty) {
      return Center(
        child: Text(
          viewModel.isConnecting
              ? 'Connecting...'
              : 'Waiting for participants...',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: mainParticipantState != null
              ? ParticipantTile(participantState: mainParticipantState)
              : Container(
            decoration: BoxDecoration(
              color: AppColors.primarySuperLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Main view')),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: ParticipantGrid(participants: otherParticipants),
        ),
      ],
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
                _floatingService.removeFloatingCall();
                viewModel.disconnect();
                if (Navigator.canPop(context)) Navigator.pop(context);
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