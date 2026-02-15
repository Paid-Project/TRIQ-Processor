import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../resources/app_resources/app_resources.dart';
import 'ticket_closed.vm.dart';

class TicketClosedDialogAttributes {
  final String title;
  final String description;
  final String cancelText;
  final String confirmText;
  final Function()? onCancelPressed;
  final Function()? onConfirmPressed;

  TicketClosedDialogAttributes({
    required this.title,
    required this.description,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancelPressed,
    this.onConfirmPressed,
  });
}

class TicketClosedDialog extends StatelessWidget {
  final DialogRequest<TicketClosedDialogAttributes> request;
  final Function(DialogResponse) completer;

  const TicketClosedDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketClosedDialogViewModel>.reactive(
      viewModelBuilder: () => TicketClosedDialogViewModel(),
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
        content: Text(
          model.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).pop(DialogResponse(confirmed: false));
          //     model.onCancel();
          //   },
          //   style: TextButton.styleFrom(
          //     foregroundColor: AppColors.gray,
          //   ),
          //   child: Text(
          //     model.cancelText,
          //     style: TextStyle(
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(DialogResponse(confirmed: true));
              model.onConfirm();
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
              LanguageService.get("close"),
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