import 'package:flutter/material.dart';

import '../../resources/app_resources/app_resources.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  gradient: AppGradients.primaryGradient,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColors.scaffoldBackground),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
