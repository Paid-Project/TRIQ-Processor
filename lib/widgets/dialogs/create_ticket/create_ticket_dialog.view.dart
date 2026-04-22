import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/machine_supplier_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';
import '../../../services/language.service.dart';
import '../../../widgets/common_text_field.dart';
import '../../../widgets/common/inline_dropdown_form_field.dart';
import 'create_ticket_dialog.vm.dart';

class CreateTicketDialogAttributes {
  final String? initialProblem;
  final String? initialErrorCode;
  final String? initialAdditionalNotes;
  final List<File>? initialAttachments;
  final Future<void> Function(
    String problem,
    String errorCode,
    String additionalNotes,
    List<File> attachments,
    String machineId,
    String organizationId,
  )?
  onSubmit;
  final VoidCallback? onCancel;

  CreateTicketDialogAttributes({
    this.initialProblem,
    this.initialErrorCode,
    this.initialAdditionalNotes,
    this.initialAttachments,
    this.onSubmit,
    this.onCancel,
  });
}

class CreateTicketDialogWidget extends StatelessWidget {
  final CreateTicketDialogAttributes attributes;
  final List<MachineSupplier> machineSupplierData;

  const CreateTicketDialogWidget({
    super.key,
    required this.attributes,
    this.machineSupplierData = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CreateTicketDialog(
      request: DialogRequest<CreateTicketDialogAttributes>(data: attributes),
      completer: (response) {
        // Handle the response if needed
      },
      machineSupplierData: machineSupplierData,
    );
  }
}

class CreateTicketDialog extends StatelessWidget {
  final DialogRequest<CreateTicketDialogAttributes> request;
  final Function(DialogResponse) completer;
  final List<MachineSupplier> machineSupplierData;

  const CreateTicketDialog({
    super.key,
    required this.request,
    required this.completer,
    required this.machineSupplierData,
  });

