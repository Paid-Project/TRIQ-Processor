import 'package:flutter/material.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import 'add_machine.vm.dart';

class AddMachineViewAttributes {
  final String id;
  final String? processorId;
  final bool isAssignedToPartner;
  AddMachineViewAttributes({this.id = '', this.isAssignedToPartner = false, this.processorId});

  factory AddMachineViewAttributes.fromMap(Map<String, String> map) {
    return AddMachineViewAttributes(
      id: map['id'] as String,
      isAssignedToPartner: bool.parse(map['isAssignedToPartner']??'false'),
      processorId: map['processorId'],
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'isAssignedToPartner': isAssignedToPartner.toString(),
      'processorId': processorId??'',
    };
  }
}

class AddMachineView extends StatelessWidget {
  const AddMachineView({super.key, required this.attributes});

  final AddMachineViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMachineViewModel>.reactive(
      viewModelBuilder: () => AddMachineViewModel(),
      onViewModelReady: (AddMachineViewModel model) => model.init(attributes),
      disposeViewModel: true,
      builder: (BuildContext context, AddMachineViewModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: AppColors.primary,
            backgroundColor: AppColors.primary,
            title: Text(
              model.isEditing ? LanguageService.get("edit_machine") : LanguageService.get("add_machine"),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: Theme.of(context).iconTheme.copyWith(color: AppColors.white),
          ),
          body: model.isBusy
              ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
              : Form(
            key: model.formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.w16),
              child: Column(
                children: [
                  // Machine Details Card
                  _buildCard(
                    context,
                    title: LanguageService.get("machine_overview_details"),
                    icon: Icons.precision_manufacturing,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactTextField(
                              context,
                              controller: model.machineNameController,
                              label: LanguageService.get("machine_name"),
                              icon: Icons.label_outline,
                              validator: (value) => value?.isEmpty ?? true
                                  ? LanguageService.get("please_enter_machine_name")
                                  : null,
                            ),
                          ),
                          SizedBox(width: AppSizes.w12),
                          Expanded(
                            child: _buildCompactTextField(
                              context,
                              controller: model.modelNumberController,
                              label: LanguageService.get("model_number"),
                              icon: Icons.numbers,
                              validator: (value) => value?.isEmpty ?? true
                                  ? LanguageService.get("please_enter_model_number")
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      _buildCompactDropdownField(
                        context,
                        label: LanguageService.get("type"),
                        icon: Icons.category_outlined,
                        value: model.selectedMachineType,
                        items: MachineType.values.map((type) {
                          return DropdownMenuItem<MachineType>(
                            value: type,
                            child: Text(type.toString()),
                          );
                        }).toList(),
                        onChanged: model.updateMachineType,
                      ),
                    ],
                  ),

                  // Processing Size Card
                  _buildCard(
                    context,
                    title: LanguageService.get("processing_dimensions"),
                    icon: Icons.straighten,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${LanguageService.get("minimum_size")} (mm)",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${LanguageService.get("maximum_area")} (mm²)",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.h8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildCompactTextField(
                                    context,
                                    controller: model.heightController,
                                    label: LanguageService.get("height"),
                                    icon: Icons.height,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return LanguageService.get("required");
                                      }
                                      if (double.tryParse(value!) == null) {
                                        return LanguageService.get("invalid_number");
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: AppSizes.w8),
                                Expanded(
                                  child: _buildCompactTextField(
                                    context,
                                    controller: model.widthController,
                                    label: LanguageService.get("width"),
                                    icon: Icons.width_normal,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return LanguageService.get("required");
                                      }
                                      if (double.tryParse(value!) == null) {
                                        return LanguageService.get("invalid_number");
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSizes.w12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildCompactTextField(
                                    context,
                                    controller: model.maximumAreaController,
                                    label: LanguageService.get("max"),
                                    icon: Icons.expand,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return LanguageService.get("required");
                                      }
                                      if (double.tryParse(value!) == null) {
                                        return LanguageService.get("invalid_number");
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: AppSizes.w8),
                                Expanded(
                                  child: _buildCompactTextField(
                                    context,
                                    controller: model.minimumAreaController,
                                    label: LanguageService.get("min"),
                                    icon: Icons.compress,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return LanguageService.get("required");
                                      }
                                      if (double.tryParse(value!) == null) {
                                        return LanguageService.get("invalid_number");
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildCompactTextField(
                        context,
                        controller: model.powerController,
                        label: "${LanguageService.get('power_consumption')} (kW)",
                        icon: Icons.flash_on,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return LanguageService.get("required");
                          }
                          if (double.tryParse(value!) == null) {
                            return LanguageService.get("invalid_number");
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  // Warranty & Purchase Info (if assigned to partner)
                  if (attributes.isAssignedToPartner)
                    _buildCard(
                      context,
                      title: LanguageService.get("warranty_purchase_info"),
                      icon: Icons.security,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactDateField(
                                context,
                                controller: model.warrantyStartDateController,
                                label: LanguageService.get("warranty_start"),
                                icon: Icons.start,
                                onTap: () => model.selectWarrantyStartDate(context),
                              ),
                            ),
                            SizedBox(width: AppSizes.w12),
                            Expanded(
                              child: _buildCompactDateField(
                                context,
                                controller: model.warrantyExpiryDateController,
                                label: LanguageService.get("warranty_expiry"),
                                icon: Icons.event_busy,
                                onTap: () => model.selectWarrantyExpiryDate(context),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactDateField(
                                context,
                                controller: model.purchaseDateController,
                                label: LanguageService.get("purchase_date"),
                                icon: Icons.shopping_cart,
                                onTap: () => model.selectPurchaseDate(context),
                              ),
                            ),
                            SizedBox(width: AppSizes.w12),
                            Expanded(
                              child: _buildCompactDateField(
                                context,
                                controller: model.installationDateController,
                                label: LanguageService.get("installation_date"),
                                icon: Icons.build,
                                onTap: () => model.selectInstallationDate(context),
                              ),
                            ),
                          ],
                        ),
                        _buildCompactTextField(
                          context,
                          controller: model.invoiceNoController,
                          label: LanguageService.get("invoice_no"),
                          icon: Icons.receipt,
                          validator: (value) => value?.isEmpty ?? true
                              ? LanguageService.get("please_enter_invoice_no")
                              : null,
                        ),
                      ],
                    ),

                  // Additional Information Card
                  if (model.additionalInfoSections.isNotEmpty)
                    _buildCard(
                      context,
                      title: LanguageService.get("additional_information"),
                      icon: Icons.info_outline,
                      children: _buildAdditionalInfoSections(context, model),
                    ),

                  // Add More Button
                  Container(
                    margin: EdgeInsets.symmetric(vertical: AppSizes.h8),
                    child: OutlinedButton.icon(
                      onPressed: model.addNewInfoSection,
                      icon: Icon(Icons.add, size: 20),
                      label: Text(LanguageService.get("add_more")),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        padding: EdgeInsets.symmetric(
                            vertical: AppSizes.h12,
                            horizontal: AppSizes.w20
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.h20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: model.onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.v12),
                        ),
                      ),
                      child: model.isSaving
                          ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        model.isEditing
                            ? LanguageService.get("save_changes")
                            : LanguageService.get("save"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.h20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.w8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.v8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        String? Function(String?)? validator,
        TextInputType? keyboardType,
        bool readOnly = false,
        int maxLines = 1,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        textInputAction: TextInputAction.next,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w12,
            vertical: AppSizes.h10,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCompactDateField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required Function() onTap,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h12),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
              prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
              suffixIcon: Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v8),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.w12,
                vertical: AppSizes.h10,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) => value?.isEmpty ?? true
                ? "${LanguageService.get("please_select")} $label"
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDropdownField(
      BuildContext context, {
        required String label,
        required IconData icon,
        required dynamic value,
        required List<DropdownMenuItem<dynamic>> items,
        required void Function(dynamic) onChanged,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h12),
      child: DropdownButtonFormField<dynamic>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w12,
            vertical: AppSizes.h10,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) => value == null
            ? "${LanguageService.get("please_select")} $label"
            : null,
      ),
    );
  }

  List<Widget> _buildAdditionalInfoSections(
      BuildContext context,
      AddMachineViewModel model,
      ) {
    List<Widget> sections = [];

    for (int i = 0; i < model.additionalInfoSections.length; i++) {
      final section = model.additionalInfoSections[i];

      sections.add(
        Container(
          margin: EdgeInsets.only(bottom: AppSizes.h12),
          padding: EdgeInsets.all(AppSizes.w12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppSizes.v8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${LanguageService.get("additional_info")} ${i + 1}",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: () => model.removeInfoSection(i),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              _buildCompactTextField(
                context,
                controller: section.titleController,
                label: LanguageService.get("heading"),
                icon: Icons.title,
                validator: (value) => value?.isEmpty ?? true
                    ? LanguageService.get("please_enter_heading")
                    : null,
              ),
              _buildCompactTextField(
                context,
                controller: section.descriptionController,
                label: LanguageService.get("description"),
                icon: Icons.description,
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true
                    ? LanguageService.get("please_enter_description")
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    return sections;
  }
}