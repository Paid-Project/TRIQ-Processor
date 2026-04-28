import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:manager/features/chat/video_chat/video_call/call_view_model.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:provider/provider.dart';

import '../../../../resources/multimedia_resources/resources.dart';

class ParticipantTile extends StatelessWidget {
  final CallParticipant participantState;
  final String? displayName;

  const ParticipantTile({
    super.key,
    required this.participantState,
    this.displayName,
  });

  String _participantName(BuildContext context) {
    final p = participantState.participant;
    final room = context.read<CallViewModel>().room;
    final isLocal = p is LocalParticipant || p == room?.localParticipant;
    if (isLocal) {
      return 'You';
    }

    // Use explicitly passed displayName first
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (p.name.isNotEmpty) {
      return p.name;
    }
    if (p.identity.isNotEmpty) {
      return p.identity;
    }
    return 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: participantState,
      child: Consumer<CallParticipant>(
        builder: (context, state, _) {
          bool isVideoAvailable =
              state.videoTrack != null && !state.videoTrack!.muted;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              color: AppColors.primarySuperLight.withOpacity(0.1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video ya Placeholder
                  if (isVideoAvailable)
                    VideoTrackRenderer(
                      state.videoTrack!,
                      fit: VideoViewFit.cover,
                    )
                  else
                    // Center mein 60x60 placeholder
                    Center(child: _buildPlaceholder()),

                  // Bottom info bar
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isVideoAvailable
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                _participantName(context),
                                style: TextStyle(
                                  color:
                                      isVideoAvailable
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (state.isMuted)
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color:
                                    isVideoAvailable
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mic_off,
                                color:
                                    isVideoAvailable
                                        ? Colors.white
                                        : Colors.black54,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    // SizedBox se fixed 60x60 size
    return SizedBox(
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            AppImages.team_default,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