  @override
  Widget build(BuildContext context1) {
    return ViewModelBuilder<CreateTicketDialogViewModel>.reactive(
      viewModelBuilder: () => CreateTicketDialogViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(request.data!),
      builder: (context1, model, child) {
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 40),
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v23),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.v23),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context1).size.width - 28,
              maxHeight: MediaQuery.of(context1).size.height * 0.55,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(AppSizes.v16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.v16),
                      topRight: Radius.circular(AppSizes.v16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.get('filled_details'),
                              style: Theme.of(
                                context1,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LanguageService.get(
                                'enter_support_request_details',
                              ),
                              style: Theme.of(context1).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            context1,
                          ).pop(DialogResponse(confirmed: false));
                          model.onCancel();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSizes.v16,
                      right: AppSizes.v16,
                    ),
                    child: Form(
                      key: model.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (machineSupplierData.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 5),
                                _buildDropdownFormField(
                                  context1,
                                  value: model.selectedOrganizationId,
                                  label: LanguageService.get('select_supplier'),
                                  items: _getUniqueOrganizationItems(
                                    machineSupplierData,
                                  ),
                                  onChanged: (value) {
                                    AppLogger.info('Selected organization changed');
                                    model.selectedOrganizationId = value;
                                    model.selectedMachineId =
                                        null; // Reset machine selection when organization changes
                                    model.formKey.currentState?.validate();
                                    model.notifyListeners();
                                  },
                                  validator: (value) {
                                    return value == null
                                        ? LanguageService.get(
                                          'please_select_supplier',
                                        )
                                        : null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                            if (model.selectedOrganizationId != null)
                              Column(
                                children: [
                                  const SizedBox(height: 5),
                                  _buildDropdownFormField(
                                    context1,
                                    value: model.selectedMachineId,
                                    label: LanguageService.get('select_machine'),
                                    items: _getUniqueMachineItems(
                                      machineSupplierData,
                                      model.selectedOrganizationId!,
                                    ),
                                    onChanged: (value) {
                                      AppLogger.info('Selected machine changed');
                                      model.formKey.currentState?.validate();
                                      model.selectedMachineId = value?.toUpperCase();

                                      model.notifyListeners();
                                      // model.selectedMachineId = value;
                                    },
                                    validator:
                                        (value) =>
                                            value == null
                                                ? LanguageService.get(
                                                  'please_select_machine',
                                                )
                                                : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),

                          // Problem Description
                          CommonTextField(
                            controller: model.problemController,
                            placeholder: LanguageService.get(
                              'write_problem_here',
                            ),
                            maxLines: 4,
                            validator: CommonValidators.required(
                              LanguageService.get(
                                'please_describe_the_problem',
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Error Code
                          CommonTextField(
                            controller: model.errorCodeController,
                            placeholder: LanguageService.get('error_code'),
                            keyboardType: TextInputType.number,
                            validator: CommonValidators.required(
                              '${LanguageService.get('error_code')} ${LanguageService.get('required')}',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          //
                          // Text(
                          //   LanguageService.get('camera'),
                          //   style: Theme.of(
                          //     context1,
                          //   ).textTheme.titleLarge?.copyWith(
                          //     color: AppColors.black,
                          //     fontWeight: FontWeight.w400,
                          //   ),
                          // ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     GestureDetector(
                          //       onTap: () => model.pickMediaFromCamera(),
                          //       child: DottedBorder(
                          //         color:
                          //         model.attachmentsError != null
                          //             ? AppColors.error
                          //             : AppColors.lightGrey,
                          //         strokeWidth: 1.5,
                          //         dashPattern: [8, 4],
                          //         borderType: BorderType.RRect,
                          //         radius: Radius.circular(12),
                          //         child: Container(
                          //           width: double.infinity,
                          //           padding: EdgeInsets.all(AppSizes.v16),
                          //           child: Row(
                          //             mainAxisAlignment:
                          //             MainAxisAlignment.center,
                          //             children: [
                          //               Icon(
                          //                 Icons.add_rounded,
                          //                 size: 24,
                          //                 color:
                          //                 model.attachmentsError != null
                          //                     ? AppColors.error
                          //                     : AppColors.black,
                          //               ),
                          //               const SizedBox(width: 8),
                          //               Text(
                          //                 LanguageService.get('camera'),
                          //                 style: TextStyle(
                          //                   color:
                          //                   model.attachmentsError != null
                          //                       ? AppColors.error
                          //                       : AppColors.black,
                          //                   fontSize: 16,
                          //                   fontWeight: FontWeight.w500,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     if (model.attachmentsError != null) ...[
                          //       const SizedBox(height: 8),
                          //       Text(
                          //         model.attachmentsError!,
                          //         style: TextStyle(
                          //           color: AppColors.error,
                          //           fontSize: 12,
                          //         ),
                          //       ),
                          //     ],
                          //   ],
                          // ),
                          // const SizedBox(height: 16),
                          Text(
                            LanguageService.get('upload_media'),

                            style: Theme.of(context1).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          // const SizedBox(height: 8),
                          // Text(
                          //   LanguageService.get('camera'),
                          //   style: Theme.of(
                          //     context1,
                          //   ).textTheme.titleLarge?.copyWith(
                          //     color: AppColors.black,
                          //     fontWeight: FontWeight.w400,
                          //   ),
                          // ),
                          // Upload Media Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IconButton(onPressed: () {
                              //
                              // }, icon:Icon(Icons.camera_alt)),
                              _buildAttachmentMenuItem(
                                icon: AppImages.gallery,
                                label: "",
                                color: AppColors.bluebackground,
                                onTap: () {
                                  model.pickMedia();
                                },
                              ),
                              _buildAttachmentMenuItem(
                                icon: AppImages.camera,
                                label: '',
                                color: AppColors.greenbackground,
                                onTap: () {
                                  model.pickMediaFromCamera();
                                },
                              ),
                              // IconButton(onPressed: () {
                              //   model.pickMedia();
                              // }, icon:Icon(Icons.perm_media)),
                              // GestureDetector(
                              //   onTap: () => model.pickMedia(),
                              //   child: DottedBorder(
                              //     color:
                              //         model.attachmentsError != null
                              //             ? AppColors.error
                              //             : AppColors.lightGrey,
                              //     strokeWidth: 1.5,
                              //     dashPattern: [8, 4],
                              //     borderType: BorderType.RRect,
                              //     radius: Radius.circular(12),
                              //     child: Container(
                              //       width: double.infinity,
                              //       padding: EdgeInsets.all(AppSizes.v16),
                              //       child: Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         children: [
                              //           Icon(
                              //             Icons.add_rounded,
                              //             size: 24,
                              //             color:
                              //                 model.attachmentsError != null
                              //                     ? AppColors.error
                              //                     : AppColors.black,
                              //           ),
                              //           const SizedBox(width: 8),
                              //           Text(
                              //             LanguageService.get('upload_media'),
                              //             style: TextStyle(
                              //               color:
                              //                   model.attachmentsError != null
                              //                       ? AppColors.error
                              //                       : AppColors.black,
                              //               fontSize: 16,
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              if (model.attachmentsError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  model.attachmentsError!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Show selected attachments
                          if (model.attachments.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppSizes.v12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${LanguageService.get('selected_files')} (${model.attachments.length})',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...model.attachments.asMap().entries.map<
                                    Widget
                                  >((entry) {
                                    final index = entry.key;
                                    final file = entry.value;
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 4),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              file.path.split('/').last,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap:
                                                () => model.removeAttachment(
                                                  index,
                                                ),
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Additional Notes
                          CommonTextField(
                            controller: model.additionalNotesController,
                            label: LanguageService.get('additional_notes'),
                            placeholder: LanguageService.get(
                              'additional_notes',
                            ),
                            maxLines: 3,
                            // validator: CommonValidators.required(
                            //   '${LanguageService.get('additional_notes')} ${LanguageService.get('required')}',
                            // ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.v16,
                    right: AppSizes.v16,
                    bottom: AppSizes.v16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              context1,
                            ).pop(DialogResponse(confirmed: false));
                            model.onCancel();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                            ),
                          ),
                          child: Text(
                            LanguageService.get('cancel'),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              model.isLoading
                                  ? null
                                  : () async {
                                    if (model.validateForm()) {
                                      await model.onSubmit(context1);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,

                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                            ),
                          ),
                          child:
                              model.isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    LanguageService.get('submit_ticket'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
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

  List<Map<String, String>> _getUniqueOrganizationItems(
    List<MachineSupplier> machineSupplierData,
  ) {
    final Map<String, String> uniqueItems = {};

    for (final supplier in machineSupplierData) {
      final orgId = supplier.customer?.organization?.id;
      final orgName = "${supplier.customer?.organization?.fullName}";

      if (orgId != null && orgId.isNotEmpty && orgName.isNotEmpty) {
        uniqueItems[orgId] = orgName;
      }
    }

    return uniqueItems.entries
        .map((entry) => {"value": entry.key, "display": entry.value})
        .toList();
  }

  List<Map<String, String>> _getUniqueMachineItems(
      List<MachineSupplier> machineSupplierData,
      String organizationId,
      ) {
    final Map<String, String> uniqueItems = {};

    try {
      final selectedSupplier = machineSupplierData.firstWhere(
            (m) => m.customer?.organization?.id == organizationId,
      );

      if (selectedSupplier.customer?.machines != null) {
        for (final machine in selectedSupplier.customer!.machines!) {
          final machineId = machine.machine?.id;

          // 🔥 CHANGE HERE (uppercase full display)
          final machineName =
              "${(machine.machine?.machineName ?? 'Unnamed Machine').toUpperCase()} "
              "(${(machine.machine?.modelNumber ?? '').toUpperCase()})";

          if (machineId != null &&
              machineId.isNotEmpty &&
              machineName.isNotEmpty) {

            // 🔥 OPTIONAL: value bhi uppercase
            uniqueItems[machineId.toUpperCase()] = machineName;
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error finding machines for organization: $e');
    }

    return uniqueItems.entries
        .map((entry) => {
      "value": entry.key,
      "display": entry.value,
    })
        .toList();
  }
  Widget _buildAttachmentMenuItem({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w12,
          vertical: AppSizes.h12,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.v10),
              ),
              child: Center(
                child: Image.asset(icon, width: 18, height: 18, color: color),
              ),
            ),
            // SizedBox(width: AppSizes.w12),
            // Text(
            //   label,
            //   style: TextStyle(
            //     color: AppColors.textPrimary,
            //     fontSize: AppSizes.f14,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFormField(
    BuildContext context, {
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return InlineDropdownFormField(
      value: value,
      label: label,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
