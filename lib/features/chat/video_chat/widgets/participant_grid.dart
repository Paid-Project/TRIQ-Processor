import 'package:flutter/material.dart';
import 'package:manager/features/chat/video_chat/video_call/call_view_model.dart';
import 'package:manager/features/chat/video_chat/widgets/participant_tile.dart';

class ParticipantGrid extends StatelessWidget {
  // <-- FIX 1: Use the new class name 'CallParticipant'.
  final List<CallParticipant> participants;

  const ParticipantGrid({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return ParticipantTile(participantState: participants[index]);
      },
    );
  }
}
