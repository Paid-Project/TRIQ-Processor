import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

class AddMediaWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddMediaWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        // Design se match karne ke liye
        color: AppColors.grey.withOpacity(0.5),
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(AppSizes.h12),
        child: Container(
          height: AppSizes.h50,
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.05), // Halki background
            borderRadius: BorderRadius.circular(AppSizes.h12),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                AppGaps.w8,
                Text(
                  LanguageService.get('uploadMedia'), // Key
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}