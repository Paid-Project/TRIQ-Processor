import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

/// Profile Page Shimmer Loading Widget
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeaderShimmer(),
            const SizedBox(height: 20),
            _buildMenuItemsShimmer(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Profile completion card shimmer
          _buildCompletionCardShimmer(),
          const SizedBox(height: 15),
          // Profile info shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image shimmer
              _buildShimmerBox(60, 60, isCircle: true),
              const SizedBox(width: 16),
              // Name and email shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(100, 14, radius: 4),
                    const SizedBox(height: 8),
                    _buildShimmerBox(150, 12, radius: 4),
                    const SizedBox(height: 8),
                    _buildShimmerBox(80, 12, radius: 4),
                  ],
                ),
              ),
              // QR code shimmer
              _buildShimmerBox(48, 48, radius: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(120, 14, radius: 4),
                const SizedBox(height: 8),
                _buildShimmerBox(180, 12, radius: 4),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildShimmerBox(60, 60, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildMenuItemsShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          6,
          (index) => Column(
            children: [
              _buildMenuItemShimmer(),
              if (index < 5) _buildDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildShimmerBox(40, 40, radius: 10),
          const SizedBox(width: 16),
          Expanded(
            child: _buildShimmerBox(100, 14, radius: 4),
          ),
          _buildShimmerBox(32, 32, radius: 10),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFEEEEEE),
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    double radius = 8,
    bool isCircle = false,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isCircle ? null : BorderRadius.circular(radius),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}
