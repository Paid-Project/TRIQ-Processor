import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class ControlBar extends StatelessWidget {
  final bool isMicOn;
  final bool isVideoOn;
  final VoidCallback onMicPressed;
  final VoidCallback onVideoPressed;
  final VoidCallback onEndCallPressed;

  const ControlBar({
    super.key,
    required this.isMicOn,
    required this.isVideoOn,
    required this.onMicPressed,
    required this.onVideoPressed,
    required this.onEndCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isMicOn ? Icons.mic_none : Icons.mic_off,
            onPressed: onMicPressed,
            backgroundColor:  AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),
          _buildControlButton(
            icon: isVideoOn ? Icons.videocam_outlined : Icons.videocam_off_outlined,
            onPressed: onVideoPressed,
            backgroundColor:  AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),
          // _buildControlButton(
          //   icon: Icons.chat_bubble_outline,
          //   onPressed: () {},
          //   backgroundColor:  AppColors.primarySuperLight.withOpacity(0.1),
          //   iconColor: Colors.black,
          // ),
          // _buildControlButton(
          //   icon: Icons.more_horiz,
          //   onPressed: () {},
          //   backgroundColor:  AppColors.primarySuperLight.withOpacity(0.1),
          //   iconColor: Colors.black,
          // ),
          Container(
            width: 80,
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              color: Colors.red,
            ),
            child: IconButton(
              icon: const Icon(Icons.call_end, color: Colors.white),
              onPressed:onEndCallPressed,
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