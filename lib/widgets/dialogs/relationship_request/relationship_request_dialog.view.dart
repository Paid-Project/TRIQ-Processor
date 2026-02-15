import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/dialogs/relationship_request/relationship_request_dialog.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../services/language.service.dart';
// import '../../country_flag/country_helper.dart';

// // Add this utility function to get country name from dial code
Country? getCountryByDialCode(String dialCode) {
  final code = dialCode.startsWith('+') ? dialCode.substring(1) : dialCode;
  try {
    return countries.firstWhere((country) => country.dialCode == code);
  } catch (_) {
    return null;
  }
}

class RelationshipRequestDialogAttributes {
  final Relationship relationship;
  final Function() onDeclineRequest;
  final Function() onAcceptRequest;
  RelationshipRequestDialogAttributes({
    required this.relationship,
    required this.onDeclineRequest,
    required this.onAcceptRequest,
  });
}

class RelationshipRequestDialog extends StatelessWidget {
  const RelationshipRequestDialog({
    super.key,
    required this.request,
    required this.completer,
  });

  final DialogRequest<RelationshipRequestDialogAttributes> request;
  final Function(DialogResponse) completer;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RelationshipRequestDialogViewModel>.reactive(
      viewModelBuilder: () => RelationshipRequestDialogViewModel(),
      onViewModelReady:
          (RelationshipRequestDialogViewModel model) => model.init(),
      builder: (
          BuildContext context,
          RelationshipRequestDialogViewModel viewModel,
          Widget? child,
          ) {
        return Dialog(
          backgroundColor: AppColors.scaffoldBackground,
          insetPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w30,
            vertical: MediaQuery.of(context).size.height / 3.8,
          ),
          child:
          viewModel.isBusy
              ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: AppColors.primary),
          )
              : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w20,
              vertical: AppSizes.h20,
            ),
            child: Column(
              children: [
                Text(
                  LanguageService.get("request_details"),
                  style: AppThemes.lightTheme.textTheme.displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: AppColors.primary,
                  thickness: AppSizes.h4,
                ),
                AppGaps.h16,
                Spacer(),
                if (request.data?.relationship != null) ...[
                  AppGaps.h8,
                  buildDetailRow(
                    context,
                    title: LanguageService.get("customer_name"),
                    value:
                    request.data!.relationship.partnerName ?? 'N/A',
                  ),
                  AppGaps.h8,
                  buildDetailRow(
                    context,
                    title: LanguageService.get("industry"),
                    value: request.data!.relationship.industry ?? 'N/A',
                  ),
                  AppGaps.h8,
                  buildDetailRow(
                    context,
                    title: LanguageService.get("email"),
                    value: request.data!.relationship.partnerEmail ?? 'N/A',
                  ),
                  AppGaps.h8,
                  // Modified this row to show country name instead of code
                  buildDetailRow(
                    context,
                    title: LanguageService.get("country"),
                    value: _getCountryNameFromCode(request.data!.relationship.partnerCountryCode),
                  ),
                  AppGaps.h8,
                  buildDetailRow(
                    context,
                    title: LanguageService.get("requested_at"),
                    value:
                    request.data!.relationship.requestedAt
                        ?.toLocal()
                        .toString()
                        .split('.')[0] ??
                        'N/A',
                  ),
                  AppGaps.h8,
                  buildDetailRow(
                    context,
                    title: LanguageService.get("status"),
                    value:
                    request.data!.relationship.status?.name
                        .toUpperCase() ??
                        'N/A',
                  ),
                  AppGaps.h16,
                ],
                Spacer(),
                Row(
                  spacing: AppSizes.w20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        request.data?.onDeclineRequest();
                        Navigator.pop(context);
                      },
                      style: AppThemes.lightTheme.textButtonTheme.style
                          ?.copyWith(
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            horizontal: AppSizes.w16,
                            vertical: AppSizes.h6,
                          ),
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: Colors.red),
                        ),
                      ),
                      child: Row(
                        spacing: AppSizes.w6,
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          Text(
                            LanguageService.get("decline"),
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        request.data?.onAcceptRequest();
                        Navigator.pop(context);
                      },
                      style: AppThemes
                          .lightTheme
                          .elevatedButtonTheme
                          .style
                          ?.copyWith(
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            horizontal: AppSizes.w16,
                            vertical: AppSizes.h6,
                          ),
                        ),
                      ),
                      child: Row(
                        spacing: AppSizes.w6,
                        children: [Icon(Icons.check), Text(
                          LanguageService.get("accept"),
                        )],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // New helper function to get country name from dial code
  String _getCountryNameFromCode(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return 'N/A';
    }

    // Try to get country name from dial code
    final country = getCountryByDialCode(countryCode);
    if (country != null) {
      return country.name;
    }

    // If not found, return the original code
    return countryCode;
  }

  Widget buildDetailRow(
      BuildContext context, {
        required String title,
        required String value,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title :',
          style: AppThemes.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: AppThemes.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}