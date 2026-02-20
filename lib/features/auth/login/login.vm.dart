import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:restart_app/restart_app.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/saved_account.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/account.service.dart';
import '../../../services/auth.service.dart';

enum LoginMode { email, phone }

enum ForgotPasswordStep { contact, otp, newPassword }

class LoginViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final authService = locator<AuthService>();
  final AccountManagerService _accountManager = AccountManagerService.instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController forgotOtpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController forgotPhoneController = TextEditingController();

  // OTP controllers for individual digits
  final List<TextEditingController> otpDigitControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());

  // Forgot password OTP controllers for individual digits
  final List<TextEditingController> forgotOtpDigitControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> forgotOtpFocusNodes = List.generate(6, (index) => FocusNode());

  // Login mode state
  LoginMode _loginMode = LoginMode.email;

  LoginMode get loginMode => _loginMode;

  // Forgot password mode state
  LoginMode _forgotPasswordMode = LoginMode.phone;

  LoginMode get forgotPasswordMode => _forgotPasswordMode;
  // Form validation
  bool _isOTPWithLogin = false;

  bool get isOTPWithLogin => _isOTPWithLogin;
  // Saved accounts state
  List<SavedAccount> _savedAccounts = [];

  List<SavedAccount> get savedAccounts => _savedAccounts;

  bool _showAllAccounts = true;

  bool get showAllAccounts => _showAllAccounts;

  bool _showLoginFormSection = false;

  bool get showLoginFormSection => _showLoginFormSection;

  // Form validation
  bool _isFormValid = true;

  bool get isFormValid => _isFormValid;

  // UI state
  bool _willRemember = true;

  bool get willRemember => _willRemember;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  bool _obscureNewPassword = true;

  bool get obscureNewPassword => _obscureNewPassword;

  bool _obscureConfirmPassword = true;

  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool _showOtpField = false;

  bool get showOtpField => _showOtpField;

  bool _showForgotPassword = false;

  bool get showForgotPassword => _showForgotPassword;

  bool _showOtpLogin = false;

  bool get showOtpLogin => _showOtpLogin;

  bool _isBusyForgotPassword = false;

  bool get isBusyForgotPassword => _isBusyForgotPassword;

  // Forgot password flow state
  ForgotPasswordStep _forgotPasswordStep = ForgotPasswordStep.contact;

  ForgotPasswordStep get forgotPasswordStep => _forgotPasswordStep;

  // OTP timer for forgot password
  int _resendForgotTimer = 0;

  bool get canResendForgotOtp => _resendForgotTimer == 0;

  int get resendForgotTimer => _resendForgotTimer;
  Timer? _forgotTimer;

  // OTP timer for login
  int _resendTimer = 0;

  bool get canResendOtp => _resendTimer == 0;

  int get resendTimer => _resendTimer;
  Timer? _timer;

  void init() async {
    emailController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    otpController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    // Add listeners for OTP digit controllers
    for (int i = 0; i < otpDigitControllers.length; i++) {
      otpDigitControllers[i].addListener(() => _updateOtpFromDigits());
    }

    for (int i = 0; i < forgotOtpDigitControllers.length; i++) {
      forgotOtpDigitControllers[i].addListener(() => _updateForgotOtpFromDigits());
    }

    notifyListeners();

    Future.delayed(Duration(milliseconds: 100), () async {
      _loadSavedAccounts();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    forgotEmailController.dispose();
    forgotOtpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    forgotPhoneController.dispose();

    // Dispose OTP controllers and focus nodes
    for (var controller in otpDigitControllers) {
      controller.dispose();
    }
    for (var controller in forgotOtpDigitControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in forgotOtpFocusNodes) {
      focusNode.dispose();
    }

    _timer?.cancel();
    _forgotTimer?.cancel();
    super.dispose();
  }

  // Update OTP controller from individual digit controllers
  void _updateOtpFromDigits() {
    String otp = otpDigitControllers.map((controller) => controller.text).join();
    otpController.text = otp;
    _updateFormValidity();
  }

  void _updateForgotOtpFromDigits() {
    String otp = forgotOtpDigitControllers.map((controller) => controller.text).join();
    forgotOtpController.text = otp;
  }

  // Handle OTP digit input
  void onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify if all digits are filled
    // if (index == 5 && value.isNotEmpty) {
    //   String fullOtp = otpDigitControllers.map((controller) => controller.text).join();
    //   if (fullOtp.length == 6) {
    //     verifyOtp();
    //   }
    // }
  }

  void onForgotOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      forgotOtpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      forgotOtpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify if all digits are filled
    // if (index == 5 && value.isNotEmpty) {
    //   String fullOtp = forgotOtpDigitControllers.map((controller) => controller.text).join();
    //   if (fullOtp.length == 6) {
    //     verifyPasswordResetOtp();
    //   }
    // }
  }

  // Clear OTP digits
  void _clearOtpDigits() {
    for (var controller in otpDigitControllers) {
      controller.clear();
    }
    otpController.clear();
  }

  void _clearForgotOtpDigits() {
    for (var controller in forgotOtpDigitControllers) {
      controller.clear();
    }
    forgotOtpController.clear();
  }

  // Saved accounts functionality
  void _loadSavedAccounts() {
    _accountManager.debugBoxStatus();
    _savedAccounts = _accountManager.getSavedAccounts();
    AppLogger.info('Loaded saved accounts: ${_savedAccounts.length}');
    for (var account in _savedAccounts) {
      AppLogger.info('Account: ${account.toJson()}');
    }
    _showLoginFormSection = _savedAccounts.isNotEmpty;
    notifyListeners();
  }

  List<SavedAccount> getDisplayedSavedAccounts() {
    if (_showAllAccounts) {
      return _savedAccounts;
    }
    return _savedAccounts.take(3).toList();
  }

  void toggleShowAllAccounts() {
    _showAllAccounts = !_showAllAccounts;
    notifyListeners();
  }

  void showLoginForm() {
    _showLoginFormSection = true;
    notifyListeners();
  }

  void hideLoginForm() {
    _showLoginFormSection = false;
    // Clear form when hiding
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  Future<void> loginWithSavedAccount(SavedAccount account) async {
    setBusy(true);

    try {
      // Update last login time
      await _accountManager.updateLastLogin(account.email);

      // Set email in controller
      emailController.text = account.email;

      // Call your Google login since backend is configured for Google auth
      final response = await googleLogin();

      response.fold(
        (failure) {
          Fluttertoast.showToast(msg: failure.message);
        },
        (user) async {
          await saveUser(user);
          navigateToStageView();
        },
      );
    } catch (e) {
      AppLogger.error('Saved account login error: $e');
      Fluttertoast.showToast(msg: 'Login failed. Please try again.');
    } finally {
      setBusy(false);
    }
  }

  Future<void> removeSavedAccount(String email) async {
    await _accountManager.removeSavedAccount(email);
    _loadSavedAccounts();
    Fluttertoast.showToast(msg: 'Account removed');
  }

  // Login mode switching
  void setLoginMode(LoginMode mode) {
    _loginMode = mode;

    _showOtpField = false;
    _showForgotPassword = false;
    _showOtpLogin = false;
    _clearOtpDigits();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    notifyListeners();
  }

  void setLoginOtpMode(LoginMode mode) {
    _showOtpField = false;
    _showForgotPassword = false;
    _showOtpLogin = true;
    _clearOtpDigits();
    notifyListeners();
  }

  // Forgot password mode switching
  void setForgotPasswordMode(LoginMode mode) {
    _forgotPasswordMode = mode;
    forgotEmailController.clear();
    forgotPhoneController.clear();
    notifyListeners();
  }

  // Form state management
  void toggleRemember(bool? didAgree) {
    _willRemember = !_willRemember;
    notifyListeners();
  }

  void togglePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleNewPassword() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void toggleForgotPassword() {
    _showOtpField = false;
    _showForgotPassword = !_showForgotPassword;
    if (!_showForgotPassword) {
      _resetForgotPasswordState();
    }
    notifyListeners();
  }

  void toggleOtpLogin() {
    _showOtpLogin = !_showOtpLogin;
    _showForgotPassword = false;
    _forgotPasswordStep = ForgotPasswordStep.contact;
    notifyListeners();
    if (!_showOtpLogin) {
      _resetShowOtpLogin();
    }
    notifyListeners();
  }
  void toggleOtpWithLogin() {
    _showOtpLogin = !_showOtpLogin;
    // _showForgotPassword = false;
    _isOTPWithLogin  = true;
    // _forgotPasswordStep = ForgotPasswordStep.contact;
    notifyListeners();
    if (!_showOtpLogin) {
      _resetShowOtpLogin();
    }
    notifyListeners();
  }

  void _resetForgotPasswordState() {
    _forgotPasswordStep = ForgotPasswordStep.contact;
    _forgotPasswordMode = LoginMode.email;
    forgotEmailController.clear();
    forgotPhoneController.clear();
    _clearForgotOtpDigits();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _forgotTimer?.cancel();
    _resendForgotTimer = 0;
  }

  void _resetShowOtpLogin() {
    _showOtpField = false;
    _clearOtpDigits();
    _timer?.cancel();
    _resendTimer = 0;
  }

  void _updateFormValidity() {
    bool isValid = false;

    if (_loginMode == LoginMode.email) {
      if (_showOtpField) {
        isValid = emailController.text.isNotEmpty && otpController.text.length == 6;
      } else {
        isValid = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
      }
    } else if (_loginMode == LoginMode.phone) {
      if (_showOtpField) {
        isValid = phoneController.text.isNotEmpty && otpController.text.length == 6;
      } else {
        isValid = phoneController.text.isNotEmpty && passwordController.text.isNotEmpty;
      }
    }

    _isFormValid = isValid;
    notifyListeners();
  }

  String _fullPhoneNumber = '';

  String get fullPhoneNumber => _fullPhoneNumber;

  String _countryCode = '';

  String get countryCode => _countryCode;

  String _forgotFullPhoneNumber = '';

  String get forgotFullPhoneNumber => _forgotFullPhoneNumber;

  String _forgotCountryCode = '';

  String get forgotCountryCode => _forgotCountryCode;

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _fullPhoneNumber = phoneNumber.number;
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void updateForgotPhoneNumber(PhoneNumber phoneNumber) {
    _forgotFullPhoneNumber = phoneNumber.number;
    _forgotCountryCode = phoneNumber.countryCode;
    // notifyListeners();
  }

  Future<void> verifyOtp() async {


    if (otpController.text.length != 6) {
      Fluttertoast.showToast(msg: 'Please enter complete OTP');
      return;
    }

    setBusy(true);
    try {
      String contact = _forgotPasswordMode == LoginMode.email ? forgotEmailController.text.trim() : _forgotFullPhoneNumber;
      final response = await authService.verifyPhone(otp: otpController.text,phone: contact);

      response.fold(
        (failure) {
          Fluttertoast.showToast(msg: failure.message);
          _clearOtpDigits();
        },
        (user) async {
          Fluttertoast.showToast(msg: 'OTP verified successfully');
          if (_forgotPasswordStep == ForgotPasswordStep.otp) {
            _showOtpField = false;
            _showForgotPassword = true;
            _showOtpLogin = false;
            _forgotPasswordStep = ForgotPasswordStep.newPassword;
            _clearOtpDigits();
            notifyListeners();
            return;
          }
        },
      );
    } catch (e) {
      AppLogger.error('OTP Verification Error: $e');
      Fluttertoast.showToast(msg: 'Invalid OTP. Please try again.');
      _clearOtpDigits(); // Clear OTP on error
    } finally {
      setBusy(false);
    }
  }
  Future<void> verifyOtpWithLogin() async {


    if (otpController.text.length != 6) {
      Fluttertoast.showToast(msg: 'Please enter complete OTP');
      return;
    }

    setBusy(true);
    try {
      String contact = _forgotPasswordMode == LoginMode.email ? forgotEmailController.text.trim() :"+${countryCode.isEmpty?"91":countryCode}"+ _forgotFullPhoneNumber;
      final response = await authService.verifyPhoneOrEmail(otp: otpController.text,phone: contact,type:_forgotPasswordMode == LoginMode.email?"email":"phone", );

      response.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message);
          _clearOtpDigits();
        },
            (user) async {
          Fluttertoast.showToast(msg: 'OTP verified successfully');

          await saveUser(user);
          await _accountManager.saveCurrentUser(user);
          navigateToStageView();

          if (_forgotPasswordStep == ForgotPasswordStep.otp) {
            _showOtpField = false;
            _showForgotPassword = true;
            _showOtpLogin = false;
            _forgotPasswordStep = ForgotPasswordStep.newPassword;
            _clearOtpDigits();
            notifyListeners();
            return;
          }
        },
      );
    } catch (e) {
      AppLogger.error('OTP Verification Error: $e');
      Fluttertoast.showToast(msg: 'Invalid OTP. Please try again.');
      _clearOtpDigits(); // Clear OTP on error
    } finally {
      setBusy(false);
    }
  }
  Future<void> resendOtp() async {
    if (!canResendOtp) return;
    _clearOtpDigits();
    await _handleOtpSend();
  }

  // Forgot password functionality
  Future<void> sendPasswordResetOtp() async {
    AppLogger.warning("sendPasswordResetOtp");
    // if (forgotPasswordFormKey.currentState?.validate() != true) {
    //   return;
    // }

    _isBusyForgotPassword = true;
    notifyListeners();

    try {
      String contact = _forgotPasswordMode == LoginMode.email ? forgotEmailController.text.trim() : _forgotFullPhoneNumber;

      final response = await authService.sendPasswordResetOtp(email: contact,isMobile: _forgotPasswordMode == LoginMode.phone,countryCode: forgotCountryCode);

      response.fold(
        (failure) {
          Fluttertoast.showToast(msg: failure.message);
        },
        (success) {
          _forgotPasswordStep = ForgotPasswordStep.otp;
          _showOtpField = true;
          _showOtpLogin = false;
          _showForgotPassword = false;
          Fluttertoast.showToast(msg: 'OTP sent');
          notifyListeners();
        },
      );

    }
    catch (e) {
      AppLogger.error('Password reset OTP error: $e');
    }
    finally {
      _isBusyForgotPassword = false;
      notifyListeners();
    }
  }
  Future<void> sendOtpWithLogin() async {
    if (forgotPasswordFormKey.currentState?.validate() != true) {
      return;
    }

    _isBusyForgotPassword = true;
    notifyListeners();

    try {
      // print("Contacts Svh:- $_forgotPasswordMode");
      String contact = _forgotPasswordMode == LoginMode.email ?  forgotEmailController.text.trim():_forgotFullPhoneNumber;


      final response = await authService.sendOtpWithLogin(value: contact, type: _forgotPasswordMode == LoginMode.email?'email':'phone',countryCode: countryCode);

      if (response == true) {
        _showOtpField = true;
        _showOtpLogin = false;
        _showForgotPassword = false;
        _forgotPasswordStep = ForgotPasswordStep.contact;
        Fluttertoast.showToast(msg: 'OTP sent successfully');
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: 'Failed to send OTP');
      }
    } catch (e) {
      AppLogger.error('Send OTP for login error: $e');
    } finally {
      _isBusyForgotPassword = false;
      notifyListeners();
    }
  }
  Future<void> resetPassword() async {
    if (forgotPasswordFormKey.currentState?.validate() != true) {
      return;
    }
    _isBusyForgotPassword = true;
    notifyListeners();
    try {
      String contact = _forgotFullPhoneNumber;
      // String contact = _forgotPasswordMode == LoginMode.email ? forgotEmailController.text.trim() : _forgotFullPhoneNumber;

      // Get OTP from forgot password OTP controllers instead of login OTP controllers
      String getForgotPasswordOtp() {
        return forgotOtpDigitControllers.map((controller) => controller.text).join();
      }

      final response = await authService.resetPassword(
        email: contact,
        otp: getForgotPasswordOtp().trim(),
        newPassword: newPasswordController.text.trim(),
        isMobile: _forgotPasswordMode == LoginMode.phone,
      );

      response.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message);
        },
        (success) {
          Fluttertoast.showToast(msg: 'Password reset successfully! Please login with your new password.');
          _resetForgotPasswordState();
          _showForgotPassword = false;
          setLoginMode(LoginMode.email);
          notifyListeners();
          Get.back();
        },
      );
    } catch (e) {
      AppLogger.error('Password reset error: $e');
      Fluttertoast.showToast(msg: 'Failed to reset password. Please try again.');
    } finally {
      _isBusyForgotPassword = false;
      notifyListeners();
    }
  }

  Future<void> resendPasswordResetOtp() async {
    if (!canResendForgotOtp) return;
    _clearForgotOtpDigits();
    await sendPasswordResetOtp();
  }

  // Google Sign-In Method
  Future<void> signInWithGoogle() async {
    try {
      setBusy(true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Fluttertoast.showToast(msg: 'Google Sign-In canceled');
        setBusy(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);

      final User? user = await _convertFirebaseUserToAppUser(authResult.user);

      if (user != null) {
        emailController.text = user.email!;
        await _handleGoogleLogin();
      } else {
        Fluttertoast.showToast(msg: 'Failed to create user');
      }
    } catch (e) {
      AppLogger.error('Google Sign-In Error: $e');
      Fluttertoast.showToast(msg: 'Google Sign-In failed: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  // Facebook Sign-In Method
  // Future<void> signInWithFacebook() async {
  //   try {
  //     setBusy(true);
  //
  //     // Trigger the Facebook sign-in flow
  //     final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
  //
  //     if (result.status == LoginStatus.success) {
  //       // Get the access token
  //       final AccessToken accessToken = result.accessToken!;
  //
  //       // Get user data from Facebook
  //       final Map<String, dynamic> userData = await FacebookAuth.instance.getUserData(fields: "name,email,picture.width(200)");
  //
  //       AppLogger.info('Facebook user data: $userData');
  //
  //       // Create Firebase credential using Facebook access token
  //       final firebase_auth.AuthCredential credential = firebase_auth.FacebookAuthProvider.credential(accessToken.tokenString);
  //
  //       // Sign in to Firebase with Facebook credential
  //       final firebase_auth.UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
  //
  //       // Convert Firebase user to manager user
  //       final User? user = await _convertFacebookUserToAppUser(authResult.user, userData);
  //
  //       if (user != null) {
  //         emailController.text = user.email!;
  //         await _handleFacebookLogin();
  //       } else {
  //         Fluttertoast.showToast(msg: 'Failed to create user');
  //       }
  //     } else if (result.status == LoginStatus.cancelled) {
  //       Fluttertoast.showToast(msg: 'Facebook Sign-In canceled');
  //     } else if (result.status == LoginStatus.failed) {
  //       AppLogger.error('Facebook login failed: ${result.message}');
  //       Fluttertoast.showToast(msg: 'Facebook Sign-In failed: ${result.message}');
  //     }
  //   } catch (e) {
  //     AppLogger.error('Facebook Sign-In Error: $e');
  //     Fluttertoast.showToast(msg: 'Facebook Sign-In failed: ${e.toString()}');
  //   } finally {
  //     setBusy(false);
  //   }
  // }

  Future<User?> _convertFirebaseUserToAppUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    return User(id: firebaseUser.uid, email: firebaseUser.email ?? '', name: firebaseUser.displayName ?? '');
  }

  Future<User?> _convertFacebookUserToAppUser(firebase_auth.User? firebaseUser, Map<String, dynamic> facebookData) async {
    if (firebaseUser == null) return null;

    return User(
      id: firebaseUser.uid,
      email: facebookData['email'] ?? firebaseUser.email ?? '',
      name: facebookData['name'] ?? firebaseUser.displayName ?? '',
      // You can add profile picture URL if needed
      // profilePictureUrl: facebookData['picture']?['data']?['url'],
    );
  }

  // Main form submission
  void onSubmitForm() async {
    if (_loginMode == LoginMode.email) {
      await _handleEmailLogin();
    } else {
      await _handlePhoneLogin();
    }
  }

  // Future<void> sendOtpForgotpassLogin() async {
  //
  //   if (forgotPasswordFormKey.currentState?.validate() != true) {
  //     return;
  //   }
  //
  //   _isBusyForgotPassword = true;
  //   notifyListeners();
  //
  //   try {
  //
  //     String contact = _forgotPasswordMode == LoginMode.email ? forgotEmailController.text.trim() : forgotPhoneController.text;
  //     final response = await authService.sendOtp(value: contact,type: _forgotPasswordMode == LoginMode.email?'email':'phone', countryCode: countryCode);
  //
  //     if (response == true) {
  //       _showOtpField = true;
  //       _showOtpLogin = false;
  //       _showForgotPassword = false;
  //       _forgotPasswordStep = ForgotPasswordStep.contact;
  //       Fluttertoast.showToast(msg: 'OTP sent successfully');
  //       notifyListeners();
  //     } else {
  //       Fluttertoast.showToast(msg: 'Failed to send OTP');
  //     }
  //   } catch (e) {
  //     AppLogger.error('Send OTP for login error: $e');
  //   } finally {
  //     _isBusyForgotPassword = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> _handleEmailLogin() async {
    setBusy(true);

    final response = await login();
    response.fold((failure) {}, (user) async {
      await saveUser(user);
      await _accountManager.saveCurrentUser(user);
      navigateToStageView();
    });
    setBusy(false);
  }

  Future<void> _handleGoogleLogin() async {
    setBusy(true);

    final response = await googleLogin();
    response.fold(
      (failure) {
        Fluttertoast.showToast(msg: failure.message);
      },
      (user) async {
        // Save user to current session and saved accounts
        await saveUser(user);
        await _accountManager.saveCurrentUser(user);
        navigateToStageView();
      },
    );
    setBusy(false);
  }

  Future<void> _handleFacebookLogin() async {
    setBusy(true);

    final response = await facebookLogin();
    response.fold(
      (failure) {
        Fluttertoast.showToast(msg: failure.message);
      },
      (user) async {
        // Save user to current session and saved accounts
        await saveUser(user);
        await _accountManager.saveCurrentUser(user);
        navigateToStageView();
      },
    );
    setBusy(false);
  }

  Future<void> _handleOtpSend() async {
    AppLogger.warning("sendPasswordResetOtp3");
    setBusy(true);

    try {
      String contact = _loginMode == LoginMode.email ? emailController.text : _fullPhoneNumber;

      final response = await authService.sendOtp(value: contact,type: _loginMode == LoginMode.email?'email':'phone', countryCode: countryCode);

      if (response == true) {
        _showOtpField = true;
        _showOtpLogin = false;
        _showForgotPassword = false;
        Fluttertoast.showToast(msg: 'OTP sent successfully');
        notifyListeners();
      } else {}
    } catch (e) {
      AppLogger.error('Send OTP Error: $e');
    }

    setBusy(false);
  }

  Future<void> _handlePhoneLogin() async {
    // if (!_showOtpField) {
    //   await _handleOtpSend();
    // } else {
    //   await verifyOtp();
    // }
   final res= await login();
    res.fold((failure) {
      Fluttertoast.showToast(msg: failure.message);
    }, (user) async {
      await saveUser(user);
      await _accountManager.saveCurrentUser(user);
      navigateToStageView();
    });
  }

  ResultFuture<User> login() async {
    AppLogger.warning("login");
    return await authService.login(value: _loginMode == LoginMode.phone?phoneController.text:emailController.text, password: passwordController.text, role: "processor",isMobile: _loginMode == LoginMode.phone);
  }

  ResultFuture<User> googleLogin() async {
    return await authService.googleLogin(email: emailController.text, token: passwordController.text);
  }

  // Facebook login method that calls your backend
  ResultFuture<User> facebookLogin() async {
    return await authService.facebookLogin(
      email: emailController.text,
      token: passwordController.text,
    );
  }

  Future<void> navigateToStageView() async {
    Restart.restartApp();
    // await _navigationService.clearStackAndShow(Routes.stage, arguments: StageViewAttributes(selectedBottomNavIndex: 0));
  }

  Future<void> navigateToRegister() async {
    await _navigationService.navigateTo(Routes.register);
  }
}
