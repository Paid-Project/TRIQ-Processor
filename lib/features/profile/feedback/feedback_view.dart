import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import '../../../widgets/common_app_bar.dart';
import '../../../widgets/common_elevated_button.dart';
import '../../../widgets/common_text_field.dart';
import 'feedback.vm.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedbackViewModel>.reactive(
      viewModelBuilder: () => FeedbackViewModel(),
      disposeViewModel: true,
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: _buildAppBar(context),
          bottomNavigationBar: _buildSaveButton(context, model),
          body: _buildContent(context, model),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "send_feedback");
  }

  Widget _buildContent(BuildContext context, FeedbackViewModel model) {
    return Container(
      color: AppColors.white,
      height: double.maxFinite,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15.h),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 17, 12, 17),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.lightGrey, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Text
                Text(
                  LanguageService.get("From"),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(width: 10.w),

                // Right Text
                Text(
                  model.currentUserEmail.isNotEmpty
                      ? model.currentUserEmail
                      : LanguageService.get("feedback_email"),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Description Field
          CommonTextField(
            controller: model.descriptionController,
            placeholder: LanguageService.get("feedback_hint"),
            maxLines: 4,
            textStyle: TextStyle(fontSize: 14),
            validator: CommonValidators.required(
              LanguageService.get("feedback_required"),
            ),
          ),
          // Spacer(),
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: AppColors.progressBlue.withOpacity(0.04), // background
          //     borderRadius: BorderRadius.circular(13),
          //     border: Border.all(color: AppColors.lightGrey, width: 1),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       SvgPicture.asset(
          //         'assets/svg/system_log.svg',
          //         width: 40,
          //         height: 40,
          //       ),
          //       SizedBox(width: 10),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: const [
          //           Text(
          //             "System Logs",
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.black,
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //           SizedBox(height: 4),
          //           Text(
          //             "View",
          //             style: TextStyle(fontSize: 10, color: Color(0xFF003382)),
          //           ),
          //         ],
          //       ),
          //       Spacer(),
          //       SvgPicture.asset(
          //         'assets/svg/done_check_icon.svg',
          //         width: 30,
          //         height: 30,
          //       ),
          //     ],
          //   ),
          // ),
          Row(
            children: [
              Checkbox(
                value: model.includeSystemLogs,
                onChanged: (bool? value) {
                  model.toggleSystemLogs(value ?? false);
                },
              ),
              Text(
                LanguageService.get("feedback_confirmation"),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, FeedbackViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: CommonElevatedButton(
        height: 48,
        label: LanguageService.get('send_feedback'),
        onPressed: () async {
          await model.sendFeedback();
        },
        backgroundColor: AppColors.primaryDark,
        textColor: AppColors.white,
        borderRadius: 45,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
