import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/auth.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/notification.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:restart_app/restart_app.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../routes/routes.dart';

class OtpVerificationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();
  final authService = locator<AuthService>();

  late String email;
  late bool isOrganization;
  final TextEditingController otpController = TextEditingController();

  // Registration data for processor registration flow
  String? fullName;
  String? phone;
  String? countryCode;
  String? password;
  String? organizationType;
  String? otherDescription;
  String? language;

  bool _isFormValid = false; // Initialize to false
  bool get isFormValid => _isFormValid;

  // Resend OTP timer properties
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _canResend = false;
  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(0);

  int get resendCountdown => _resendCountdown;

  bool get canResend => _canResend;

  ValueNotifier<int> get timerNotifier => _timerNotifier;

  void init(OtpVerificationViewAttributes attributes) {
    email = attributes.email;
    isOrganization = attributes.isOrganization;

    // Store registration data if provided
    fullName = attributes.fullName;
    phone = attributes.phone;
    countryCode = attributes.countryCode;
    password = attributes.password;
    organizationType = attributes.organizationType;
    otherDescription = attributes.otherDescription;
    language = attributes.language;

    otpController.addListener(_updateFormValidity);
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;
    _timerNotifier.value = _resendCountdown;
    notifyListeners(); // Only notify once at the start

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _resendCountdown--;
      _timerNotifier.value = _resendCountdown; // Update ValueNotifier without rebuilding entire widget

      if (_resendCountdown <= 0) {
        _canResend = true;
        timer.cancel();
        _resendTimer = null;
        notifyListeners(); // Only notify when timer completes to update button state
      }
    });
  }

  Future<void> resendOtp() async {
    if (!_canResend) return;

    setBusy(true);

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await authService.sendOtpForRegistration(value: phone??'',countryCode: countryCode??'');

            return apiResponse;
          } catch (e) {
            AppLogger.error('Error resending OTP: $e');
            throw e;
          }
        },
        message: "Resending OTP...",
      ),
    );

    if (response?.confirmed == true) {
      final result = response?.data;
      if (result is Right) {
        Fluttertoast.showToast(msg: 'OTP sent successfully');
        _startResendTimer(); // Restart the timer
      } else if (result is Left) {
        final failure = result.fold((l) => l, (r) => null);
        if (failure != null) {
          Fluttertoast.showToast(msg: failure.message);
        }
      }
    } else {
      Fluttertoast.showToast(msg: response?.data ?? 'Failed to send OTP');
    }
    setBusy(false);
  }

  void _updateFormValidity() {
    // Check if OTP is 6 digits (assuming 6-digit OTP)
    final isValid = email.isNotEmpty && otpController.text.isNotEmpty && otpController.text.length == 6;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
    }
  }

  Future verifyEmail() async {
    AppLogger.info("Verifying OTP: ${otpController.text}");

    if (!isFormValid) return;

    final otpValue = otpController.text;

    setBusy(true);

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          final otpResponse = await _apiService.post(url: ApiEndpoints.verifyEmail, data: {'email': email, 'code': otpValue, "type": "email"});

          if (otpResponse.statusCode == 200) {
            // OTP verified successfully
            AppLogger.info("OTP verified successfully");

            // Check if this is a registration flow (has registration data)
            if (fullName != null && phone != null && password != null) {
              // This is a registration flow - call register API
              AppLogger.info("Proceeding with registration");
              String? fcmToken;
              final notificationService = NotificationService();
              fcmToken = await notificationService.getToken();
              final registerResponse = await _apiService.post(
                url: ApiEndpoints.register,
                data: {
                  'fullName': fullName!,
                  'email': email,
                  'password': password!,
                  'phone': phone!,
                  'countryCode': countryCode ?? '',
                  'role': 'processor',
                  if (fcmToken != null) 'fcmToken': fcmToken,
                },
              );

              if (registerResponse.statusCode == 200) {
                // Handle registration response like login
                final userData = registerResponse.data['user'] as Map<String, dynamic>;
                final token = registerResponse.data['token'] as String?;

                final user = User.fromJson(userData);
                if (token != null) {
                  final userWithToken = user.copyWith(token: token);
                  await saveUser(userWithToken);
                  AppLogger.info('User saved successfully with token after registration');
                } else {
                  await saveUser(user);
                  AppLogger.info('User saved successfully without token after registration');
                }

                return 'Registration completed successfully';
              } else {
                throw Exception(registerResponse.data['message'] ?? 'Registration failed');
              }
            } else {
              // This is a regular OTP verification flow
              return 'OTP verified successfully';
            }
          } else {
            throw Exception(otpResponse.data['message'] ?? 'OTP verification failed');
          }
        },
        message: "Verifying OTP...",
      ),
    );

    if (response?.confirmed == true) {
      Restart.restartApp();
      // Verification/Registration completed successfully, navigate to main manager
      // await _navigationService.clearStackAndShow(Routes.stage, arguments: StageViewAttributes(selectedBottomNavIndex: 0));
    }

    setBusy(false);
  }
  Future verifyPhone() async {
    AppLogger.info("Verifying OTP: ${otpController.text}");

    if (!isFormValid) return;

    final otpValue = otpController.text;

    setBusy(true);

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          final otpResponse = await _apiService.post(url: ApiEndpoints.verifyEmail, data: {'phone': "${countryCode ?? '+91'}${phone ?? ''}", 'code': otpValue, "type": "phone"});

          if (otpResponse.statusCode == 200) {
            // OTP verified successfully
            AppLogger.info("OTP verified successfully");

            // Check if this is a registration flow (has registration data)
            if (fullName != null && phone != null && password != null) {
              // This is a registration flow - call register API
              AppLogger.info("Proceeding with registration");
              String? fcmToken;
              final notificationService = NotificationService();
              fcmToken = await notificationService.getToken();
              final registerResponse = await _apiService.post(
                url: ApiEndpoints.register,
                data: {
                  'fullName': fullName!,
                  'email': email,
                  'password': password!,
                  'phone': phone!,
                  'countryCode': countryCode ?? '',
                  'role': 'processor',
                  if (organizationType != null) 'processorType': organizationType!='Others'?organizationType:"Others : ${otherDescription}",
                  if (fcmToken != null) 'fcmToken': fcmToken,
                },
              );

              if (registerResponse.statusCode == 200) {
                // Handle registration response like login
                final userData = registerResponse.data['user'] as Map<String, dynamic>;
                final token = registerResponse.data['token'] as String?;

                final user = User.fromJson(userData);
                if (token != null) {
                  final userWithToken = user.copyWith(token: token);
                  await saveUser(userWithToken);
                  AppLogger.info('User saved successfully with token after registration');
                } else {
                  await saveUser(user);
                  AppLogger.info('User saved successfully without token after registration');
                }

                return 'Registration completed successfully';
              } else {
                throw Exception(registerResponse.data['message'] ?? 'Registration failed');
              }
            } else {
              // This is a regular OTP verification flow
              return 'OTP verified successfully';
            }
          } else {
            throw Exception(otpResponse.data['message'] ?? 'OTP verification failed');
          }
        },
        message: "Verifying OTP...",
      ),
    );

    if (response?.confirmed == true) {
      Restart.restartApp();
      // await Future.delayed(Duration(seconds: 2));
      // // Verification/Registration completed successfully, navigate to main manager
      // await _navigationService.clearStackAndShow(Routes.stage, arguments: StageViewAttributes(selectedBottomNavIndex: 0));
    }

    setBusy(false);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _timerNotifier.dispose();
    otpController.removeListener(_updateFormValidity);
    otpController.dispose();
    super.dispose();
  }
}
