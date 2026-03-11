import 'package:flutter/material.dart';

import '../../../resources/app_resources/app_resources.dart';

class VoiceRecordActionButton extends StatelessWidget {
  const VoiceRecordActionButton({
    super.key,
    required this.showSendButton,
    required this.isBusy,
    required this.isRecording,
    this.onSend,
    this.onRecordStart,
    this.onRecordUpdate,
    this.onRecordEnd,
  });

  final bool showSendButton;
  final bool isBusy;
  final bool isRecording;
  final VoidCallback? onSend;
  final VoidCallback? onRecordStart;
  final void Function(LongPressMoveUpdateDetails details)? onRecordUpdate;
  final VoidCallback? onRecordEnd;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Widget child;

    if (isBusy) {
      backgroundColor = AppColors.primaryDark;
      child = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (showSendButton) {
      backgroundColor = AppColors.primaryDark;
      child = const Icon(
        Icons.send_rounded,
        color: Colors.white,
        size: 22,
      );
    } else {
      backgroundColor = isRecording ? AppColors.error : AppColors.primaryDark;
      child = const Icon(
        Icons.mic_rounded,
        color: Colors.white,
        size: 24,
      );
    }

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: child),
    );

    if (isBusy) {
      return IgnorePointer(child: button);
    }

    if (showSendButton) {
      return GestureDetector(onTap: onSend, child: button);
    }

    return GestureDetector(
      onLongPressStart: (_) => onRecordStart?.call(),
      onLongPressMoveUpdate: onRecordUpdate,
      onLongPressEnd: (_) => onRecordEnd?.call(),
      child: button,
    );
  }
}
