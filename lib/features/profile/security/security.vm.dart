import 'package:stacked/stacked.dart';
import 'package:get/get.dart';
import 'package:manager/services/language.service.dart';

class SecurityViewModel extends BaseViewModel {
  bool _isBiometricEnabled = false;

  bool get isBiometricEnabled => _isBiometricEnabled;

  void init() {
    // Initialize biometric state - could be loaded from storage
    _isBiometricEnabled = false;
    notifyListeners();
  }

  void navigateToChangePassword() {
    // TODO: Navigate to change password screen
    Get.snackbar(
      '',
      'Change Password feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleBiometric(bool value) {
    _isBiometricEnabled = value;
    notifyListeners();

    // TODO: Implement actual biometric toggle functionality
    Get.snackbar(
      '',
      value
          ? LanguageService.get("fingerprint_face_id_login") + ' enabled'
          : LanguageService.get("fingerprint_face_id_login") + ' disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
