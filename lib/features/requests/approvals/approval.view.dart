import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import 'approval.vm.dart';

class ApprovalView extends StatelessWidget {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ApprovalViewModel>.reactive(
      viewModelBuilder: () => ApprovalViewModel(),
      onViewModelReady: (ApprovalViewModel model) => model.init(),
      onDispose: (ApprovalViewModel model) => model.dispose(),
      builder: (BuildContext context, ApprovalViewModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: AppColors.transparent,
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.v20),
              color: AppColors.white,
            ),
            margin: EdgeInsets.symmetric(horizontal: AppSizes.w20),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w16,
              vertical: AppSizes.h20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSizes.h10,
              children: [
                RichText(
                  text: TextSpan(
                    text: "",
                    style: Theme.of(context).textTheme.displayMedium,
                    children: [
                      TextSpan(
                        text: LanguageService.get("approvals_requests"),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Text(
                  LanguageService.get("manage_leave_requests"),
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.v14,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w10,
                    vertical: AppSizes.h10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.v14),
                  ),
                  child: Column(
                    children: [
                      buildProfileOption(
                        context,
                        title: LanguageService.get("apply_for_leave"),
                        onTap: () {},
                        showDivider: true,
                      ),
                      buildProfileOption(
                        context,
                        title: LanguageService.get("apply_for_advance_pay"),
                        onTap: () {},
                        showDivider: true,
                      ),
                      buildProfileOption(
                        context,
                        title: LanguageService.get("apply_for_machine_request"),
                        onTap: () {},
                        showDivider: true,
                      ),
                      buildProfileOption(
                        context,
                        title: LanguageService.get("apply_for"),
                        onTap: () {},
                        showDivider: false,
                        showTrailing: false,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: LanguageService.get("enter_here"),
                        ),
                        maxLength: 150,
                        minLines: 4,
                        maxLines: 4,
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? LanguageService.get("please_enter_organization_name")
                                    : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    bool showDivider = false,
        bool showTrailing = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            trailing: showTrailing?Icon(Icons.arrow_forward_ios, color: AppColors.primary):null,
          ),
          if (showDivider)
            Divider(
              height: AppSizes.h3,
              color: AppColors.gray,
              indent: AppSizes.w20,
              endIndent: AppSizes.w20,
            ),
        ],
      ),
    );
  }
}
