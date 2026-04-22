import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/machine_supplier_model.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import '../../../widgets/common/inline_dropdown_form_field.dart';
import 'select_maintenance_type_dialog.vm.dart';

class SelectMaintenanceTypeDialog extends StatelessWidget {
  final SelectMaintenanceTypeDialogAttributes? attributes;
  final bool isWarrantyActive;
  final List<MachineSupplier> machineSupplierData;

  const SelectMaintenanceTypeDialog({
    super.key,
    this.attributes,
    this.isWarrantyActive = true,
    this.machineSupplierData = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SelectMaintenanceTypeDialogViewModel>.reactive(
      viewModelBuilder:
          () =>
              SelectMaintenanceTypeDialogViewModel()
                ..init(isGeneralCheckUpDisabled: !isWarrantyActive),
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
              maxWidth: MediaQuery.of(context).size.width - 28,
              maxHeight: MediaQuery.of(context).size.height * 0.55,
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
                              LanguageService.get('select_maintenance_type'),
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LanguageService.get(
                                'select_any_one_option_at_a_time',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium
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
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSizes.v16,
                      right: AppSizes.v16,
                    ),
                    child: Form(
                      key: model.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (machineSupplierData.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 5),
                                Builder(
                                  builder: (context) {
                                    final allSupplierItems =
                                        machineSupplierData
                                            .map((e) {
                                              // Safely get the id and name
                                              final id =
                                                  e.customer?.organization?.id;
                                              final name =
                                                  e
                                                      .customer
                                                      ?.organization
                                                      ?.fullName;
                                              return {'id': id, 'name': name};
                                            })
                                            // 2. Filter out any items that have a null or empty ID
                                            .where((item) {
                                              final id = item['id'];
                                              return id != null &&
                                                  (id).isNotEmpty;
                                            })
                                            .toList();

                                    // 3. De-duplicate the list
                                    final uniqueSupplierItems =
                                        <Map<String, String>>[];
                                    final seenValues =
                                        <
                                          String
                                        >{}; // This Set will track seen IDs

                                    for (final item in allSupplierItems) {
                                      final value = item['id'] as String;

                                      // .add() returns true ONLY if the value was NOT already in the set
                                      if (seenValues.add(value)) {
                                        // This is a new, unique ID, so we add it to our final list
                                        uniqueSupplierItems.add({
                                          "value": value,
                                          "display":
                                              item['name'] ??
                                              "Unnamed Supplier",
                                        });
                                      }
                                    }

                                    return _buildDropdownFormField(
                                      context1,
                                      value: model.selectedOrganizationId,
                                      label: LanguageService.get(
                                        'select_supplier',
                                      ),
                                      items:
                                          uniqueSupplierItems, // <-- Use the de-duplicated list
                                      onChanged: (value) {
                                        print(
                                          "selected organization ===> $value",
                                        );
                                        model.selectedOrganizationId = value;
                                        model.formKey.currentState?.validate();
                                        model.notifyListeners();
                                      },
                                      validator:
                                          (value) =>
                                              value == null
                                                  ? LanguageService.get(
                                                    'please_select_supplier',
                                                  )
                                                  : null,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          if (model.selectedOrganizationId != null)
                            Column(
                              children: [
                                const SizedBox(height: 5),
                                Builder(
                                  builder: (context) {
                                    final int supplierIndex =
                                        machineSupplierData.indexWhere(
                                          (m) =>
                                              m.customer?.organization?.id ==
                                              model.selectedOrganizationId,
                                        );
                                    List<MachineElement> machineList =
                                        (supplierIndex != -1)
                                            ? (machineSupplierData[supplierIndex]
                                                    .customer
                                                    ?.machines) ??
                                                []
                                            : [];

                                    return machineList.isNotEmpty
                                        ? _buildDropdownFormField(
                                          context,
                                          value: model.selectedMachineId,
                                          label: LanguageService.get(
                                            'select_machine',
                                          ),
                                      items: machineList
                                          .where(
                                            (e) =>
                                        e.machine?.id != null &&
                                            (e.machine!.id ?? '').isNotEmpty,
                                      )
                                          .map(
                                            (e) => {
                                          "value": e.machine!.id!,
                                          "display":
                                          "${(e.machine?.machineName ?? 'Unnamed Machine').toUpperCase()} (${(e.machine?.modelNumber ?? '').toUpperCase()})",
                                        },
                                      )
                                          .toList(),
                                          onChanged: (value) {
                                            print("selected machine ===> $value");
                                            model.formKey.currentState?.validate();
                                            model.selectedMachineId = value?.toUpperCase();  // uppercase here
                                            model.notifyListeners();
                                          },
                                          validator:
                                              (value) =>
                                                  value == null
                                                      ? LanguageService.get(
                                                        'please_select_machine',
                                                      )
                                                      : null,
                                        )
                                        : SizedBox();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Maintenance Type Options
                          _buildMaintenanceOption(
                            context,
                            model,
                            'General Check Up',
                            LanguageService.get('general_check_up'),
                            AppColors.primary,
                            isEnabled: isWarrantyActive,
                          ),
                          SizedBox(height: 10),
                          _buildMaintenanceOption(
                            context,
                            model,
                            'Full Machine Service',
                            LanguageService.get('full_machine_service'),
                            AppColors.primary,
                            isEnabled: true,
                          ),

                          const SizedBox(height: 32),

                          // Action Buttons
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSizes.v16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context1,
                                      ).pop(DialogResponse(confirmed: false));
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.lightGrey,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
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
                                        model.selectedType != null &&
                                                !model.isLoading
                                            ? () async {
                                              if (model.validateForm()) {
                                                await model.submit(
                                                  model.selectedType!,
                                                  (maintenanceType) async {
                                                    if (context1.mounted) {
                                                      Navigator.of(
                                                        context1,
                                                      ).pop(
                                                        DialogResponse(
                                                          confirmed: true,
                                                        ),
                                                      );
                                                    }

                                                    await attributes?.onSubmit?.call(
                                                      maintenanceType,
                                                      model.selectedOrganizationId ?? "",
                                                      (model.selectedMachineId ?? "").toUpperCase(),  // double safety
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          model.selectedType != null &&
                                                  !model.isLoading
                                              ? AppColors.primary
                                              : AppColors.lightGrey,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
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
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.white),
                                              ),
                                            )
                                            : Text(
                                              LanguageService.get(
                                                'submit_ticket',
                                              ),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceOption(
    BuildContext context,
    SelectMaintenanceTypeDialogViewModel model,
    String value,
    String label,
    Color color, {
    bool isEnabled = true,
  }) {
    final isSelected = model.selectedType == value;

    return GestureDetector(
      onTap: isEnabled ? () => model.selectType(value) : null,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : isEnabled
                  ? AppColors.white
                  : AppColors.lightGrey.withValues(alpha: 0.3),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : isEnabled
                    ? AppColors.lightGrey
                    : AppColors.lightGrey.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: model.selectedType,
              onChanged:
                  isEnabled
                      ? (String? newValue) {
                        if (newValue != null) {
                          model.selectType(newValue);
                        }
                      }
                      : null,
              activeColor: color,
              fillColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return color;
                }
                return isEnabled ? AppColors.whisperGray : AppColors.lightGrey;
              }),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isSelected
                          ? color
                          : isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (!isEnabled)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  LanguageService.get('out_of_warranty'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
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

class SelectMaintenanceTypeDialogAttributes {
  final Future<void> Function(
    String maintenanceType,
    String organizationId,
    String machineId,
  )?
  onSubmit;
  final VoidCallback? onCancel;

  SelectMaintenanceTypeDialogAttributes({this.onSubmit, this.onCancel});
}
