import 'package:flutter/material.dart';

import '../../../resources/app_resources/app_resources.dart';

class VoiceRecordingBar extends StatelessWidget {
  const VoiceRecordingBar({
    super.key,
    required this.duration,
    required this.cancelProgress,
    required this.shouldCancel,
  });

  final Duration duration;
  final double cancelProgress;
  final bool shouldCancel;

  @override
  Widget build(BuildContext context) {
    final activeColor = shouldCancel ? AppColors.error : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.28),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              color: activeColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shouldCancel ? 'Release to cancel' : 'Slide left to cancel',
                  style: TextStyle(
                    color: shouldCancel ? AppColors.error : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: cancelProgress,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    backgroundColor: AppColors.lightGrey.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.keyboard_double_arrow_left_rounded,
            color: activeColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
