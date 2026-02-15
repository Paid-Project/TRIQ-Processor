import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/resources/app_resources/app_maps.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/utils/app_logger.dart';
import '../../../services/auth.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class RegisterViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final authService = locator<AuthService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otherDescriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Employee manager only handles employee registration
  bool get isOrganization => false;

  String? _organizationType;

  String? get organizationType => _organizationType;

  String? _language = "English";

  String? get language => _language;

  bool _isFormValid = false;

  bool get isFormValid => _isFormValid;

  bool _didAgree = true;

  bool get didAgree => _didAgree;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  String _fullPhoneNumber = '';

  String get fullPhoneNumber => _fullPhoneNumber;

  String _countryCode = '';

  String get countryCode => _countryCode;

  void init() {
    nameController.addListener(_updateFormValidity);
    otherDescriptionController.addListener(_updateFormValidity);
    emailController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
  }

  // Removed setRegistrationType - employee manager only handles employee registration

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.number;
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateOrganizationType(String? value) {
    _organizationType = value;
    if (value != "Others") {
      otherDescriptionController.clear();
    }
    _updateFormValidity();
    notifyListeners();
  }

  void updateLanguage(String? value) {
    _language = value;
    _updateFormValidity();
    notifyListeners();
  }

  void toggleAgree(bool? didAgree) {
    _didAgree = !_didAgree;
    _updateFormValidity();
    notifyListeners();
  }

  void _updateFormValidity() {
    // Employee validation only
    bool isValid =
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        didAgree;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  void onSubmitForm() async {
    if (formKey.currentState?.validate() == true && _isFormValid) {
      AppLogger.info("Form is valid! Submitting...");

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await authService.sendOtpForRegistration(value: phoneController.text,countryCode: countryCode);

              return apiResponse;
            } catch (e) {
              AppLogger.error('Error sending OTP: $e');
              rethrow;
            }
          },
          message: "Sending OTP...",
        ),
      );

      if (response?.confirmed == true) {
        final result = response?.data;
        if (result is Right) {
          // Prepare organization type for registration
          String finalOrgType = _organizationType!;
          if (_organizationType == "Others" && otherDescriptionController.text.isNotEmpty) {
            finalOrgType = "Others: ${otherDescriptionController.text}";
          }

          _navigationService.navigateTo(
            Routes.otpVerification,
            arguments: OtpVerificationViewAttributes(
              isOrganization: false,
              email: emailController.text,
              fullName: nameController.text,
              phone: _fullPhoneNumber,
              countryCode: _countryCode,
              password: passwordController.text,
              organizationType: finalOrgType,
              otherDescription: otherDescriptionController.text.isNotEmpty ? otherDescriptionController.text : null,
              language: AppMaps.languageMap[_language] ?? "English",
            ),
          );
        } else if (result is Left) {
          final failure = result.fold((l) => l, (r) => null);
          if (failure != null) {
            Fluttertoast.showToast(msg: failure.message);
          }
        }
      }
    } else {
      AppLogger.error("Form is invalid!");
      Fluttertoast.showToast(msg: 'Form is invalid');
    }
  }

  // Removed registerEmployee - now using sendOtpForRegistration instead

  @override
  void dispose() {
    nameController.dispose();
    otherDescriptionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
