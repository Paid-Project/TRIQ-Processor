import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'change_password.vm.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        ChangePasswordViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPasswordImage(),
                const SizedBox(height: 15),
                _buildPasswordForm(context, model),
                const SizedBox(height: 38),
                _buildSaveButton(context, model),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "change_password", titleSpacing: 0);
  }

  Widget _buildPasswordImage() {
    return Center(
      child: Image.asset(
        AppImages.changePassword,
        height: 240,
        width: 240,
        fit: BoxFit.contain,
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildPasswordForm(
    BuildContext context,
    ChangePasswordViewModel model,
  ) {
    return Form(
      key: model.formKey,
      child: Column(
        children: [
          CommonTextField(
                placeholder: LanguageService.get("old_password"),
                controller: model.oldPasswordController,
                obscureText: !model.isOldPasswordVisible,
                contentPadding: EdgeInsets.all(12),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LanguageService.get("please_enter_old_password");
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Image.asset(
                    model.isOldPasswordVisible
                        ? AppImages.eyeOpen
                        : AppImages.eyeClose,
                    width: 22,
                    height: 22,
                    color: AppColors.textGrey,
                  ),
                  onPressed: model.toggleOldPasswordVisibility,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .slideX(begin: 0.2),
          const SizedBox(height: 16),
          CommonTextField(
                placeholder: LanguageService.get("new_password"),
                controller: model.newPasswordController,
                obscureText: !model.isNewPasswordVisible,
                contentPadding: EdgeInsets.all(12),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LanguageService.get("please_enter_new_password");
                  }
                  if (value.length < 6) {
                    return LanguageService.get(
                      "password_must_be_at_least_6_characters",
                    );
                  }
                  if (value == model.oldPasswordController.text) {
                    return LanguageService.get(
                      "new_password_must_be_different_from_old",
                    );
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Image.asset(
                    model.isNewPasswordVisible
                        ? AppImages.eyeOpen
                        : AppImages.eyeClose,
                    width: 22,
                    height: 22,
                    color: AppColors.textGrey,
                  ),
                  onPressed: model.toggleNewPasswordVisibility,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 300.ms)
              .slideX(begin: 0.2),
          const SizedBox(height: 16),
          CommonTextField(
                placeholder: LanguageService.get("confirm_password"),
                controller: model.confirmPasswordController,
                obscureText: !model.isConfirmPasswordVisible,
                contentPadding: EdgeInsets.all(12),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LanguageService.get("please_confirm_password");
                  }
                  if (value != model.newPasswordController.text) {
                    return LanguageService.get("passwords_do_not_match");
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Image.asset(
                    model.isConfirmPasswordVisible
                        ? AppImages.eyeOpen
                        : AppImages.eyeClose,
                    width: 22,
                    height: 22,
                    color: AppColors.textGrey,
                  ),
                  onPressed: model.toggleConfirmPasswordVisibility,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms, delay: 400.ms)
              .slideX(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ChangePasswordViewModel model) {
    return SizedBox(
      width: double.infinity,
      child: CommonElevatedButton(
        label: LanguageService.get("save_password"),
        onPressed: model.isLoading ? null : () => model.changePassword(context),
        backgroundColor: AppColors.primary,
        textColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 45,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        isLoading: model.isLoading,
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(begin: 0.3);
  }
}
