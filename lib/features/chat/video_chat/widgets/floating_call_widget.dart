// lib/widgets/floating_call_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:manager/features/chat/video_chat/video_call/call_view_model.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_grid.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_tile.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:provider/provider.dart';
import 'control_bar.dart';

class FloatingCallService {
  static final FloatingCallService _instance = FloatingCallService._internal();
  factory FloatingCallService() => _instance;
  FloatingCallService._internal();

  OverlayEntry? _overlayEntry;
  CallViewModel? _activeCallViewModel;
  bool _isFloating = false;

  // Store call info for returning to full screen
  String? _roomName;
  String? _token;
  bool _isVoice = false;

  // Chat screen params
  String? _contactName;
  String? _contactNumber;
  String? _contactInitials;
  String? _roomId;
  String? _ticketId;
  String? _ticketStatus;
  String? _userRole;
  String? _flag;

  bool get isFloating => _isFloating;
  CallViewModel? get activeCallViewModel => _activeCallViewModel;

  void showFloatingCall({
    required BuildContext context,
    required CallViewModel viewModel,
    required bool isVoice,
    String? roomName,
    String? token,
    String? contactName,
    String? contactNumber,
    String? contactInitials,
    String? roomId,
    String? ticketId,
    String? ticketStatus,
    String? userRole,
    String? flag,
  }) {
    if (_overlayEntry != null) {
      removeFloatingCall();
    }

    _activeCallViewModel = viewModel;
    _isFloating = true;
    _roomName = roomName;
    _token = token;
    _isVoice = isVoice;
    _contactName = contactName;
    _contactNumber = contactNumber;
    _contactInitials = contactInitials;
    _roomId = roomId;
    _ticketId = ticketId;
    _ticketStatus = ticketStatus;
    _userRole = userRole;
    _flag = flag;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => FloatingCallWidget(
            viewModel: viewModel,
            isVoice: isVoice,
            onTap: () => _returnToFullScreen(context),
            onClose: () {
              viewModel.disconnect();
              removeFloatingCall();
            },
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _returnToFullScreen(BuildContext context) {
    // Remove floating first
    final viewModel = _activeCallViewModel;
    final isVoice = _isVoice;

    removeFloatingCall();

    if (viewModel != null) {
      // Navigate to full screen with existing viewModel
      Get.to(
        () => VideoCallScreenFromFloating(
          viewModel: viewModel,
          isVoice: isVoice,
          roomName: _roomName ?? '',
          token: _token ?? '',
          contactName: _contactName,
          contactNumber: _contactNumber,
          contactInitials: _contactInitials,
          roomId: _roomId,
          ticketId: _ticketId,
          ticketStatus: _ticketStatus,
          userRole: _userRole,
          flag: _flag,
        ),
      );
    }
  }

  void removeFloatingCall() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isFloating = false;
    // Don't clear viewModel here as it might be used for return
  }

  void clearAll() {
    removeFloatingCall();
    _activeCallViewModel = null;
    _roomName = null;
    _token = null;
    _isVoice = false;
  }
}

// Floating Widget with animations
class FloatingCallWidget extends StatefulWidget {
  final CallViewModel viewModel;
  final bool isVoice;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const FloatingCallWidget({
    super.key,
    required this.viewModel,
    required this.isVoice,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<FloatingCallWidget> createState() => _FloatingCallWidgetState();
}

class _FloatingCallWidgetState extends State<FloatingCallWidget>
    with SingleTickerProviderStateMixin {
  double _xPosition = 20;
  double _yPosition = 100;
  final double _width = 120;
  final double _height = 160;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _snapToEdge(double screenWidth) {
    setState(() {
      // Snap to nearest edge
      if (_xPosition + _width / 2 < screenWidth / 2) {
        _xPosition = 10;
      } else {
        _xPosition = screenWidth - _width - 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      left: _xPosition,
      top: _yPosition,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onPanStart: (_) {
            setState(() => _isDragging = true);
          },
          onPanUpdate: (details) {
            setState(() {
              _xPosition += details.delta.dx;
              _yPosition += details.delta.dy;
              _xPosition = _xPosition.clamp(0, screenWidth - _width);
              _yPosition = _yPosition.clamp(50, screenHeight - _height - 100);
            });
          },
          onPanEnd: (_) {
            setState(() => _isDragging = false);
            _snapToEdge(screenWidth);
          },
          onTap: widget.onTap,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(0.4),
            child: Container(
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      widget.isVoice
                          ? [const Color(0xFF1E3A5F), const Color(0xFF0D2137)]
                          : [Colors.grey[850]!, Colors.grey[900]!],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    _buildContent(),

                    // Expand indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.open_in_full,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),

                    // Bottom info
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mute indicators
                            ListenableBuilder(
                              listenable: widget.viewModel,
                              builder: (context, _) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!widget.viewModel.isMicOn)
                                      _buildStatusIcon(
                                        Icons.mic_off,
                                        Colors.red,
                                      ),
                                    if (!widget.isVoice &&
                                        !widget.viewModel.isVideoOn)
                                      _buildStatusIcon(
                                        Icons.videocam_off,
                                        Colors.red,
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            // Duration
                            ListenableBuilder(
                              listenable: widget.viewModel,
                              builder: (context, _) {
                                return Text(
                                  widget.viewModel.callDuration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 10),
    );
  }

  Widget _buildContent() {
    if (widget.isVoice) {
      return _buildVoiceContent();
    } else {
      return _buildVideoContent();
    }
  }

  Widget _buildVoiceContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_in_talk,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isVoice ? 'Voice' : 'Video',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final mainParticipant = widget.viewModel.mainParticipant;

        if (mainParticipant?.videoTrack != null && widget.viewModel.isVideoOn) {
          return VideoTrackRenderer(
            mainParticipant!.videoTrack!,
            fit: VideoViewFit.cover,
          );
        } else {
          return _buildVoiceContent();
        }
      },
    );
  }
}

// Screen to return from floating
class VideoCallScreenFromFloating extends StatefulWidget {
  final CallViewModel viewModel;
  final bool isVoice;
  final String roomName;
  final String token;
  final String? contactName;
  final String? contactNumber;
  final String? contactInitials;
  final String? roomId;
  final String? ticketId;
  final String? ticketStatus;
  final String? userRole;
  final String? flag;

  const VideoCallScreenFromFloating({
    super.key,
    required this.viewModel,
    required this.isVoice,
    required this.roomName,
    required this.token,
    this.contactName,
    this.contactNumber,
    this.contactInitials,
    this.roomId,
    this.ticketId,
    this.ticketStatus,
    this.userRole,
    this.flag,
  });

  @override
  State<VideoCallScreenFromFloating> createState() =>
      _VideoCallScreenFromFloatingState();
}

class _VideoCallScreenFromFloatingState
    extends State<VideoCallScreenFromFloating> {
  final FloatingCallService _floatingService = FloatingCallService();

  @override
  void dispose() {
    if (!_floatingService.isFloating) {
      widget.viewModel.disconnect();
      widget.viewModel.dispose();
      _floatingService.clearAll();
    }
    super.dispose();
  }

  void _minimizeToFloating() {
    _floatingService.showFloatingCall(
      context: context,
      viewModel: widget.viewModel,
      isVoice: widget.isVoice,
      roomName: widget.roomName,
      token: widget.token,
      contactName: widget.contactName,
      contactNumber: widget.contactNumber,
      contactInitials: widget.contactInitials,
      roomId: widget.roomId,
      ticketId: widget.ticketId,
      ticketStatus: widget.ticketStatus,
      userRole: widget.userRole,
      flag: widget.flag,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Scaffold(
        backgroundColor:
            widget.isVoice
                ? AppColors.primaryDark
                : AppColors.scaffoldBackground,
        body: SafeArea(
          child: Consumer<CallViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isConnecting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.isVoice) {
                return _buildVoiceCallUI(viewModel);
              } else {
                return _buildVideoCallUI(viewModel);
              }
            },
          ),
        ),
      ),
    );
  }

  // ============ VOICE CALL UI ============
  Widget _buildVoiceCallUI(CallViewModel viewModel) {
    return Column(
      children: [
        _buildVoiceTopBar(viewModel),
        Expanded(child: _buildVoiceContent(viewModel)),
        _buildVoiceControlBar(viewModel),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildVoiceTopBar(CallViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              viewModel.disconnect();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'Voice Call',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.callDuration,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          // Minimize button for voice call
          IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white),
            onPressed: _minimizeToFloating,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceContent(CallViewModel viewModel) {
    final participants = viewModel.participants;

    if (participants.isEmpty) {
      return const Center(
        child: Text('Connecting...', style: TextStyle(color: Colors.white)),
      );
    }

    if (participants.length <= 2) {
      final remoteParticipant = participants.firstWhere(
        (p) => p.participant != viewModel.room?.localParticipant,
        orElse: () => participants.first,
      );

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildParticipantAvatar(remoteParticipant, size: 120),
            const SizedBox(height: 24),
            Text(
              remoteParticipant.participant.identity ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  remoteParticipant.isMuted ? Icons.mic_off : Icons.mic,
                  color: remoteParticipant.isMuted ? Colors.red : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  remoteParticipant.isMuted ? 'Muted' : 'Speaking',
                  style: TextStyle(
                    color:
                        remoteParticipant.isMuted
                            ? Colors.white54
                            : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          '${participants.length} Participants',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return _buildVoiceParticipantCard(participant, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceParticipantCard(
    CallParticipant participant,
    CallViewModel viewModel,
  ) {
    final isLocal = participant.participant == viewModel.room?.localParticipant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildParticipantAvatar(participant, size: 60),
        const SizedBox(height: 8),
        Text(
          isLocal ? 'You' : (participant.participant.identity ?? 'Unknown'),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Icon(
          participant.isMuted ? Icons.mic_off : Icons.mic,
          color: participant.isMuted ? Colors.red : Colors.green,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildParticipantAvatar(
    CallParticipant participant, {
    double size = 80,
  }) {
    final isSpeaking = !participant.isMuted;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSpeaking ? Colors.greenAccent : Colors.transparent,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: size / 2 - 3,
        backgroundColor: Colors.grey.shade700,
        child: Text(
          _getInitials(participant.participant.identity ?? 'U'),
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildVoiceControlBar(CallViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildVoiceControlButton(
            icon: viewModel.isMicOn ? Icons.mic : Icons.mic_off,
            label: viewModel.isMicOn ? 'Mute' : 'Unmute',
            isActive: viewModel.isMicOn,
            onPressed: viewModel.toggleMic,
          ),
          _buildVoiceControlButton(
            icon: viewModel.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: 'Speaker',
            isActive: viewModel.isSpeakerOn,
            onPressed: viewModel.toggleSpeaker,
          ),
          _buildEndCallButton(viewModel),
        ],
      ),
    );
  }

  Widget _buildVoiceControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white24,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive ? AppColors.primaryDark : Colors.white,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildEndCallButton(CallViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end, color: Colors.white),
            onPressed: () {
              // Remove floating if exists
              _floatingService.removeFloatingCall();
              viewModel.disconnect();
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text('End', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // ============ VIDEO CALL UI ============
  Widget _buildVideoCallUI(CallViewModel viewModel) {
    return Column(
      children: [
        _buildTopBar(viewModel),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCallLayout(viewModel),
          ),
        ),
        ControlBar(
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
              const Text(
                'Video Call',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: _minimizeToFloating, // <-- Floating minimize
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
          child:
              mainParticipantState != null
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
}
