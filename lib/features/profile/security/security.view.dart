import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'change_password/change_password.view.dart';
import 'security.vm.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SecurityViewModel>.reactive(
      viewModelBuilder: () => SecurityViewModel(),
      onViewModelReady: (SecurityViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, SecurityViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.scaffoldBackground,
          body: Container(
            color: AppColors.scaffoldBackground,
            child: SingleChildScrollView(
              child: _buildMenuItems(context, model),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "security", titleSpacing: 0);
  }

  Widget _buildMenuItems(BuildContext context, SecurityViewModel model) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            imagePath: AppImages.key,
            title: LanguageService.get("change_password"),
            iconColor: AppColors.bluebackground,
            onTap: () => Get.to(() => const ChangePasswordView()),
            animationDelay: 400.ms,
          ),
          _buildDivider(),
          // _buildMenuItem(
          //   imagePath: AppImages.fingerprint,
          //   title: LanguageService.get("fingerprint_face_id_login"),
          //   iconColor: AppColors.walletBackground,
          //   onTap: () {},
          //   animationDelay: 500.ms,
          //   isLast: true,
          //   hasToggle: true,
          //   toggleValue: model.isBiometricEnabled,
          //   onToggleChanged: (value) => model.toggleBiometric(value),
          // ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? imagePath,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    required Duration animationDelay,
    bool isLast = false,
    bool hasToggle = false,
    bool? toggleValue,
    ValueChanged<bool>? onToggleChanged,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isLast ? 16 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    imagePath != null
                        ? Image.asset(
                          imagePath,
                          width: 24,
                          height: 24,
                          color: iconColor,
                          fit: BoxFit.contain,
                        )
                        : Icon(icon!, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            if (hasToggle)
              Switch(
                value: toggleValue ?? false,
                onChanged: onToggleChanged,
                activeColor: AppColors.primary,
                inactiveThumbColor: AppColors.gray,
                inactiveTrackColor: AppColors.violetBlue.withValues(alpha: 0.1),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashRadius: 0,
              )
            else
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySuperLight.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.textGrey.withValues(alpha: 0.1),
                  ),
                ),
                child: Image.asset(
                  AppImages.arrowRight,
                  width: 16,
                  height: 16,
                  color: AppColors.textGrey,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 100.ms, delay: animationDelay);
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFEEEEEE),
    );
  }
}
