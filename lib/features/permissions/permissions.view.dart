import 'package:flutter/material.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/permissions/permissions.vm.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PermissionsViewModel>.reactive(
      viewModelBuilder: () => PermissionsViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w30,
                  vertical: AppSizes.h20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: AppSizes.w100,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: AppSizes.h20),
                  Text(
                    LanguageService.get("app_permissions"),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.h10),
                  Text(
                    LanguageService.get("please_enable_permissions"),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.v14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.h30),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Notification Permission
                          _buildPermissionCard(
                            context: context,
                            title: LanguageService.get("notifications"),
                            description: LanguageService.get("notifications_description"),
                            icon: Icons.notifications_active,
                            isEnabled: model.notificationPermission,
                            onToggle: () => model.requestNotificationPermission(),
                          ),
                          SizedBox(height: AppSizes.h15),

                          // Camera Permission
                          _buildPermissionCard(
                            context: context,
                            title: LanguageService.get("camera"),
                            description: LanguageService.get("take_photos_and_scan"),
                            icon: Icons.camera_alt,
                            isEnabled: model.cameraPermission,
                            onToggle: () => model.requestCameraPermission(),
                          ),
                          SizedBox(height: AppSizes.h15),

                          // Microphone Permission
                          _buildPermissionCard(
                            context: context,
                            title: LanguageService.get("microphone"),
                            description: LanguageService.get("record_audio_and_voice_messages"),
                            icon: Icons.mic,
                            isEnabled: model.microphonePermission,
                            onToggle: () => model.requestMicrophonePermission(),
                          ),
                          SizedBox(height: AppSizes.h15),

                          // Photos Permission
                          _buildPermissionCard(
                            context: context,
                            title: LanguageService.get("photos"),
                            description: LanguageService.get("access_your_photo_library"),
                            icon: Icons.photo_library,
                            isEnabled: model.photosPermission,
                            onToggle: () => model.requestPhotosPermission(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.h20),
                  ElevatedButton(
                    onPressed: () => model.navigateToStage(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, AppSizes.h50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                      ),
                    ),
                    child: Text(
                      LanguageService.get("continue"),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.h10),
                  Text(
                    model.allPermissionsInteracted
                        ? LanguageService.get("all_permissions_granted")
                        : LanguageService.get("please_interact_with_all_permissions_to_continue"),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: model.allPermissionsInteracted
                          ? Colors.green
                          : AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w20,
          vertical: AppSizes.h15
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: AppSizes.w24,
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSizes.h6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.primary,
            thumbColor: WidgetStatePropertyAll(Colors.white),
            inactiveTrackColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}