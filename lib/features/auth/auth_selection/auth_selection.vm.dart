import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../routes/routes.dart';

class AuthSelectionViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void init() {
    // Initialize any required data or check authentication state
    notifyListeners();
  }

  /// Navigate to Sign Up page/flow
  Future<void> navigateToSignUp() async {
    await _navigationService.navigateTo(Routes.register);
  }

  /// Navigate to Login page
  Future<void> navigateToLogin() async {
    await _navigationService.navigateTo(Routes.login);
  }

  /// Navigate to Terms of Service
  Future<void> navigateToTermsOfService() async {
    // Implement navigation to terms of service page
    // await _navigationService.navigateTo(Routes.termsOfService);
  }

  /// Navigate to Privacy Policy
  Future<void> navigateToPrivacyPolicy() async {
    // Implement navigation to privacy policy page
    // await _navigationService.navigateTo(Routes.privacyPolicy);
  }

  @override
  void dispose() {
    super.dispose();
  }
}