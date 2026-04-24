import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:phone_input/src/number_parser/models/phone_number.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/features/employee/add_employee/add_employee.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common/custom_dropdown.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/dialogs/country_picker.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/employee.dart';

import '../../machines/machines_dropdown.dart';
import '../../tasks/create_task/widgets/add_media_widget.dart';
import '../department/department_dropdown.dart';
import '../designation/designation_dropdown.dart';
import 'employee_permission.view.dart';

class AddEmployeeViewAttributes {
  final String? id;
  final bool hasPasswordField;
  final bool hasReadOnly;
  final bool isPartialAdd;

  AddEmployeeViewAttributes({
    this.id,
    this.hasPasswordField = false,
    this.hasReadOnly = false,
    this.isPartialAdd = false,
  });
}

class AddEmployeeView extends StackedView<AddEmployeeViewModel> {
  AddEmployeeView({Key? key, required this.attributes}) : super(key: key);

  final AddEmployeeViewAttributes attributes;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget builder(
    BuildContext context,
    AddEmployeeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          viewModel.isPartialEdit
              ? LanguageService.get('add_employee')
              : viewModel.isViewMode
              ? LanguageService.get('employee_details')
              : viewModel.isEditMode
              ? LanguageService.get('edit_employee_detail')
              : LanguageService.get('create_new_employee'),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primaryDark],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              stops: const [0.08, 1],
            ),
          ),
        ),
      ),
      body:
          viewModel.isBusy
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.h10,
                    right: AppSizes.h10,
                    bottom: AppSizes.h12,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ PROFILE HEADER (View Mode Only)
                        if (viewModel.isViewMode)
                          Container(
                            padding: EdgeInsets.all(AppSizes.h16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.h8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.2,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),

                                        child: ClipOval(
                                          child:
                                              viewModel.profilePhotoUrl != null
                                                  ? Image.network(
                                                    '${viewModel.profilePhotoUrl}'
                                                        .prefixWithBaseUrl,
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        AppImages.team_default,
                                                        width: 50,
                                                        height: 50,
                                                      );
                                                    },
                                                  )
                                                  : Image.asset(
                                                    AppImages.team_default,
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              viewModel
                                                      .nameController
                                                      .text
                                                      .isNotEmpty
                                                  ? viewModel
                                                      .nameController
                                                      .text
                                                  : "No Name",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ).animate().fadeIn(
                                              duration: 500.ms,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              viewModel
                                                      .selectedDesignation
                                                      ?.name ??
                                                  "N/A",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textGrey,
                                              ),
                                            ).animate().fadeIn(
                                              duration: 500.ms,
                                              delay: 200.ms,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20),
                                  onPressed: viewModel.switchToEditMode,
                                ),
                              ],
                            ),
                          ),
                        AppGaps.h16,

                        // ✅ EMPLOYEE DETAILS SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get('employee_details'),
                          children: [
                            _FormSection(
                              label: LanguageService.get('employee_name'),
                              child: CommonTextField(
                                controller: viewModel.nameController,
                                placeholder: LanguageService.get('enter_name'),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                validator:
                                    (value) =>
                                        value?.isEmpty == true
                                            ? LanguageService.get(
                                              'please_enter_name',
                                            )
                                            : null,
                              ),
                            ),
                            AppGaps.h16,
                            _FormSection(
                              label: LanguageService.get('phone_number'),
                              child: IntlPhoneField(
                                controller: viewModel.phoneController,
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                enabled: !viewModel.isViewMode,
                                pickerDialogStyle: PickerDialogStyle(
                                  backgroundColor: AppColors.white,
                                  countryCodeStyle: TextStyle(
                                    color: AppColors.black,
                                  ),
                                  countryNameStyle: TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: LanguageService.get(
                                    'phone_number',
                                  ),
                                  labelStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                initialCountryCode: 'IN',
                                onChanged: (phone) {
                                  if (!viewModel.isViewMode) {
                                    viewModel.updatePhoneNumber(phone);
                                  }
                                  // model.updateForgotPhoneNumber(phone);
                                },
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) {
                                    return LanguageService.get(
                                      'please_enter_phone_number',
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // _FormSection(
                            //   label: LanguageService.get('phone_number'),
                            //   child: IntlPhoneField(
                            //     disableLengthCheck: true,
                            //     controller: viewModel.phoneController,
                            //     readOnly: viewModel.isViewMode, // ✅ FIXED
                            //     enabled: !viewModel.isViewMode, // ✅ ADDED
                            //     pickerDialogStyle: PickerDialogStyle(
                            //       backgroundColor: AppColors.white,
                            //       countryCodeStyle: TextStyle(
                            //         color: AppColors.black,
                            //       ),
                            //       countryNameStyle: TextStyle(
                            //         color: AppColors.black,
                            //       ),
                            //     ),
                            //     decoration: InputDecoration(
                            //       hintText: LanguageService.get(
                            //         'enter_phone_number',
                            //       ),
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.lightGrey,
                            //         ),
                            //       ),
                            //       enabledBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.lightGrey,
                            //         ),
                            //       ),
                            //       focusedBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.primary,
                            //           width: 2,
                            //         ),
                            //       ),
                            //       contentPadding: EdgeInsets.symmetric(
                            //         vertical: AppSizes.h14,
                            //       ),
                            //     ),
                            //     onChanged: (phone) {
                            //       if (!viewModel.isViewMode) {
                            //         viewModel.updatePhoneNumber(phone);
                            //       }
                            //     },
                            //     initialCountryCode: 'IN',
                            //     validator: (phone) {
                            //       if (phone == null || phone.number.isEmpty) {
                            //         return LanguageService.get(
                            //           'please_enter_phone_number',
                            //         );
                            //       }
                            //       return null;
                            //     },
                            //   ),
                            // ),
                            AppGaps.h5,
                            _FormSection(
                              label: LanguageService.get('email'),
                              child: CommonTextField(
                                controller: viewModel.emailController,
                                placeholder: LanguageService.get('enter_email'),
                                keyboardType: TextInputType.emailAddress,
                                readOnly: viewModel.isViewMode, // ✅ FIXED
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
                            ),
                            if (!viewModel.isViewMode) ...[
                              AppGaps.h20,
                              _FormSection(
                                label: LanguageService.get('blood_group'),
                                child: CustomDropdownFormField<String>(
                                  hintText: LanguageService.get(
                                    'select_blood_group',
                                  ),
                                  value: viewModel.selectedBloodGroup,
                                  items:
                                      viewModel.bloodGroups.map((String unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                  onChanged: viewModel.updateSelectedBloodGroup,
                                  label: '',
                                  validator:
                                      (value) =>
                                          value == null
                                              ? LanguageService.get(
                                                'Please Select Blood Group',
                                              )
                                              : null,
                                ),
                              ),
                              AppGaps.h20,
                              AddMediaWidget(onTap: viewModel.pickMedia),
                              if (viewModel.pickedFiles.isNotEmpty)
                                _buildPickedFilesList(viewModel),
                            ] else ...[
                              // ✅ SHOW BLOOD GROUP IN READ-ONLY MODE
                              if (viewModel.selectedBloodGroup != null) ...[
                                AppGaps.h16,
                                _FormSection(
                                  label: LanguageService.get('blood_group'),
                                  child: CommonTextField(
                                    controller: TextEditingController(
                                      text: viewModel.selectedBloodGroup,
                                    ),
                                    readOnly: true,
                                    placeholder: '',
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                        AppGaps.h16,

                        // ✅ EMPLOYEE ROLE SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get('employee_role'),
                          children: [
                            _FormSection(
                              label: LanguageService.get('employee_id'),
                              child: CommonTextField(
                                controller: viewModel.employeeIdController,
                                placeholder: LanguageService.get(
                                  'enter_employee_id',
                                ),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                validator:
                                    (value) =>
                                        value?.isEmpty == true
                                            ? LanguageService.get(
                                              'Please Select Employee ID',
                                            )
                                            : null,
                              ),
                            ),
                            AppGaps.h16,
                            _FormSection(
                              label: LanguageService.get('department'),
                              child: CustomDepartmentDropdown(
                                viewModel: viewModel,
                                isReadOnly:
                                    viewModel.isViewMode &&
                                    viewModel.isPartialEdit == false,
                              ),
                            ),
                            // _FormSection(
                            //   label: LanguageService.get('department'),
                            //   child: CustomDropdownFormField<DepartmentModel>(
                            //     hintText: LanguageService.get(
                            //       'select_department',
                            //     ),
                            //     value: viewModel.selectedDepartment,
                            //     items: [
                            //       // Always show "Add New" option when list is empty or as first option
                            //       if (viewModel.myDepartment.isEmpty)
                            //         DropdownMenuItem<DepartmentModel>(
                            //           value: DepartmentModel(
                            //             id: 'new',
                            //             name: 'Add New Department',
                            //           ),
                            //           child: Row(
                            //             children: [
                            //               Icon(
                            //                 Icons.add_circle_outline,
                            //                 size: 20,
                            //                 color: AppColors.primary,
                            //               ),
                            //               SizedBox(width: 8),
                            //               Text(
                            //                 "Add New Department",
                            //                 style: TextStyle(
                            //                   color: AppColors.primary,
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ...viewModel.myDepartment.map((
                            //         DepartmentModel dept,
                            //       ) {
                            //         return DropdownMenuItem<DepartmentModel>(
                            //           value: dept,
                            //           child: Text(
                            //             dept.name ?? 'Unnamed Department',
                            //           ),
                            //         );
                            //       }).toList(),
                            //     ],
                            //     onChanged:
                            //         viewModel.isViewMode && viewModel.isPartialEdit==false
                            //             ? null
                            //             : (value) {
                            //               if (value?.id == 'new') {
                            //                 // Call dialog without TeamListVM
                            //                 viewModel
                            //                     .showCreateDepartmentDialog(
                            //                       context,
                            //                     );
                            //               } else {
                            //                 viewModel.updateSelectedDepartment(
                            //                   value,
                            //                 );
                            //               }
                            //             },
                            //     label: '',
                            //     validator:
                            //         (value) =>
                            //             value == null || value.id == 'new'
                            //                 ? LanguageService.get(
                            //                   'Please Select Department',
                            //                 )
                            //                 : null,
                            //   ),
                            // ),
                            AppGaps.h16,
                            _FormSection(
                              label: 'Designation',
                              child: CustomDesignationDropdown(
                                viewModel: viewModel,
                                isReadOnly:
                                    viewModel.isViewMode &&
                                    viewModel.isPartialEdit == false,
                              ),
                            ),
                            AppGaps.h16,

                            //  if(viewModel.selectedDesignation?.name.toLowerCase()=='machine operator')
                            // ...[
                            _FormSection(
                              label: 'assign_machine'.lang,
                              child: MachineDropdownFormField(
                                hintText: 'Select Machine',
                                items: viewModel.machines,
                                onChanged: viewModel.updateSelectedMachine,
                                initialValue: viewModel.selectedMachine,
                                // ✨ NEW: Conditional validator based on designation
                                validator: (value) {
                                  // Check if designation contains 'hr' (case insensitive)
                                  final designationName =
                                      viewModel.selectedDepartment?.name
                                          .toLowerCase() ??
                                      '';
                                  final isHR = designationName.contains('hr');

                                  // If NOT HR and machine is not selected, show error
                                  if (!isHR && value == null) {
                                    return 'Please select a machine';
                                  }

                                  return null; // No error
                                },
                              ),
                            ),

                            AppGaps.h16,
                            //],
                            _FormSection(
                              label: 'Country',
                              child: CommonCountryPicker(
                                selectedCountry: viewModel.selectedCountry,
                                onCountryChanged:
                                    viewModel.updateSelectedCountry,
                                isReadOnly: viewModel.isViewMode,
                                hintText: 'Select Country',
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select country';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            AppGaps.h16,
                            _FormSection(
                              label: LanguageService.get(
                                'assigned_area_region_city',
                              ),
                              child: CommonTextField(
                                controller:
                                    viewModel.customFactoryLocationController,
                                placeholder: LanguageService.get(
                                  'Enter Area / Region / City',
                                ),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                              ),
                            ),
                            if (viewModel.selectedDesignation?.name
                                    .toLowerCase() !=
                                'ceo') ...[
                              AppGaps.h16,
                              _FormSection(
                                label: LanguageService.get('report_to'),
                                child:
                                    viewModel.isLoadingReportTo
                                        ? Container(
                                          height: 56,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : CustomDropdownFormField<String>(
                                          key: ValueKey(
                                            'report_to_${viewModel.reportToList.length}',
                                          ),
                                          isExpanded: true,
                                          hintText:
                                              viewModel
                                                      .selectedReportToIds
                                                      .isEmpty
                                                  ? LanguageService.get(
                                                    'report_to',
                                                  )
                                                  : "${viewModel.selectedReportToIds.length} selected",

                                          value: null,

                                          items:
                                              viewModel.reportToList.map((
                                                Employee emp,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: emp.id,
                                                  enabled: false,

                                                  child: StatefulBuilder(
                                                    builder: (
                                                      context,
                                                      menuSetState,
                                                    ) {
                                                      final isSelected = viewModel
                                                          .selectedReportToIds
                                                          .contains(emp.id);

                                                      return InkWell(
                                                        onTap: () {
                                                          viewModel
                                                              .toggleReportTo(
                                                                emp.id!,
                                                              );
                                                          menuSetState(() {});
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Checkbox(
                                                              value: isSelected,
                                                              onChanged: (val) {
                                                                viewModel
                                                                    .toggleReportTo(
                                                                      emp.id!,
                                                                    );
                                                                menuSetState(
                                                                  () {},
                                                                );
                                                              },
                                                            ),

                                                            Expanded(
                                                              child: Text(
                                                                "${capitalize(emp.name ?? 'Unknown')} (${emp.designation?.name ?? 'N/A'})",
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              }).toList(),

                                          onChanged:
                                              viewModel.isViewMode ||
                                                      viewModel
                                                          .reportToList
                                                          .isEmpty
                                                  ? null
                                                  : (_) {},

                                          label: '',
                                          validator: (value) {
                                            if (viewModel
                                                        .selectedDesignation
                                                        ?.name !=
                                                    'CEO' &&
                                                !viewModel.isViewMode &&
                                                viewModel
                                                    .reportToList
                                                    .isNotEmpty) {
                                              if (viewModel
                                                  .selectedReportToIds
                                                  .isEmpty) {
                                                return 'Please select report to';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                // CustomDropdownFormField<String>(
                                //           key: ValueKey('report_to_${viewModel.reportToList.length}'),
                                //           hintText: viewModel.reportToList.isEmpty
                                //                   ? 'No eligible employees found'
                                //                   : LanguageService.get('report_to'),
                                //           value:
                                //               viewModel
                                //                   .selectedReportToEmployee
                                //                   ?.id, // ✅ ID use karo
                                //           items: viewModel.reportToList.map((Employee emp,) {
                                //                 return DropdownMenuItem<String>(
                                //                   value: emp.id,
                                //                   child: Text(
                                //                     "${emp.name ?? 'Unknown'} (${emp.designation?.name ?? 'N/A'})",
                                //                     style: TextStyle(
                                //                       fontSize: 14,
                                //                     ),
                                //                   ),
                                //                 );
                                //               }).toList(),
                                //           onChanged:
                                //               viewModel.isViewMode ||
                                //                       viewModel
                                //                           .reportToList
                                //                           .isEmpty
                                //                   ? null
                                //                   : (String? selectedId) {
                                //                     // ✅ String receive karo
                                //                     if (selectedId != null) {
                                //                       final selectedEmployee =
                                //                           viewModel.reportToList
                                //                               .firstWhere(
                                //                                 (emp) =>
                                //                                     emp.id ==
                                //                                     selectedId,
                                //                               );
                                //                       viewModel
                                //                           .updateSelectedReportTo(
                                //                             selectedEmployee,
                                //                             selectedEmployee
                                //                                 .name,
                                //                           );
                                //                     }
                                //                   },
                                //           label: '',
                                //           validator: (value) {
                                //             if (viewModel
                                //                         .selectedDesignation
                                //                         ?.name !=
                                //                     'CEO' &&
                                //                 !viewModel.isViewMode &&
                                //                 viewModel
                                //                     .reportToList
                                //                     .isNotEmpty) {
                                //               if (value == null ||
                                //                   value.isEmpty) {
                                //                 return 'Please select report to';
                                //               }
                                //             }
                                //             return null;
                                //           },
                                //         ),
                              ),

                              // Debug info
                              if (!viewModel.isViewMode)
                                Padding(
                                  padding: EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    "Available: ${viewModel.reportToList.length} employees",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                        AppGaps.h16,

                        // ✅ WORK INFORMATION SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get('work_information'),
                          children: [
                            _FormSection(
                              label: LanguageService.get('employment_type'),
                              child: CustomDropdownFormField<String>(
                                hintText: LanguageService.get('full_time'),
                                value: viewModel.selectedEmploymentType,
                                items:
                                    viewModel.employmentTypes.map((
                                      String type,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                onChanged:
                                    viewModel.isViewMode
                                        ? null
                                        : viewModel
                                            .updateSelectedEmploymentType,
                                label: '',
                                validator:
                                    (value) =>
                                        value == null
                                            ? LanguageService.get(
                                              'please_select_employment_type',
                                            )
                                            : null,
                              ),
                            ),
                            AppGaps.h16,
                            Row(
                              children: [
                                Expanded(
                                  child: _FormSection(
                                    label: LanguageService.get('shift_timing'),
                                    child: SizedBox(
                                      height: 60,
                                      child: CustomDropdownFormField<String>(
                                        hintText: LanguageService.get(
                                          'shift_timing',
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.black,
                                        ),
                                        value: viewModel.shiftTiming,
                                        items:
                                            viewModel.shiftOptions.map((
                                              String type,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: type,
                                                child: Text(type),
                                              );
                                            }).toList(),
                                        onChanged:
                                            viewModel.isViewMode
                                                ? null // ✅ DISABLED
                                                : viewModel.updateSelectedShift,
                                        label: '',
                                        validator:
                                            (value) =>
                                                value == null
                                                    ? LanguageService.get(
                                                      'please_select_employment_type',
                                                    )
                                                    : null,
                                      ),
                                    ),
                                  ),
                                ),
                                AppGaps.w16,
                                Expanded(
                                  child: _FormSection(
                                    label: LanguageService.get('joining_date'),
                                    child: SizedBox(
                                      height: 55,
                                      child: CommonTextField(
                                        controller:
                                            viewModel.startDateTimeController,
                                        placeholder: LanguageService.get(
                                          'select_date',
                                        ),
                                        readOnly: true,
                                        onTap:
                                            viewModel.isViewMode
                                                ? null
                                                : () => viewModel
                                                    .selectStartDateTime(
                                                      context,
                                                    ),
                                        suffixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 20,
                                          color: AppColors.textGrey,
                                        ),
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? LanguageService.get(
                                                      'please_select_joining_date',
                                                    )
                                                    : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppGaps.h16,

                        // ✅ PERSONAL INFORMATION SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get('personal_information'),
                          children: [
                            _FormSection(
                              label: LanguageService.get('address_line_1'),
                              child: CommonTextField(
                                controller: viewModel.address_line_1Controller,
                                placeholder: LanguageService.get(
                                  'address_line_1',
                                ),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                validator:
                                    (value) =>
                                        value?.isEmpty == true
                                            ? LanguageService.get(
                                              'Please Fill Address',
                                            )
                                            : null,
                              ),
                            ),
                            AppGaps.h16,
                            _FormSection(
                              label: LanguageService.get('address_line_2'),
                              child: CommonTextField(
                                controller: viewModel.address_line_2Controller,
                                placeholder: LanguageService.get(
                                  'address_line_2',
                                ),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                              ),
                            ),

                            AppGaps.h16,

                            // Country and City in same row
                            Row(
                              children: [
                                Expanded(
                                  child: buildCountryDropdown(
                                    context,
                                    viewModel,

                                    viewModel.country,
                                    (value) {
                                      viewModel.updateCountry(value);
                                      viewModel.onCountryChanged(
                                        value ?? 'India',
                                      );
                                    },
                                    false,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: AbsorbPointer(
                                    absorbing: false,
                                    child: buildStateDropdown(
                                      context,
                                      viewModel,
                                      viewModel.selectedState,
                                      (value) => viewModel.updateState(value),
                                      false,
                                      viewModel
                                          .availableStates, // Pass corporate states list
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // State and PIN Code in same row
                            Row(
                              children: [
                                Expanded(
                                  child: CommonTextField(
                                    enabled: true,
                                    controller: viewModel.cityController,
                                    label: LanguageService.get("current_city"),
                                    placeholder: LanguageService.get(
                                      "current_city",
                                    ),
                                    readOnly: false,
                                    contentPadding: EdgeInsets.all(12),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return LanguageService.get(
                                          "please_enter_city",
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),

                                Expanded(
                                  child: CommonTextField(
                                    enabled: true,
                                    controller: viewModel.pinCodeController,
                                    label: LanguageService.get("pin_code"),
                                    placeholder: LanguageService.get(
                                      "pin_code",
                                    ),
                                    readOnly: false,
                                    contentPadding: EdgeInsets.all(12),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return LanguageService.get(
                                          "please_enter_pin_code",
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: _FormSection(
                            //         label: LanguageService.get('current_city'),
                            //         child: CommonTextField(
                            //           controller: viewModel.pr_cityController,
                            //           placeholder: LanguageService.get(
                            //             'current_city',
                            //           ),
                            //           readOnly: viewModel.isViewMode, // ✅ FIXED
                            //           validator:
                            //               (value) =>
                            //                   value?.isEmpty == true
                            //                       ? LanguageService.get(
                            //                         'Please Fill City Name',
                            //                       )
                            //                       : null,
                            //         ),
                            //       ),
                            //     ),
                            //     AppGaps.w16,
                            //     Expanded(
                            //       child: _FormSection(
                            //         label: LanguageService.get(
                            //           'state_province',
                            //         ),
                            //         child: CommonTextField(
                            //           controller: viewModel.pr_stateController,
                            //           placeholder: LanguageService.get(
                            //             'state_province',
                            //           ),
                            //           readOnly: viewModel.isViewMode, // ✅ FIXED
                            //           validator:
                            //               (value) =>
                            //                   value?.isEmpty == true
                            //                       ? LanguageService.get(
                            //                         'Please Fill State Name',
                            //                       )
                            //                       : null,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // AppGaps.h16,
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: _FormSection(
                            //         label: 'Country',
                            //         child: CommonCountryPicker(
                            //           selectedCountry:
                            //               viewModel.selectedPersonalCountry,
                            //           onCountryChanged:
                            //               viewModel
                            //                   .updateSelectedPersonalCountry,
                            //           isReadOnly: viewModel.isViewMode,
                            //           hintText: 'Select Country',
                            //           validator: (value) {
                            //             if (value == null) {
                            //               return 'Please select country';
                            //             }
                            //             return null;
                            //           },
                            //         ),
                            //       ),
                            //     ),
                            //     AppGaps.w16,
                            //     Expanded(
                            //       child: _FormSection(
                            //         label: LanguageService.get('Pincode'),
                            //         child: CommonTextField(
                            //           keyboardType:TextInputType.phone ,
                            //           controller:
                            //               viewModel.pr_pincodeController,
                            //           placeholder: LanguageService.get(
                            //             'Pincode',
                            //           ),
                            //           readOnly: viewModel.isViewMode, // ✅ FIXED
                            //           validator:
                            //               (value) =>
                            //                   value?.isEmpty == true
                            //                       ? LanguageService.get(
                            //                         'Please Fill Area Pincode',
                            //                       )
                            //                       : null,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        AppGaps.h16,

                        // ✅ EMERGENCY CONTACT SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get('emergency_contact_name'),
                          children: [
                            _FormSection(
                              label: LanguageService.get('name_and_relation'),
                              child: CommonTextField(
                                controller: viewModel.emergency_nameController,
                                placeholder: LanguageService.get(
                                  'name_and_relation',
                                ),
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                // validator:
                                //     (value) =>
                                //         value?.isEmpty == true
                                //             ? LanguageService.get(
                                //               'please_enter_name',
                                //             )
                                //             : null,
                              ),
                            ),
                            AppGaps.h16,
                            _FormSection(
                              label: LanguageService.get('phone_number'),
                              child: IntlPhoneField(
                                controller:
                                    viewModel.emergency_mobileController,
                                readOnly: viewModel.isViewMode, // ✅ FIXED
                                enabled: !viewModel.isViewMode,
                                pickerDialogStyle: PickerDialogStyle(
                                  backgroundColor: AppColors.white,
                                  countryCodeStyle: TextStyle(
                                    color: AppColors.black,
                                  ),
                                  countryNameStyle: TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: LanguageService.get(
                                    'phone_number',
                                  ),
                                  labelStyle: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.v12,
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                initialCountryCode: 'IN',
                                onChanged: (phone) {
                                  if (!viewModel.isViewMode) {
                                    viewModel.updatePhoneNumber(phone);
                                  }
                                  // model.updateForgotPhoneNumber(phone);
                                },
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) {
                                    return LanguageService.get(
                                      'please_enter_phone_number',
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // _FormSection(
                            //   label: LanguageService.get('phone_number'),
                            //   child: IntlPhoneField(
                            //     disableLengthCheck: true,
                            //     controller:
                            //         viewModel.emergency_mobileController,
                            //     readOnly: viewModel.isViewMode, // ✅ FIXED
                            //     enabled: !viewModel.isViewMode, // ✅ ADDED
                            //     pickerDialogStyle: PickerDialogStyle(
                            //       backgroundColor: AppColors.white,
                            //       countryCodeStyle: TextStyle(
                            //         color: AppColors.black,
                            //       ),
                            //       countryNameStyle: TextStyle(
                            //         color: AppColors.black,
                            //       ),
                            //     ),
                            //     decoration: InputDecoration(
                            //       hintText: LanguageService.get(
                            //         'enter_phone_number',
                            //       ),
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.lightGrey,
                            //         ),
                            //       ),
                            //       enabledBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.lightGrey,
                            //         ),
                            //       ),
                            //       focusedBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(
                            //           AppSizes.h12,
                            //         ),
                            //         borderSide: BorderSide(
                            //           color: AppColors.primary,
                            //           width: 2,
                            //         ),
                            //       ),
                            //       contentPadding: EdgeInsets.symmetric(
                            //         vertical: AppSizes.h14,
                            //       ),
                            //     ),
                            //     onChanged: (phone) {
                            //       if (!viewModel.isViewMode) {
                            //         viewModel.updatePhoneNumber(phone);
                            //       }
                            //     },
                            //     initialCountryCode: 'IN',
                            //     // validator: (phone) {
                            //     //   if (phone == null || phone.number.isEmpty) {
                            //     //     return LanguageService.get(
                            //     //       'please_enter_phone_number',
                            //     //     );
                            //     //   }
                            //     //   return null;
                            //     // },
                            //   ),
                            // ),
                            AppGaps.h5,
                            _FormSection(
                              label: LanguageService.get('email'),
                              child: CommonTextField(
                                controller: viewModel.emergency_emailController,
                                placeholder: LanguageService.get('enter_email'),
                                keyboardType: TextInputType.emailAddress,
                                readOnly: viewModel.isViewMode, // ✅ FIXED
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
                                // validator:
                                //     (value) =>
                                //         value?.isEmpty == true
                                //             ? LanguageService.get(
                                //               'Please Enter Mail',
                                //             )
                                //             : null,
                              ),
                            ),
                          ],
                        ),
                        AppGaps.h16,

                        // ✅ PERMISSIONS SECTION
                        _buildSectionCard(
                          context: context,
                          title: LanguageService.get(
                            'System Access & Permissions',
                          ),
                          traling: CommonElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SystemAccessPermissionsView(
                                        isReadOnly: viewModel.isViewMode,
                                        initialPermissions:
                                            viewModel.permissions,
                                      ),
                                ),
                              );

                              if (result != null &&
                                  result is Permissions &&
                                  !viewModel.isViewMode) {
                                viewModel.updatePermissions(result);
                              }
                            },
                            label:
                                viewModel.isEditMode
                                    ? LanguageService.get('edit_permission')
                                    : viewModel.isViewMode
                                    ? LanguageService.get('view permission')
                                    : LanguageService.get('add_permission'),
                            backgroundColor: AppColors.primaryDark,
                            textColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            borderRadius: 10,
                            fontSize: 10,
                            height: 28,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

      bottomNavigationBar:
          (viewModel.isPartialEdit == false && viewModel.isViewMode) ||
                  viewModel.isBusy
              ? null
              : Container(
                height: 80,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGrey,
                      spreadRadius: 0,
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(AppSizes.h16),
                child: CommonElevatedButton(
                  label:
                      viewModel.isEditMode
                          ? LanguageService.get('save_changes')
                          : viewModel.isPartialEdit
                          ? LanguageService.get('add_employee')
                          : LanguageService.get('create_employee'),
                  isLoading: viewModel.isBusy,
                  borderRadius: AppSizes.h45,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: () {
                    viewModel.onSave(_formKey);
                  },
                ),
              ),
    );
  }

  @override
  AddEmployeeViewModel viewModelBuilder(BuildContext context) =>
      AddEmployeeViewModel();

  @override
  bool get disposeViewModel => false; // Add this to prevent disposal

  @override
  void onViewModelReady(AddEmployeeViewModel viewModel) {
    viewModel.init(attributes);
  }

  @override
  void onDispose(AddEmployeeViewModel viewModel) {
    // Manually dispose when the view is actually destroyed
    viewModel.dispose();
    super.onDispose(viewModel);
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    Widget? traling,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.h8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (traling == null)
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                traling,
              ],
            ),
          if (children.isNotEmpty) AppGaps.h16,
          ...children,
        ],
      ),
    );
  }

  Widget _buildPickedFilesList(AddEmployeeViewModel viewModel) {
    return Container(
      height: AppSizes.h100,
      margin: EdgeInsets.only(top: AppSizes.h16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.pickedFiles.length,
        itemBuilder: (context, index) {
          final file = viewModel.pickedFiles[index];
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: AppSizes.h100,
                height: AppSizes.h100,
                margin: EdgeInsets.only(right: AppSizes.w8),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppSizes.h8),
                  image:
                      file.path.contains('.jpg') || file.path.contains('.png')
                          ? DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    !(file.path.contains('.jpg') || file.path.contains('.png'))
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.h8),
                            child: Text(
                              file.path.split('/').last,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        : null,
              ),
              InkWell(
                onTap: () => viewModel.removeFile(index),
                child: Container(
                  margin: EdgeInsets.all(AppSizes.h4),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: AppSizes.h16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
        ),
        AppGaps.h8,
        child,
      ],
    );
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

Widget buildCountryDropdown(
  BuildContext context,
  AddEmployeeViewModel model,
  String selectedValue,
  Function(String?) onChanged,
  bool isReadOnly,
) {
  // Ensure the selected value is in the countries list, otherwise use default
  String validSelectedValue = selectedValue;
  if (!model.countries.contains(selectedValue)) {
    validSelectedValue = 'India'; // Default fallback
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        LanguageService.get("country"),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      CustomDropdownFormField<String>(
        isExpanded: true,
        label: LanguageService.get("country"),
        hintText: LanguageService.get('select_country'),
        value: validSelectedValue,
        items:
            model.countries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
        onChanged: isReadOnly ? null : onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return LanguageService.get('please_select_country');
          }
          return null;
        },
      ),
    ],
  );
}

Widget buildStateDropdown(
  BuildContext context,
  AddEmployeeViewModel model,
  String? selectedValue,
  Function(String?) onChanged,
  bool isReadOnly,
  List<String> statesList, // Direct states list parameter
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        LanguageService.get("state_province"),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      CustomDropdownFormField<String>(
        isExpanded: true,
        label: LanguageService.get("state_province"),
        hintText: LanguageService.get('select_state'),
        value: selectedValue,
        items:
            statesList.map((String state) {
              return DropdownMenuItem<String>(value: state, child: Text(state));
            }).toList(),
        onChanged: isReadOnly ? null : onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return LanguageService.get('please_select_state');
          }
          return null;
        },
      ),
    ],
  );
}
