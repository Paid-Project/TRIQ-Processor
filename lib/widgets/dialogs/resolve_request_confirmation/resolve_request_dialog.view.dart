import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../resources/app_resources/app_resources.dart';
import 'resolve_request_dialog.vm.dart';

class ResolveRequestDialogAttributes {
  final String title;
  final String description;
  final String cancelText;
  final String confirmText;
  final Function(ResolveRequestResponse)? onCancelPressed;
  final Function(ResolveRequestResponse)? onConfirmPressed;
  final String? initialRemarks;
  final bool isRequired;

  ResolveRequestDialogAttributes({
    required this.title,
    required this.description,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancelPressed,
    this.onConfirmPressed,
    this.initialRemarks = '',
    this.isRequired = false,
  });
}

class ResolveRequestResponse {
  final bool confirmed;
  final String remarks;

  ResolveRequestResponse({
    required this.confirmed,
    required this.remarks,
  });
}

class ResolveRequestDialog extends StatelessWidget {
  final DialogRequest<ResolveRequestDialogAttributes> request;
  final Function(DialogResponse) completer;

  const ResolveRequestDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResolveRequestDialogViewModel>.reactive(
      viewModelBuilder: () => ResolveRequestDialogViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(request.data!),
      builder: (context, model, child) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v16),
        ),
        title: Text(
          model.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.h16),
            if(getUser().organizationType == OrganizationType.manufacturer)
            TextField(
              controller: model.remarksController,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                labelText: model.isRequired ? LanguageService.get("remarks") : LanguageService.get("remarks"),
                hintText: LanguageService.get("add_remarks_here"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w16,
                  vertical: AppSizes.h12,
                ),
              ),
              onChanged: (value) => model.updateRemarks(value),
            ),
            // if (model.isRequired && model.hasError)
            //   Padding(
            //     padding: EdgeInsets.only(top: AppSizes.h8, left: AppSizes.w8),
            //     child: Text(
            //       'Please enter remarks before confirming',
            //       style: TextStyle(
            //         color: Colors.red,
            //         fontSize: 12,
            //       ),
            //     ),
            //   ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final response = ResolveRequestResponse(
                confirmed: false,
                remarks: model.remarksController.text,
              );

              Navigator.of(context).pop(DialogResponse(
                confirmed: false,
                data: response,
              ));

              model.onCancel(response);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray,
            ),
            child: Text(
              model.cancelText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed:
            getUser().organizationType == OrganizationType.manufacturer && model.isSubmitDisabled?null:
                () {
              if(getUser().organizationType == OrganizationType.manufacturer){
                if(model.isSubmitDisabled) {
                  return;
                }
                  if (model.isRequired && model.remarksController.text.trim().isEmpty) {
                    model.setError(true);
                    return;
                  }
              }

              final response = ResolveRequestResponse(
                confirmed: true,
                remarks: model.remarksController.text,
              );

              Navigator.of(context).pop(DialogResponse(
                confirmed: true,
                data: response,
              ));

              model.onConfirm(response);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.w16,
                vertical: AppSizes.h8,
              ),
            ),
            child: Text(
              model.confirmText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}