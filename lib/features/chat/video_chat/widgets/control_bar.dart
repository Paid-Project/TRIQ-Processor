import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';

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
            svgIcon: isMicOn ? AppImages.vc_microphone : null,
            icon: isMicOn ? null : Icons.mic_off,
            onPressed: onMicPressed,
            backgroundColor: AppColors.primarySuperLight.withOpacity(0.1),
            iconColor: Colors.black,
          ),
          _buildControlButton(
            svgIcon: isVideoOn ? AppImages.vc_video : null,
            icon: isVideoOn ? null : Icons.videocam_off_outlined,
            onPressed: onVideoPressed,
            backgroundColor: AppColors.primarySuperLight.withOpacity(0.1),
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
              onPressed: onEndCallPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    String? svgIcon,
    IconData? icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              svgIcon != null
                  ? SvgPicture.asset(
                    svgIcon,
                    color: iconColor,
                    height: 28,
                    width: 28,
                  )
                  : Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }
}
