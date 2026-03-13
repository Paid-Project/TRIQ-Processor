import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import 'add_partner.vm.dart';

class AddPartnerViewAttributes {
  final String? id;
  final bool hasPasswordField;
  final bool hasReadOnly;
  final bool isNewProcessor;
  AddPartnerViewAttributes({
    required this.id,
    this.hasPasswordField = false,
    this.hasReadOnly = true,
    this.isNewProcessor = true,
  });
}

class AddPartnerView extends StatelessWidget {
  const AddPartnerView({super.key, required this.attributes});

  final AddPartnerViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddPartnerViewModel>.reactive(
      viewModelBuilder: () => AddPartnerViewModel(),
      onViewModelReady: (AddPartnerViewModel model) => model.init(attributes),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        AddPartnerViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildCustomAppBar(context),
          body: SafeArea(
            child:
                model.isBusy
                    ? Center(child: CircularProgressIndicator())
                    : _buildPartnerDetailsForm(context, model),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        attributes.isNewProcessor ?  LanguageService.get("add_customer_entry") : LanguageService.get("add_machine"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPartnerDetailsForm(
    BuildContext context,
    AddPartnerViewModel model,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h10,
      ),
      child: Form(
        key: model.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            _buildSectionHeader(context, LanguageService.get("personal_info")),
            SizedBox(height: AppSizes.h10),
            _buildPersonalInfoFields(model),

            // Machines Section
            SizedBox(height: AppSizes.h20),
            // it should be only for manufacturer
            if (getUser().organizationType == OrganizationType.manufacturer)
              _buildSectionHeader(context, LanguageService.get("link_machine_to_customer")),
            SizedBox(height: AppSizes.h10),
            _buildMachinesSection(context, model),

            _buildSaveButton(context, model),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPersonalInfoFields(AddPartnerViewModel model) {
    return Column(
      children: [
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
              initialValue: model.name,
              label: "Name",
              validator:
                  (value) =>
                      value?.isEmpty == true ? LanguageService.get("please_enter_name") : null,
            )
            : _buildEditableTextField(
              controller: model.nameController,
              label: LanguageService.get("name"),
              validator:
                  (value) =>
                      value?.isEmpty == true
                          ? LanguageService.get("please_enter_name")
                          : null,
            ),
        SizedBox(height: AppSizes.h10),
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
              initialValue: model.phoneNumber,
              label: LanguageService.get("phone_number"),
              keyboardType: TextInputType.phone,
              validator:
                  (value) =>
                      value?.isEmpty == true
                          ? LanguageService.get("please_enter_phone_number")
                          : null,
            )
            : IntlPhoneField(
              controller: model.phoneController,
              pickerDialogStyle: PickerDialogStyle(
                backgroundColor: AppColors.white,
                countryCodeStyle: TextStyle(color: AppColors.black),
                countryNameStyle: TextStyle(color: AppColors.black),
              ),
              decoration: InputDecoration(
                labelText: LanguageService.get("phone_number"),
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
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                model.updatePhoneNumber(phone);
              },
              validator: (phone) {
                if (phone == null || phone.number.isEmpty) {
                  return LanguageService.get("please_enter_phone_number");
                }
                return null;
              },
            ),
        SizedBox(height: AppSizes.h10),
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
              initialValue: model.email,
              label: LanguageService.get("email"),
              keyboardType: TextInputType.emailAddress,
          validator: (value) {

            if (value == null || value.isEmpty) {
              return 'Please Enter Mail';
            }

            final emailRegex = RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            );

            if (!emailRegex.hasMatch(value)) {
              return 'Please Enter Valid Email';
            }

            return null;
          },
            )
            : _buildEditableTextField(
              controller: model.emailController,
              label: LanguageService.get("email"),
              keyboardType: TextInputType.emailAddress,
          validator: (value) {

            if (value == null || value.isEmpty) {
              return 'Please Enter Mail';
            }

            final emailRegex = RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            );

            if (!emailRegex.hasMatch(value)) {
              return 'Please Enter Valid Email';
            }

            return null;
          },
            ),

        SizedBox(height: AppSizes.h10),
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
          initialValue: model.contactPerson,
          label: LanguageService.get("contact_person"),
          keyboardType: TextInputType.name,
        )
            : _buildEditableTextField(
          controller: model.contactPersonController,
          label: LanguageService.get("contact_person"),
          keyboardType: TextInputType.name,
        ),

        SizedBox(height: AppSizes.h10),
       if (!attributes.hasReadOnly)
            _buildDesignationField(model),
      ],
    );
  }


  Widget _buildDesignationField(
      AddPartnerViewModel model,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: model.designationType,
        decoration: InputDecoration(
          labelText: LanguageService.get("designation"),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w16,
            vertical: AppSizes.h16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: [
          DropdownMenuItem(value: 'md', child: Text('Managing Director (MD)')),
          DropdownMenuItem(
            value: 'ceo',
            child: Text('Chief Executive Officer (CEO)'),
          ),
          DropdownMenuItem(value: 'partner', child: Text('Managing Partner')),
          DropdownMenuItem(
            value: 'chairman',
            child: Text('Chairman / Chairperson'),
          ),
          DropdownMenuItem(value: 'others', child: Text('Others')),
        ],
        onChanged: (value) {
          model.updateDesignationType(value);
          // Show text field for "Others" option
          if (value == 'others') {
            model.showOtherDesignation = true;
          } else {
            model.showOtherDesignation = false;
          }
        },
      ),
    );
  }


  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool isLastField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction:
          isLastField ? TextInputAction.done : TextInputAction.next,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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
      ),
      validator: validator,
    );
  }

  Widget _buildMachineSelectionDropdown(
    BuildContext context,
    AddPartnerViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get("select_assign_machines"),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.v14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSizes.h10),

        // Simple dropdown button that opens the selection popup
        InkWell(
          onTap: () {
            _showCleanMachineSelectionPopup(context, model);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w16,
              vertical: AppSizes.h16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.v8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model.machineAssignments.isEmpty
                        ? LanguageService.get("select_machine")
                        : "${model.machineAssignments.length} ${LanguageService.get("machines")}",
                    style: TextStyle(
                      color:
                          model.machineAssignments.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                      fontSize: AppSizes.v16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        // Standalone Add Machine button removed - now only in the popup list
      ],
    );
  }

  // Clean and simple machine selection popup similar to the language selection shown
  void _showCleanMachineSelectionPopup(
    BuildContext context,
    AddPartnerViewModel model,
  ) {
    final availableMachines = model.machines ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.v12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog header - Step 1 of 2
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.h16,
                    horizontal: AppSizes.w20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.v12),
                      topRight: Radius.circular(AppSizes.v12),
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSizes.w16),
                      Text(
                        LanguageService.get("select_machines"),
                        style: TextStyle(
                          fontSize: AppSizes.v18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                Container(
                  height: 4,
                  width: double.infinity,
                  color: AppColors.lightGrey.withOpacity(0.3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(color: AppColors.primary),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: AppColors.lightGrey.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: EdgeInsets.all(AppSizes.w16),
                  child: TextField(
                    controller: model.machineSearchController,
                    decoration: InputDecoration(
                      hintText: LanguageService.get("search_machines"),
                      prefixIcon: Icon(Icons.search, color: AppColors.gray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v8),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v8),
                        borderSide: BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: model.filterMachines,
                  ),
                ),

                // Machine list
                Flexible(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      final machinesToDisplay =
                          model.filteredMachines.isEmpty
                              ? availableMachines
                              : model.filteredMachines;

                      return ListView.builder(
                        itemCount:
                            machinesToDisplay.length +
                            1, // +1 for Add Machine button
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // Add Machine button at the end of the list
                          if (index == machinesToDisplay.length) {
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                model.navigateToAddMachine();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSizes.h16,
                                  horizontal: AppSizes.w20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.lightGrey.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    SizedBox(width: AppSizes.w12),
                                    Text(
                                      LanguageService.get("add_machine"),
                                      style: TextStyle(
                                        fontSize: AppSizes.v16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Regular machine items
                          final machine = machinesToDisplay[index];
                          final isSelected = model.machineAssignments.any(
                            (assignment) => assignment.id == machine.id,
                          );

                          return InkWell(
                            onTap: () {
                              if (isSelected) {
                                model.removeMachineAssignment(machine.id!);
                              } else {
                                model.addMachineAssignment(machine);
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.h16,
                                horizontal: AppSizes.w20,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.lightGrey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          machine.machineName ??
                                              'Unknown Machine',
                                          style: TextStyle(
                                            fontSize: AppSizes.v16,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                            color:
                                                isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary,
                                          ),
                                        ),
                                        if (machine.modelNumber != null)
                                          SizedBox(height: 4),
                                        if (machine.modelNumber != null)
                                          Text(
                                            machine.modelNumber!,
                                            style: TextStyle(
                                              fontSize: AppSizes.v14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Done button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.w16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v8),
                      ),
                    ),
                    child: Text(
                      LanguageService.get("done"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.v16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildMachinesSection(
    BuildContext context,
    AddPartnerViewModel model,
  ) {
    if (getUser().organizationType == OrganizationType.manufacturer) {
      return Column(
        children: [
          // Machine selection dropdown popup
          _buildMachineSelectionDropdown(context, model),
          SizedBox(height: AppSizes.h20),

          // List of selected machines with their dates
          if (model.machineAssignments.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: model.machineAssignments.length,
              itemBuilder: (context, index) {
                final assignment = model.machineAssignments[index];
                return _buildMachineAssignmentCard(context, model, assignment);
              },
            ),
        ],
      );
    }

    // For non-manufacturer organization types, return empty
    return SizedBox.shrink();
  }

  Widget _buildMachineAssignmentCard(
    BuildContext context,
    AddPartnerViewModel model,
    MachineAssignment assignment,
  ) {
    return Card(
      color: AppColors.white,
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  assignment.machine.machineName ?? 'Unknown Machine',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => model.removeMachineAssignment(assignment.id),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h16),
            _buildDateField(
              context: context,
              label: LanguageService.get("Purchase Date"),
              date: assignment.purchaseDate,
              onDateSelected: (date) {
                model.updateMachinePurchaseDate(assignment.id, date);
              },
            ),
            SizedBox(height: AppSizes.h16),
            _buildDateField(
              context: context,
              label: LanguageService.get("installation_date"),
              date: assignment.installationDate,
              onDateSelected: (date) {
                model.updateMachineInstallationDate(assignment.id, date);
              },
            ),
            SizedBox(height: AppSizes.h16),

            Text(
              LanguageService.get("warranty_details"),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.h10),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context: context,
                    label: LanguageService.get("start_date"),
                    date: assignment.startDate,
                    onDateSelected: (date) {
                      model.updateMachineStartDate(assignment.id, date);
                    },
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                Expanded(
                  child: _buildDateField(
                    context: context,
                    label: LanguageService.get("expiration_date"),
                    date: assignment.expirationDate,
                    onDateSelected: (date) {
                      model.updateMachineExpirationDate(assignment.id, date);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.h16),
            _buildInvoiceField(context, model, assignment),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceField(
    BuildContext context,
    AddPartnerViewModel model,
    MachineAssignment assignment,
  ) {
    // Create a TextEditingController for this specific invoice field

    return TextFormField(
      // controller: TextEditingController(text: assignment.invoiceNo),
      decoration: InputDecoration(
        labelText: LanguageService.get("machine_invoice_no"),
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
      ),
      onChanged: (value) {
        model.updateMachineInvoiceNo(assignment.id, value);
      },
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
          ),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd').format(date) : LanguageService.get("select_date"),
          style: TextStyle(
            color:
                date != null ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoMachinesWidget(
    BuildContext context,
    AddPartnerViewModel model,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.w16),
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.v12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          Icon(
            Icons.precision_manufacturing,
            size: AppSizes.w40,
            color: AppColors.gray,
          ),
          SizedBox(height: AppSizes.h10),
          Text(
            LanguageService.get("no_machines_assigned"),
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: AppSizes.v16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSizes.h6),
          Text(
            LanguageService.get("please_add_machines_first"),
            style: TextStyle(color: AppColors.gray, fontSize: AppSizes.v14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    required String initialValue,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: attributes.hasReadOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        fillColor: AppColors.lightGrey.withOpacity(0.3),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSaveButton(BuildContext context, AddPartnerViewModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (getUser().organizationType == OrganizationType.manufacturer)
          if (model.machineAssignments.isEmpty &&
              model.machines != null &&
              model.machines!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: AppSizes.h8),
              child: Text(
                LanguageService.get("assign_minimum_one_machine"),
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: AppSizes.v12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ElevatedButton(
          onPressed: model.isSaveEnabled ? model.onSave : null,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, AppSizes.h50),
            backgroundColor:
                model.isSaveEnabled ? AppColors.primary : AppColors.gray,
          ),
          child:
              model.isSaving
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    getUser().organizationType == OrganizationType.manufacturer
                        ? LanguageService.get("save")
                        : LanguageService.get("send_request"),
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ],
    );
  }
}
