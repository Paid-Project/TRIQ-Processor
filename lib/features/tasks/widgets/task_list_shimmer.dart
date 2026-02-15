import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../resources/app_resources/app_resources.dart';

class TaskListShimmer extends StatelessWidget {
  const TaskListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.scaffoldBackground, // SAHI
      highlightColor: AppColors.grey.withOpacity(0.1), // SAHI
      child: ListView.builder(
        itemCount: 5,
        padding:  EdgeInsets.symmetric(
          horizontal: AppSizes.w16, // SAHI
          vertical: AppSizes.h16, // SAHI
        ),
        itemBuilder: (context, index) {
          return Container(
            padding:  EdgeInsets.all(AppSizes.h16), // SAHI
            margin:  EdgeInsets.only(bottom: AppSizes.h12), // SAHI
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSizes.h12), // SAHI
              //boxShadow: [AppTheme.mildBoxShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title and Priority
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 200, height: 16), // Title
                    _buildShimmerBox(width: 50, height: 16), // Priority
                  ],
                ),
                AppGaps.h8, // SAHI
                Divider(color: AppColors.lightGrey.withOpacity(0.5)), // SAHI
                AppGaps.h8, // SAHI

                // Row 2: Machine and Assigned To
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(width: 80, height: 12),
                          AppGaps.h4, // SAHI
                          _buildShimmerBox(width: 120, height: 14),
                        ],
                      ),
                    ),
                    AppGaps.w16, // SAHI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(width: 80, height: 12),
                          AppGaps.h4, // SAHI
                          _buildShimmerBox(width: 120, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white, // SAHI
        borderRadius: BorderRadius.circular(AppSizes.h4), // SAHI
      ),
    );
  }
}