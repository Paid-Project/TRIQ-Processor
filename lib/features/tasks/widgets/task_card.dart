import 'package:flutter/material.dart';
import 'package:manager/core/models/task.dart'; // Naya API Task Model
import 'package:manager/features/tasks/task_list/task_list.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task; // Model update kiya
  final VoidCallback? onTap;
  final TaskListViewModel? viewModel;

  const TaskCardWidget({
    Key? key,
    required this.task,
    this.onTap,
    this.viewModel,
  }) : super(key: key);

  // API se aa rahe "High", "Medium", "Low" strings ke liye colors
  Color _getPriorityTagColor() {
    switch (task.priority.toLowerCase()) {
      case 'low':
        return AppColors.softGreen;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.red;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.yellow;
      default:
        return AppColors.grey;
    }
  }

  // Card ka background color
  Color _getPriorityBackgroundColor() {
    switch (task.priority.toLowerCase()) {
      case 'low':
        return AppColors.teaGreen; // (F1F8E9 ke kareeb)
      case 'medium':
        return AppColors.peachPuff; // (FFF8E1 ke kareeb)
      case 'high':
        return AppColors.mistyRose; // (FCE4EC ke kareeb)
      default:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.h16),
        padding: EdgeInsets.all(AppSizes.h16),
        decoration: BoxDecoration(
          color: _getPriorityBackgroundColor(),
          borderRadius: BorderRadius.circular(AppSizes.h12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(),
            AppGaps.h12,
            Text(
              task.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppGaps.h16,
            Divider(height: 1, color: AppColors.lightGrey),
            AppGaps.h16,
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            task.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppGaps.w8,
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.w10,
            vertical: AppSizes.h4,
          ),
          decoration: BoxDecoration(
            color: _getPriorityTagColor(),
            borderRadius: BorderRadius.circular(AppSizes.h8),
          ),
          child: Text(
            task.priority, // API se priority string
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        AppGaps.w4,
        // if(viewModel?.selectedTaskTypeIndex == 0 )
        // const Icon(Icons.more_vert, color: AppColors.textGrey),
      ],
    );
  }

  Widget _buildBottomRow() {
    // TODO: API response me 'assignee' (naam) nahi hai,
    // 'assignTo' (ID) hai. Yahan ID dikhegi.
    // 'isAssignedBy' bhi nahi hai.
    // Hum 'tab' ke hisaab se logic laga sakte hain.

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguageService.get('remainingTime'),
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            AppGaps.h4,
            Text(
              task.getRemainingTime(), // Helper function se formatted time
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              LanguageService.get('assignTo'), // Simple 'Assign To'
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            AppGaps.h4,
            Text(
              task.assignTo.name ?? "NO Name", // Yahan ID dikhegi
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
