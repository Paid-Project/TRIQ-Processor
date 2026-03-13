import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/features/auth/register/register.vm.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common/custom_dropdown.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(),
      onViewModelReady: (RegisterViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, RegisterViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight - MediaQuery.of(context).padding.vertical - kToolbarHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w13),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSizes.h12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start, // This moves items to the top
                            children: [_buildBackButton(context), _buildHeaderSection(context, model)],
                          ),
                          Column(children: [_buildRegistrationForm(context, model), _buildSignInLink(context)]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, RegisterViewModel model) {
    return Column(
      children: [
        SizedBox(height: 220, width: 250, child: Image.asset('assets/images/auth3.png', fit: BoxFit.contain)),
        SizedBox(height: AppSizes.h2),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context, RegisterViewModel model) {
    return Form(
      key: model.formKey,
      child: Column(
        children: [
          _buildTextFormField(
            context,
            controller: model.nameController,
            label: LanguageService.get('enter_your_company_name'),
            suffix: CustomPopup(
              content: Text(
                '''This Login is only for Processor''',
                style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w500),
              ),
              position: PopupPosition.top,
              arrowColor: AppColors.textGrey,
              backgroundColor: AppColors.textGrey,
              child: Padding(padding: EdgeInsets.all(16), child: Image.asset(AppImages.alert, width: 16, height: 16)),
            ),
            validator: (value) => value?.isEmpty == true ? LanguageService.get('please_enter_name') : null,
          ),

          // Organization type dropdown
          SizedBox(height: AppSizes.h13),
          CustomDropdownFormField<String>( // <-- 1. Specify the type
            value: model.organizationType,
            label: LanguageService.get('processor_type'),

            // 2. Convert the 'items' list to DropdownMenuItems
            items: [
              DropdownMenuItem<String>(
                value: "Glass Processor",
                child: Text(LanguageService.get('glass_processor')),
              ),
              DropdownMenuItem<String>(
                value: "Aluminum Processor",
                child: Text(LanguageService.get('aluminum_processor')),
              ),
              DropdownMenuItem<String>(
                value: "UPVC Processor",
                child: Text(LanguageService.get('upvc_processor')),
              ),
              DropdownMenuItem<String>(
                value: "Others",
                child: Text(LanguageService.get('others')),
              ),
            ],
            onChanged: model.updateOrganizationType,
            validator: (value) => value == null
                ? LanguageService.get('please_select_processor_type')
                : null,
          ),
          // Other description field (only if "Others" is selected)
          if (model.organizationType == "Others") ...[
            SizedBox(height: AppSizes.h13),
            _buildTextFormField(
              context,
              controller: model.otherDescriptionController,
              label: LanguageService.get('describe_your_organization'),
              validator: (value) => value?.isEmpty == true ? LanguageService.get('please_describe_your_organization') : null,
            ),
          ],

          SizedBox(height: AppSizes.h13),
          _buildTextFormField(
            context,
            controller: model.emailController,
            label: LanguageService.get('email'),
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

          SizedBox(height: AppSizes.h13),
          SizedBox(
            height: 60,
            child: IntlPhoneField(
              controller: model.phoneController,
              pickerDialogStyle: PickerDialogStyle(
                backgroundColor: AppColors.white,
                countryCodeStyle: TextStyle(color: AppColors.black),
                countryNameStyle: TextStyle(color: AppColors.black),
              ),
              decoration: InputDecoration(
                labelText: LanguageService.get('phone_number'),
                labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v13), borderSide: BorderSide(color: AppColors.lightGrey)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v13),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v13),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                model.updatePhoneNumber(phone);
              },
              validator: (phone) {
                if (phone == null || phone.number.isEmpty) {
                  return LanguageService.get('please_enter_phone_number');
                }
                return null;
              },
            ),
          ),

          SizedBox(height: AppSizes.h5),
          _buildPasswordFormField(
            context,
            controller: model.passwordController,
            obscureText: model.obscurePassword,
            onToggleVisibility: model.togglePassword,
            onFieldSubmitted: (_) => model.onSubmitForm(),
          ),

          SizedBox(height: AppSizes.h15),
          _buildSubmitButton(context, model),
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

  // Widget _buildDropdownFormField(
  //   BuildContext context, {
  //   required String? value,
  //   required String label,
  //   required List<Map<String, String>> items,
  //   required void Function(String?)? onChanged,
  //   String? Function(String?)? validator,
  // }) {
  //   return SizedBox(
  //     height: 50,
  //     child: DropdownButtonFormField<String>(
  //       value: value,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
  //         floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
  //         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
  //         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
  //         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.primary, width: 2)),
  //         errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red)),
  //         focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red, width: 2)),
  //       ),
  //       dropdownColor: AppColors.white,
  //       style: Theme.of(context).textTheme.bodyLarge,
  //       items:
  //           items.map((Map<String, String> item) {
  //             return DropdownMenuItem<String>(value: item['value'], child: Text(item['display']!));
  //           }).toList(),
  //       onChanged: onChanged,
  //       validator: validator,
  //     ),
  //   );
  // }

  Widget _buildPasswordFormField(
    BuildContext context, {
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    void Function(String)? onFieldSubmitted,
  }) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: LanguageService.get('password'),
          labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
          floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.gray),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.red, width: 2)),
        ),
        validator: (value) => value?.isEmpty == true ? LanguageService.get('please_enter_password') : null,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, RegisterViewModel model) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: model.onSubmitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 4,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          LanguageService.get("continue"),
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LanguageService.get('already_have_account'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          SizedBox(width: AppSizes.w8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              LanguageService.get('sign_in'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: Container(
      margin: EdgeInsets.only(top: 5), // Add margin for proper spacing
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        shape: BoxShape.circle, // Makes it circular
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
        // Adjust padding for better circle appearance
      ),
    ),
  );
}
