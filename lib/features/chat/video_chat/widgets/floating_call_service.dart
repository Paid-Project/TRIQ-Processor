// lib/features/chat/video_chat/widgets/floating_call_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:manager/features/chat/video_chat/demo/call_view_model.dart';
import 'package:manager/features/chat/video_chat/widgets/control_bar.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_grid.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_tile.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:provider/provider.dart';

class FloatingCallService {
  static final FloatingCallService _instance = FloatingCallService._internal();
  factory FloatingCallService() => _instance;
  FloatingCallService._internal();

  OverlayEntry? _overlayEntry;
  CallViewModel? _activeCallViewModel;
  bool _isFloating = false;

  String? _roomName;
  String? _token;
  bool _isVoice = false;

  bool get isFloating => _isFloating;
  CallViewModel? get activeCallViewModel => _activeCallViewModel;

  void showFloatingCall({
    required BuildContext context,
    required CallViewModel viewModel,
    required bool isVoice,
    String? roomName,
    String? token,
  }) {
    if (_overlayEntry != null) {
      removeFloatingCall();
    }

    _activeCallViewModel = viewModel;
    _isFloating = true;
    _roomName = roomName;
    _token = token;
    _isVoice = isVoice;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => FloatingCallWidget(
        viewModel: viewModel,
        isVoice: isVoice,
        onTap: () => _openFullScreen(),
        onClose: () {
          viewModel.disconnect();
          removeFloatingCall();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _openFullScreen() {
    if (_activeCallViewModel == null) return;

    final viewModel = _activeCallViewModel!;
    final isVoice = _isVoice;
    final roomName = _roomName ?? '';
    final token = _token ?? '';

    removeFloatingCall();

    Get.to(
          () => VideoCallScreenFromFloating(
        viewModel: viewModel,
        isVoice: isVoice,
        roomName: roomName,
        token: token,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  void removeFloatingCall() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isFloating = false;
  }

  void clearAll() {
    removeFloatingCall();
    _activeCallViewModel = null;
    _roomName = null;
    _token = null;
    _isVoice = false;
  }
}

// ============ FLOATING WIDGET ============
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
          onPanStart: (_) => setState(() => _isDragging = true),
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
                  colors: [Colors.grey[850]!, Colors.grey[900]!],
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

                    // Expand icon
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
                            ListenableBuilder(
                              listenable: widget.viewModel,
                              builder: (context, _) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!widget.viewModel.isMicOn)
                                      _buildStatusIcon(Icons.mic_off, Colors.red),
                                    if (!widget.isVoice && !widget.viewModel.isVideoOn)
                                      _buildStatusIcon(Icons.videocam_off, Colors.red),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final mainParticipant = widget.viewModel.mainParticipant;

        if (!widget.isVoice &&
            mainParticipant?.videoTrack != null &&
            widget.viewModel.isVideoOn) {
          return VideoTrackRenderer(
            mainParticipant!.videoTrack!,
            fit: VideoViewFit.cover,
          );
        }

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
                child: Icon(
                  widget.isVoice ? Icons.phone_in_talk : Icons.videocam,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isVoice ? 'Voice Call' : 'Video Call',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============ FULL SCREEN FROM FLOATING ============
// Uses EXACT SAME UI as VideoCallScreen
class VideoCallScreenFromFloating extends StatefulWidget {
  final CallViewModel viewModel;
  final bool isVoice;
  final String roomName;
  final String token;

  const VideoCallScreenFromFloating({
    super.key,
    required this.viewModel,
    required this.isVoice,
    required this.roomName,
    required this.token,
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
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Consumer<CallViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.room == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call_end, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Call ended'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return _buildCallUI(viewModel);
            },
          ),
        ),
      ),
    );
  }

  // ============ SAME UI AS VideoCallScreen ============
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
        widget.isVoice
            ? _buildVoiceControlBar(viewModel)
            : ControlBar(
          isMicOn: viewModel.isMicOn,
          isVideoOn: viewModel.isVideoOn,
          onMicPressed: viewModel.toggleMic,
          onVideoPressed: viewModel.toggleVideo,
          onEndCallPressed: () {
            _floatingService.clearAll();
            viewModel.disconnect();
            Navigator.pop(context);
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
      return const Center(
        child: Text('Waiting for participants...'),
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

  // ============ VOICE CONTROL BAR (Same as VideoCallScreen) ============
  Widget _buildVoiceControlBar(CallViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mic button
          _buildControlButton(
            icon: viewModel.isMicOn ? Icons.mic : Icons.mic_off,
            onPressed: viewModel.toggleMic,
            backgroundColor: AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),

          // Speaker button
          _buildControlButton(
            icon: viewModel.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
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
                _floatingService.clearAll();
                viewModel.disconnect();
                Navigator.pop(context);
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