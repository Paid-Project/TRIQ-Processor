import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/profile/help_support/help_support.vm.dart';

class HelpAndSupportView extends StatelessWidget {
  const HelpAndSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HelpAndSupportViewModel>.reactive(
      viewModelBuilder: () => HelpAndSupportViewModel(),
      builder: (context, model, child) {
        return Scaffold(backgroundColor: AppColors.cultured, appBar: _buildAppBar(context, model), body: _buildContent(context, model));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HelpAndSupportViewModel model) {
    return GradientAppBar(
      titleKey: "help_and_support",
      titleSpacing: 0,
      actions: [
        CommonElevatedButton(
          height: 23,
          label: LanguageService.get("report_a_problem"),
          onPressed: () => _showReportProblemDialog(context, model),
          backgroundColor: AppColors.white.withValues(alpha: 0.15),
          textColor: AppColors.white,
          padding: EdgeInsets.all(5),
          borderRadius: 6,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, HelpAndSupportViewModel model) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Options Section
          Container(
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(16),
            child: _buildContactOptionsSection(model),
          ),
          SizedBox(height: 30),

          // FAQ Section
          // Container(
          //   decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10)),
          //   padding: EdgeInsets.all(16),
          //   child: _buildFAQSection(),
          // ),
        ],
      ),
    );
  }

  Widget _buildContactOptionsSection(HelpAndSupportViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Option
        _buildContactOption(
          imagePath: AppImages.email,
          iconColor: AppColors.violetBlue,
          title: LanguageService.get("email"),
          subtitle: "info.triqinnovations@gmail.com",
          onTap: () => model.launchEmail(),
        ),
        SizedBox(height: 15),
        Divider(height: 0),
        SizedBox(height: 15),

        // WhatsApp Option
        _buildContactOption(
          imagePath: AppImages.whatsapp,
          iconColor: AppColors.emeraldGreen,
          title: LanguageService.get("whatsapp"),
          subtitle: LanguageService.get("chat_now"),
          hasButton: true,
          buttonText: LanguageService.get("chat_now"),
          onTap: () => model.launchWhatsApp(),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required String imagePath,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasButton = false,
    String? buttonText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Image.asset(imagePath, width: 26, height: 26, color: iconColor),
          ),
          SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.black)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textGrey)),
              ],
            ),
          ),

          // Button (for WhatsApp)
          if (hasButton && buttonText != null)
            CommonElevatedButton(
              label: buttonText,
              onPressed: onTap,
              backgroundColor: AppColors.primaryDark,
              textColor: AppColors.white,
              padding: EdgeInsets.all(7),
              borderRadius: 8,
              height: 25,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanguageService.get("faqs"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 20),
        Center(child: Text(LanguageService.get("coming_soon"), style: TextStyle(fontSize: 16, color: AppColors.textGrey))),
      ],
    );
  }

  void _showReportProblemDialog(BuildContext context, HelpAndSupportViewModel model) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close_rounded),
                ),
              ),

              // Header
              Text(LanguageService.get("report_problem"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 20),

              // Form with validation
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Title Field
                    CommonTextField(
                      controller: titleController,
                      placeholder: LanguageService.get("title"),
                      validator: CommonValidators.required(LanguageService.get("title_required")),
                    ),
                    SizedBox(height: 16),

                    // Description Field
                    CommonTextField(
                      controller: descriptionController,
                      placeholder: LanguageService.get("write_here"),
                      maxLines: 4,
                      validator: CommonValidators.required(LanguageService.get("description_required")),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: CommonElevatedButton(
                  label: LanguageService.get("submit"),
                  onPressed: () {
                    // Validate the form
                    if (formKey.currentState!.validate()) {
                      // Form is valid, submit the report
                      Get.back();
                      model.submitProblemReport(titleController.text.trim(), descriptionController.text.trim());
                    }
                    // If validation fails, CommonTextField will show error messages
                  },
                  backgroundColor: AppColors.primaryDark,
                  textColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  borderRadius: 23,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
