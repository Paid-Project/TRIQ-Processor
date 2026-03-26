import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/services/language.service.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/widgets/common_elevated_button.dart';
import 'package:manager/widgets/common_app_bar.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../widgets/common/custom_dropdown.dart';
import 'create_or_edit_org.vm.dart';

class UpdateOrganizationViewAttributes {
  final Organization? organization;

  UpdateOrganizationViewAttributes({this.organization});
}

class UpdateOrganizationView extends StatelessWidget {
  const UpdateOrganizationView({super.key, this.attributes});

  final UpdateOrganizationViewAttributes? attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UpdateOrganizationViewModel>.reactive(
      viewModelBuilder: () => UpdateOrganizationViewModel(),
      onViewModelReady: (UpdateOrganizationViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        UpdateOrganizationViewModel model,
        Widget? child,
      ) {
        return WillPopScope(
          onWillPop: () async {
            if (model.isPersonalInfoEditable == true || 
                model.isCorporateAddressEditable == true) {
              final shouldLeave = await _showExitConfirmationDialog(context, model);
              return shouldLeave ?? false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(context, model),
            backgroundColor: AppColors.cultured,
            body:
                model.isBusy
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : Form(
                      key: model.formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Personal Information Section
                            _buildPersonalInformationSection(context, model),
                            const SizedBox(height: 15),

                            // Address Section (Corporate + Factory)
                            _buildCorporateAddressSection(context, model),
                          ],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {
    return GradientAppBar(titleKey: "update_profile",onBackPressed: () async {
      if (model.isPersonalInfoEditable == true ||
          model.isCorporateAddressEditable == true) {


        final shouldLeave =
            await _showExitConfirmationDialog(context, model);


        if (shouldLeave == true) {
          Navigator.pop(context); // ✅ back
        }
      } else {
        Navigator.pop(context); // ✅ normal back
      }
    },);
  }

  Widget _buildPersonalInformationSection(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          image:
                              model.profileImageFile != null
                                  ? DecorationImage(
                                    image: FileImage(model.profileImageFile!),
                                    fit: BoxFit.cover,
                                  )
                                  : model.profileImageUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(model.profileImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                  : model.hasLogoFile
                                  ? DecorationImage(
                                    image: AssetImage(
                                      'assets/images/placeholder.png',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : model.logoUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(model.logoUrl),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            model.profileImageFile == null &&
                                    model.profileImageUrl.isEmpty &&
                                    !model.hasLogoFile &&
                                    model.logoUrl.isEmpty
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.gray,
                                )
                                : null,
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _showProfileImagePickerOptions(context, model);
                          },
                          child: Container(
                            padding: EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Image.asset(
                              AppImages.edit,
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Name and Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (model.profileModel?.profile?.user?.fullName != null &&
                                (model.profileModel!.profile?.user!.fullName!.toUpperCase()??'').isNotEmpty)
                            ? (model.profileModel!.profile?.user!.fullName!.toUpperCase()??'')
                            : model.yourNameController.text.isNotEmpty
                            ? model.yourNameController.text.toUpperCase()
                            : "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (model.profileModel?.profile?.user?.email != null &&
                                (model.profileModel!.profile?.user!.email!??'').isNotEmpty)
                            ? model.profileModel!.profile?.user!.email!??''
                            : model.emailController.text.isNotEmpty
                            ? model.emailController.text
                            : "",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: Text(
                  LanguageService.get("personal_information"),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              // Edit Details / Update Button
              CommonElevatedButton(
                onPressed: () {
                  model.togglePersonalInfoEdit();
                },
                label:
                    (model.isPersonalInfoEditable ?? false)
                        ? LanguageService.get("update")
                        : LanguageService.get("edit_details"),
                backgroundColor:
                    (model.isPersonalInfoEditable ?? false)
                        ? AppColors.success
                        : AppColors.primaryDark,
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
            ],
          ),
          const SizedBox(height: 15),

          // Organization Name (Read-only)
          CommonTextField(
            enabled: model.isPersonalInfoEditable ?? false,
            controller:model.yourNameController,
            label: LanguageService.get("organization_name"),
            placeholder: LanguageService.get("organization_name"),
            readOnly: !(model.isPersonalInfoEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Unit Name with info icon
          // Stack(
          //   children: [
          //     CommonTextField(
          //       controller: model.unitNameController,
          //       label: LanguageService.get("unit_name"),
          //       placeholder: LanguageService.get("unit_name"),
          //       readOnly: !(model.isPersonalInfoEditable ?? false),
          //       contentPadding: EdgeInsets.all(12),
          //       textStyle: const TextStyle(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     Positioned(
          //       right: 0,
          //       bottom: 2,
          //       child: Center(
          //         child: CustomPopup(
          //           content: Text(
          //             '''Use this to create and manage a new factory or unit under your\ncompany — such as a new location, branch, or brand in another country.''',
          //             style: TextStyle(
          //               color: AppColors.white,
          //               fontSize: 9,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //           position: PopupPosition.top,
          //           arrowColor: AppColors.textGrey,
          //           backgroundColor: AppColors.textGrey,
          //           child: Padding(
          //             padding: EdgeInsets.all(16),
          //             child: Image.asset(
          //               AppImages.alert,
          //               width: 16,
          //               height: 16,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),

          // Your Name
          CommonTextField(
            enabled: model.isPersonalInfoEditable ?? false,
            controller:  model.organizationNameController,
            label: LanguageService.get("your_name"),
            placeholder: LanguageService.get("your_name"),
            readOnly: !(model.isPersonalInfoEditable ?? false),
            contentPadding: EdgeInsets.all(12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AbsorbPointer(
            absorbing: !(model.isPersonalInfoEditable ?? false),

            child: _buildDropdownFormField(
              context,
              value: model.organizationType,
              label: LanguageService.get('processor_type'),
              items: [
                {"value": "Glass Processor", "display": LanguageService.get('glass_processor')},
                {"value": "Aluminum Processor", "display": LanguageService.get('aluminum_processor')},
                {"value": "UPVC Processor", "display": LanguageService.get('upvc_processor')},
                {"value": "Others", "display": LanguageService.get('others')},
              ],
              onChanged:model.updateOrganizationType,
              validator: (value) => value == null ? LanguageService.get('please_select_processor_type') : null,
            ),
          ),

          // Other description field (only if "Others" is selected)
          if (model.organizationType == "Others") ...[
            SizedBox(height: AppSizes.h16),
            _buildTextFormField(
              context,
              controller: model.otherDescriptionController,
              label: LanguageService.get('describe_your_organization'),
              validator: (value) => value?.isEmpty == true ? LanguageService.get('please_describe_your_organization') : null,
            ),
          ],

          SizedBox(height: AppSizes.h13),
          // Your Designation (Dropdown)
          _buildDesignationDropdown(context, model),
          const SizedBox(height: 16),

          // Primary Phone Number
          _buildPhoneFieldWithFlag(context, model),
          const SizedBox(height: 16),

          // Primary Email with verification
          CommonTextField(
            controller: model.emailController,
            label: LanguageService.get("primary_email"),
            placeholder: LanguageService.get("primary_email"),
            keyboardType: TextInputType.emailAddress,
            // enabled: model.profileModel?.profile?.user?.isEmailVerified??false,
            suffix: (model.profileModel?.profile?.user?.isEmailVerified??false) ? Image.asset(AppImages.verified, width: 22, height: 24):

            CommonElevatedButton(
              onPressed: () {
                model.sendVerificationEmail(model.emailController.text);
              },
              label:LanguageService.get("unverified"),
              backgroundColor: AppColors.warningRed,
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
            readOnly: (model.profileModel?.profile?.user?.isEmailVerified??false)?true:!(model.isPersonalInfoEditable ?? false),
            contentPadding: EdgeInsets.only(left: 12,right: 5),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Verification message
          Obx(()=>model.isEmailVarificationSend.value?Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              children: [
                Image.asset(
                  AppImages.alert,
                  width: 19,
                  height: 19,
                  color: AppColors.success,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LanguageService.get('verification_sent_message'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ):SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCorporateAddressSection(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single Edit Button for Both Addresses
          Row(
            children: [
              Expanded(
                child: Text(
                  LanguageService.get("address_section"),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              CommonElevatedButton(

                onPressed: () {
                  model.toggleCorporateAddressEdit();
                },
                label:
                    (model.isCorporateAddressEditable ?? false)
                        ? LanguageService.get("update")
                        : LanguageService.get("edit_details"),
                backgroundColor:
                    (model.isCorporateAddressEditable ?? false)
                        ? AppColors.success
                        : AppColors.primaryDark,
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
            ],
          ),
          const SizedBox(height: 20),

          Form(
            key: model.corporateAddressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.get("corporate_address"),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),

                CommonTextField(
                  enabled: model.isCorporateAddressEditable ?? false,
                  controller: model.addressLine1Controller,
                  label: LanguageService.get("address_line_1"),
                  placeholder: LanguageService.get("address_line_1"),
                  readOnly: !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (!(model.isCorporateAddressEditable ?? false)) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return LanguageService.get("please_enter_address_line_1");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                CommonTextField(
                  enabled: model.isCorporateAddressEditable ?? false,
                  controller: model.addressLine2Controller,
                  label: LanguageService.get("address_line_2"),
                  placeholder: LanguageService.get("address_line_2"),
                  readOnly: !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: !(model.isCorporateAddressEditable ?? false),
                        child: _buildCountryDropdown(
                          context,
                          model,
                          model.corporateCountryValue,
                          (value) {
                            model.updateCountry(value);
                            model.onCountryChanged(value ?? 'India');
                          },
                          !(model.isCorporateAddressEditable ?? false),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: !(model.isCorporateAddressEditable ?? false),
                        child: _buildStateDropdown(
                          context,
                          model,
                          model.selectedState,
                          (value) => model.updateState(value),
                          !(model.isCorporateAddressEditable ?? false),
                          model.availableStates,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        enabled: model.isCorporateAddressEditable ?? false,
                        controller: model.cityController,
                        label: LanguageService.get("city"),
                        placeholder: LanguageService.get("city"),
                        readOnly: !(model.isCorporateAddressEditable ?? false),
                        contentPadding: EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          if (!(model.isCorporateAddressEditable ?? false)) {
                            return null;
                          }
                          if (value == null || value.trim().isEmpty) {
                            return LanguageService.get("please_enter_city");
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CommonTextField(
                        enabled: model.isCorporateAddressEditable ?? false,
                        controller: model.pinCodeController,
                        label: LanguageService.get("pin_code"),
                        placeholder: LanguageService.get("pin_code"),
                        readOnly: !(model.isCorporateAddressEditable ?? false),
                        contentPadding: EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          if (!(model.isCorporateAddressEditable ?? false)) {
                            return null;
                          }
                          if (value == null || value.trim().isEmpty) {
                            return LanguageService.get("please_enter_pin_code");
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          Form(
            key: model.factoryAddressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.get("factory_address"),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 9),

                Row(
                  children: [
                    Checkbox(
                      value: model.sameAsCorpAddress,
                      onChanged:
                          (model.isCorporateAddressEditable ?? false)
                              ? (value) => model.toggleSameAsCorpAddress(
                                value ?? false,
                              )
                              : null,
                    ),
                    SizedBox(width: 6),
                    Text(
                      LanguageService.get("same_as_corporate_address"),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                CommonTextField(
                  enabled: model.isCorporateAddressEditable ?? false,
                  controller: model.factoryAddressLine1Controller,
                  label: LanguageService.get("address_line_1"),
                  placeholder: LanguageService.get("address_line_1"),
                  readOnly:
                      model.sameAsCorpAddress ||
                      !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (model.sameAsCorpAddress ||
                        !(model.isCorporateAddressEditable ?? false)) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return LanguageService.get("please_enter_address_line_1");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                CommonTextField(
                  enabled: model.isCorporateAddressEditable ?? false,
                  controller: model.factoryAddressLine2Controller,
                  label: LanguageService.get("address_line_2"),
                  placeholder: LanguageService.get("address_line_2"),
                  readOnly:
                      model.sameAsCorpAddress ||
                      !(model.isCorporateAddressEditable ?? false),
                  contentPadding: EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing:
                            model.sameAsCorpAddress ||
                            !(model.isCorporateAddressEditable ?? false),
                        child: _buildCountryDropdown(
                          context,
                          model,
                          model.factoryCountryValue,
                          (value) {
                            model.updateFactoryCountry(value);
                            model.onFactoryCountryChanged(value ?? 'India');
                          },
                          model.sameAsCorpAddress ||
                              !(model.isCorporateAddressEditable ?? false),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: AbsorbPointer(
                        absorbing:
                            model.sameAsCorpAddress ||
                            !(model.isCorporateAddressEditable ?? false),
                        child: _buildStateDropdown(
                          context,
                          model,
                          model.selectedFactoryState,
                          (value) => model.updateFactoryState(value),
                          model.sameAsCorpAddress ||
                              !(model.isCorporateAddressEditable ?? false),
                          model.availableFactoryStates,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        enabled: model.isCorporateAddressEditable ?? false,
                        controller: model.factoryCityController,
                        label: LanguageService.get("city"),
                        placeholder: LanguageService.get("city"),
                        readOnly:
                            model.sameAsCorpAddress ||
                            !(model.isCorporateAddressEditable ?? false),
                        contentPadding: EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          if (model.sameAsCorpAddress ||
                              !(model.isCorporateAddressEditable ?? false)) {
                            return null;
                          }
                          if (value == null || value.trim().isEmpty) {
                            return LanguageService.get("please_enter_city");
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: CommonTextField(
                        enabled: model.isCorporateAddressEditable ?? false,
                        controller: model.factoryPinCodeController,
                        label: LanguageService.get("pin_code"),
                        placeholder: LanguageService.get("pin_code"),
                        readOnly:
                            model.sameAsCorpAddress ||
                            !(model.isCorporateAddressEditable ?? false),
                        contentPadding: EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) {
                          if (model.sameAsCorpAddress ||
                              !(model.isCorporateAddressEditable ?? false)) {
                            return null;
                          }
                          if (value == null || value.trim().isEmpty) {
                            return LanguageService.get("please_enter_pin_code");
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Factory Address Section removed - now part of corporate address section

  // Widget _buildDesignationDropdown(
  //   BuildContext context,
  //   UpdateOrganizationViewModel model,
  // ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         LanguageService.get("your_designation"),
  //         style: const TextStyle(
  //           fontSize: 12,
  //           color: AppColors.textGrey,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       SizedBox(
  //         height: 46,
  //         width: double.infinity,
  //         child: AbsorbPointer(
  //
  //           absorbing: !(model.isPersonalInfoEditable ?? false),
  //           child: DropdownFlutter<String>(
  //             closedHeaderPadding: EdgeInsets.all(12),
  //             items: const ["MD", "CEO", "Chairman", "Other"],
  //             onChanged:
  //                 (model.isPersonalInfoEditable ?? false)
  //                     ? (value) {
  //                       model.updateDesignationType(value);
  //                       if (value == 'Other') {
  //                         model.showOtherDesignation = true;
  //                       } else {
  //                         model.showOtherDesignation = false;
  //                       }
  //                     }
  //                     : null,
  //             initialItem: _getValidInitialItem(model.designationType),
  //             hintText: LanguageService.get('select_designation'),
  //             decoration: CustomDropdownDecoration(
  //               headerStyle: TextStyle(
  //                 fontSize: 14,
  //                 color:
  //                     (model.isPersonalInfoEditable ?? false)
  //                         ? AppColors.black
  //                         : AppColors.textGrey,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               hintStyle: const TextStyle(
  //                 fontSize: 12,
  //                 color: AppColors.textGrey,
  //               ),
  //               // closedBorder: Border.all(color: AppColors.lightGrey),
  //               expandedBorder: Border.all(color: AppColors.primary),
  //               expandedFillColor: AppColors.white,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDesignationDropdown(
      BuildContext context,
      UpdateOrganizationViewModel model,
      ) {
    final List<String> designationItems = ["MD", "CEO", "Chairman", "Other"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get("your_designation"),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 55,
          child: CustomDropdownFormField<String>(
            label: LanguageService.get("your_designation"),
            //hintText: LanguageService.get('select_designation'),
            value: _getValidInitialItem(model.designationType),

            // 1. Convert your List<String> to List<DropdownMenuItem<String>>
            items: designationItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),

            // 2. This logic is the same and will automatically
            //    disable the field if 'isPersonalInfoEditable' is false.
            onChanged: (model.isPersonalInfoEditable ?? false)
                ? (value) {
              model.updateDesignationType(value);
              if (value == 'Other') {
                model.showOtherDesignation = true;
              } else {
                model.showOtherDesignation = false;
              }
            }
                : null,

            // 3. Added a validator for consistency
            validator: (value) => value == null
                ? LanguageService.get('please_select_designation')
                : null,
          ),
        ),
      ],
    );
  }
  Widget _buildPhoneFieldWithFlag(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get("primary_phone_number"),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing:(model.profileModel?.profile?.user?.isPhoneVerified??false)?true:!(model.isPersonalInfoEditable ?? false) ,
          child: PhoneInput(
            flagShape: BoxShape.rectangle,
            enabled: (model.profileModel?.profile?.user?.isPhoneVerified??false)?false:!(model.isPersonalInfoEditable ?? true),
            defaultCountry:
                _mapCountryCodeToIso(model.profileModel?.profile?.user?.countryCode) ??
                IsoCode.IN,
            initialValue:
                (model.profileModel?.profile?.user?.phone != null &&
                        (model.profileModel!.profile?.user?.phone!??'').isNotEmpty)
                    ? PhoneNumber(
                      isoCode:
                          _mapCountryCodeToIso(
                            model.profileModel?.profile?.user?.countryCode,
                          ) ??
                          IsoCode.IN,
                      nsn: _extractNationalNumber(
                        model.profileModel!.profile?.user?.phone??'',
                        model.profileModel?.profile?.user?.countryCode,
                      ),
                    )
                    : null,
            key: ValueKey(
              'org_phone_${model.profileModel?.profile?.user?.countryCode}_${model.profileModel?.profile?.user?.phone}',
            ),
            countrySelectorNavigator: CountrySelectorNavigator.dialog(
              countryCodeStyle: const TextStyle(color: AppColors.black),
              countryNameStyle: const TextStyle(color: AppColors.black),
              searchInputTextStyle: const TextStyle(color: AppColors.textGrey),
              searchInputDecoration: InputDecoration(
                hintText: LanguageService.get('search_country'),
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            onChanged:
                (model.isPersonalInfoEditable ?? false)
                    ? (phone) {
                      if (phone != null) {
                        // Convert phone_input PhoneNumber to the format expected by the model
                        model.updatePhoneNumberFromString(
                          '${phone.countryCode}${phone.nsn}',
                        );
                      }
                    }
                    : null,

            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(AppImages.verified, width: 22, height: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _getValidInitialItem(String? designationType) {
    const List<String> validItems = ["MD", "CEO", "Chairman", "Other"];

    if (designationType != null && validItems.contains(designationType)) {
      return designationType;
    }
    return null;
  }

  // Widget _buildUnitsSection(
  //     BuildContext context,
  //     UpdateOrganizationViewModel model,
  //     ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildSectionTitle(context, LanguageService.get("factory_office_manufacturing_Location")),
  //         ],
  //       ),
  //       SizedBox(height: AppSizes.h20),
  //       ...List.generate(model.units.length, (index) {
  //         return _buildUnitCard(context, model, index);
  //       }),
  //       SizedBox(height: AppSizes.h10),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           TextButton.icon(
  //             onPressed: model.addUnit,
  //             icon: Icon(Icons.add, color: AppColors.primary),
  //             label: Text(LanguageService.get("add"), style: TextStyle(color: AppColors.primary)),
  //           ),
  //         ],
  //       ),
  //       if (model.units.isEmpty)
  //         Container(
  //           padding: EdgeInsets.all(AppSizes.w20),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: AppColors.lightGrey),
  //             borderRadius: BorderRadius.circular(AppSizes.v12),
  //           ),
  //           child: Column(
  //             children: [
  //               Icon(
  //                 Icons.business_outlined,
  //                 size: AppSizes.v48,
  //                 color: AppColors.gray,
  //               ),
  //               SizedBox(height: AppSizes.h8),
  //               Text(
  //                 LanguageService.get("no_units_added"),
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gray),
  //               ),
  //               Text(
  //                 LanguageService.get("add_units_manage_locations"),
  //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildCountryDropdown(
    BuildContext context,
    UpdateOrganizationViewModel model,
    String? selectedValue,
    Function(String?) onChanged,
    bool isReadOnly,
  ) {
    String? validSelectedValue = selectedValue;
    if (selectedValue != null &&
        selectedValue.isNotEmpty &&
        !model.countries.contains(selectedValue)) {
      validSelectedValue = null;
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
          items: model.countries.map((String country) {
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
        )
      ],
    );
  }

  Widget _buildStateDropdown(
    BuildContext context,
    UpdateOrganizationViewModel model,
    String? selectedValue,
    Function(String?) onChanged,
    bool isReadOnly,
    List<String> statesList, // Direct states list parameter
  ) {
    String? validSelectedValue = selectedValue;
    if (selectedValue != null &&
        selectedValue.isNotEmpty &&
        !statesList.contains(selectedValue)) {
      validSelectedValue = null;
    }

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
          value: validSelectedValue,
          items: statesList.map((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: isReadOnly ? null : onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LanguageService.get('please_select_state');
            }
            return null;
          },
        )
      ],
    );
  }

  void _showProfileImagePickerOptions(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Draggable handle
            Container(
              width: 47,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.textGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 15),

            // Two options arranged horizontally
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildOptionButton(
                  iconPath: AppImages.gallery,
                  label: 'Album',
                  color: AppColors.turquoiseBlue,
                  onTap: () {
                    Get.back();
                    model.pickProfileImageFromGallery();
                  },
                ),
                SizedBox(width: 20),
                _buildOptionButton(
                  iconPath: AppImages.camera,
                  label: 'Camera',
                  color: AppColors.greenbackground,
                  onTap: () {
                    Get.back();
                    model.takeProfilePhoto();
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String iconPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(iconPath, width: 24, height: 25, color: color),
          ),
          SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextFormField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        TextInputType keyboardType = TextInputType.text,
        Widget? suffix,
        String? Function(String?)? validator,
      }) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red, width: 2)),
        ),
        validator: validator,
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
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: value,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red, width: 2)),
        ),
        dropdownColor: AppColors.white,
        style: Theme.of(context).textTheme.bodyLarge,
        items:
        items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(value: item['value'], child: Text(item['display']!));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
  // Show exit confirmation dialog when data is being edited
  Future<bool?> _showExitConfirmationDialog(
    BuildContext context,
    UpdateOrganizationViewModel model,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            LanguageService.get("unsaved_changes"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          content: Text(
            LanguageService.get("do_you_want_to_save"),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Discard changes
              },
              child: Text(
                LanguageService.get("discard"),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Save changes based on which section is being edited
                if (model.isPersonalInfoEditable == true) {
                  await model.updatePersonalInfo();
                }
                if (model.isCorporateAddressEditable == true) {
                  final isSaved = await model.submitAddressSection();
                  if (!isSaved) {
                    return;
                  }
                }
                Navigator.of(context).pop(true); // Allow navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                LanguageService.get("save"),
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Extract national number from phone number
  String _extractNationalNumber(String phoneNumber, String? countryCode) {
    if (phoneNumber.isEmpty) return '';

    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If country code is provided, try to remove it
    if (countryCode != null && countryCode.isNotEmpty) {
      String cleanCountryCode = countryCode.replaceAll(RegExp(r'[^\d]'), '');

      // Check if the phone number starts with the country code
      if (cleanNumber.startsWith(cleanCountryCode)) {
        // Remove the country code from the beginning
        cleanNumber = cleanNumber.substring(cleanCountryCode.length);
      }
    }

    return cleanNumber;
  }

  // Map country code string to IsoCode
  IsoCode? _mapCountryCodeToIso(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) return IsoCode.IN;

    // Remove + if present
    String cleanCode = countryCode.replaceAll('+', '');

    // Map common country codes to IsoCode
    switch (cleanCode) {
      case '91':
        return IsoCode.IN;
      case '1':
        return IsoCode.US;
      case '44':
        return IsoCode.GB;
      case '33':
        return IsoCode.FR;
      case '49':
        return IsoCode.DE;
      case '86':
        return IsoCode.CN;
      case '81':
        return IsoCode.JP;
      case '82':
        return IsoCode.KR;
      case '61':
        return IsoCode.AU;
      case '55':
        return IsoCode.BR;
      case '7':
        return IsoCode.RU;
      case '39':
        return IsoCode.IT;
      case '34':
        return IsoCode.ES;
      case '31':
        return IsoCode.NL;
      case '46':
        return IsoCode.SE;
      case '47':
        return IsoCode.NO;
      case '45':
        return IsoCode.DK;
      case '41':
        return IsoCode.CH;
      case '43':
        return IsoCode.AT;
      case '32':
        return IsoCode.BE;
      case '48':
        return IsoCode.PL;
      case '420':
        return IsoCode.CZ;
      case '421':
        return IsoCode.SK;
      case '36':
        return IsoCode.HU;
      case '40':
        return IsoCode.RO;
      case '359':
        return IsoCode.BG;
      case '385':
        return IsoCode.HR;
      case '386':
        return IsoCode.SI;
      case '372':
        return IsoCode.EE;
      case '371':
        return IsoCode.LV;
      case '370':
        return IsoCode.LT;
      case '353':
        return IsoCode.IE;
      case '351':
        return IsoCode.PT;
      case '30':
        return IsoCode.GR;
      case '357':
        return IsoCode.CY;
      case '356':
        return IsoCode.MT;
      case '352':
        return IsoCode.LU;
      default:
        return IsoCode.IN; // Default to India
    }
  }
}
