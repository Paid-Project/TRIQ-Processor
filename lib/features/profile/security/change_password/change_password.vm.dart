import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/services/auth.service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/services/language.service.dart';

import '../../../../core/models/hive/user/user.dart';
import '../../../../core/storage/storage.dart';

class ChangePasswordViewModel extends BaseViewModel {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final authService=locator.get<AuthService>();

  // Text controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password visibility states
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Getters
  bool get isOldPasswordVisible => _isOldPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => isBusy;

  // Password visibility toggles
  void toggleOldPasswordVisibility() {
    _isOldPasswordVisible = !_isOldPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // Change password method
  Future<void> changePassword(BuildContext context) async {
    // Validate form first
    if (newPasswordController.text != confirmPasswordController.text) {
      _showError("Password Do Not Match");
      return;
    }

    User user=getUser();
    try {
      setBusy(true);
      await authService.resetNewPassword(
        email: user.email??'',
        newPassword: newPasswordController.text.trim(),
        oldPassword: oldPasswordController.text.trim(),
        isMobile: false,
      );
      _showSuccess(LanguageService.get("password_changed_successfully"));
      _clearForm();

    } catch (e) {
      _showError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  // Helper methods
  void _showError(String message) {
    // TODO: Implement error dialog or use snackbar
    print('Error: $message');
  }

  void _showSuccess(String message) {
    // TODO: Implement success dialog or use snackbar
    print('Success: $message');
  }

  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _isOldPasswordVisible = false;
    _isNewPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
