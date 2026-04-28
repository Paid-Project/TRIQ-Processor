import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/notification.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/models/hive/user/user.dart';
import '../core/utils/failures.dart';
import '../routes/routes.dart';

class AuthService {
  final apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  ResultFuture<String> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String countryCode,
    required String role,
    String? organizationType,
    String? language,
  }) async {
    try {
      final data = {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'countryCode': countryCode,
        'role': role,
      };

      // Add organization-specific fields if registering as organization
      if (role == 'organization' && organizationType != null) {
        data['organizationType'] = organizationType;
        if (language != null) {
          data['language'] = language;
        }
      }

      final response = await apiService.post(
        url: ApiEndpoints.register,
        data: data,
      );

      if (response.data['msg'] == 'Registered. Verify email and phone OTP.') {
        return Right('Registration successful');
      } else {
        return Left(Failure(response.data['message'] ?? 'Registration failed'));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to register'));
  }

  // ResultFuture<User> verifyEmail({
  //   required String email,
  //   required String otp,
  // }) async {
  //   try {
  //     final response = await apiService.post(
  //       url: ApiEndpoints.verifyEmail,
  //       data: {'email': email, 'otp': otp},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       try {
  //         final userData = response.data['user'] as Map<String, dynamic>;
  //         final token = response.data['token'] as String?;
  //
  //         AppLogger.info(
  //           'Email verification successful - Token: ${token != null ? 'Present' : 'Missing'}',
  //         );
  //         AppLogger.info('User data: $userData');
  //
  //         final user = User.fromJson(userData);
  //         if (token != null) {
  //           final userWithToken = user.copyWith(token: token);
  //           await saveUser(userWithToken);
  //           AppLogger.info(
  //             'User saved successfully with token after email verification',
  //           );
  //           return Right(userWithToken);
  //         }
  //
  //         AppLogger.info(
  //           'User created successfully without token after email verification',
  //         );
  //         return Right(user);
  //       } catch (e) {
  //         AppLogger.error('Error processing email verification response: $e');
  //         return Left(
  //           Failure('Error processing email verification response: $e'),
  //         );
  //       }
  //     } else {
  //       AppLogger.error('Email verification failed: ${response.data}');
  //       return Left(
  //         Failure(response.data['message'] ?? 'Email verification failed'),
  //       );
  //     }
  //   } catch (e) {
  //     if (e is DioException) {
  //       AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
  //       return Left(
  //         Failure(e.response?.data?['message'] ?? 'Something went wrong'),
  //       );
  //     }
  //   }
  //   return Left(Failure('Failed to verify email'));
  // }

  ResultFuture<bool> verifyPhone({
    required String phone,
    required String otp,
  })
  async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.verifyEmail,
        data: {'phone': phone, 'otp': otp},
      );

      if (response.data['success'] == true) {
        return Right(true);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }
  ResultFuture<User>verifyPhoneOrEmail({
    required String phone,
    required String otp,
    required String type,
    required String countryCode,
  })
  async {
    try {
      var data = {};
      if(type=='email'){
        data={'email': phone,  'otp': otp , 'type':type, 'role':'processor'};
      }
      else{
        data={"countryCode":countryCode,'phone': phone, 'otp': otp , 'type':type, 'role':'processor'};
      }

      final response = await apiService.post(
        url: ApiEndpoints.loginWithOtp,
        data: data,
      );

      if (response.data['success'] == true) {
        try {
          // Extract user data and token from response
          final userData = response.data['user'] as Map<String, dynamic>;
          final token = response.data['token'] as String?;

          AppLogger.info(
            'Login successful - Token: ${token != null ? 'Present' : 'Missing'}',
          );
          AppLogger.info('User data: $userData');

          // Create user with token included
          final user = User.fromJson(userData);
          if (token != null) {
            // Update user with token and save to storage
            final userWithToken = user.copyWith(token: token);
            await saveUser(userWithToken);
            AppLogger.info('User saved successfully with token');

            return Right(userWithToken);
          }

          AppLogger.info('User created successfully without token');

          return Right(user);
        } catch (e) {
          AppLogger.error('Error processing login response: $e');
          return Left(Failure('Error processing login response: $e'));
        }
      } else {
        // Log the response for debugging
        AppLogger.error('Login failed: ${response.data}');
        return Left(Failure(response.data['message'] ?? 'Login failed'));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }
  ResultFuture<bool> forgotPassword({required String email}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode== 200) {
        return Right(true);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }

  ResultFuture<bool> resetPassword({
    required String email,
     String? otp,
    required String newPassword,
    required bool isMobile,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.resetPassword, // You need to add this endpoint
        data: {isMobile?'phone':'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      if (response.statusCode==200) {
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to reset password'));
  }
  ResultFuture<bool> resetNewPassword({
    required String email,
     String? otp,
    required String oldPassword,
    required String newPassword,
    required bool isMobile,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.resetNewPassword, // You need to add this endpoint
        data: {isMobile?'phone':'email': email, 'newPassword':newPassword, 'oldPassword': oldPassword},
      );


      if (response.statusCode == 200||response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: response.data['msg'],
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
        // 1️⃣ Clear all local/hive data
        await clearHive();

        // 2️⃣ Navigate user to Login screen (remove all previous screens)
        await _navigationService.clearStackAndShow(Routes.login);
        print("asdasdasdas");


        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      log('Failed to reset password ${e}');
      return Left(Failure('Failed to reset password ${e}'));
    }

  }
  ResultFuture<User> login({
    required String value,
    required String countryCode,
    required String password,
    required String role,
    required bool isMobile,
  }) async {
    try {

      // Get FCM token
      String? fcmToken;
      try {
        final notificationService = NotificationService();
        fcmToken = await notificationService.getToken();
      } catch (e) {
        AppLogger.error('Failed to get FCM token: $e');
      }

      final response = await apiService.post(
        url: ApiEndpoints.login,
        data: {
          "countryCode":countryCode??"",
          isMobile?"phone":'email': value,
          'password': password,
          'role': role,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.data['success'] == true) {
        try {
          // Extract user data and token from response
          final userData = response.data['user'] as Map<String, dynamic>;
          final token = response.data['token'] as String?;

          AppLogger.info(
            'Login successful - Token: ${token != null ? 'Present' : 'Missing'}',
          );
          AppLogger.info('User data: $userData');

          // Create user with token included
          final user = User.fromJson(userData);
          if (token != null) {
            // Update user with token and save to storage
            final userWithToken = user.copyWith(token: token);
            await saveUser(userWithToken);
            AppLogger.info('User saved successfully with token');

            return Right(userWithToken);
          }

          AppLogger.info('User created successfully without token');

          return Right(user);
        } catch (e) {
          AppLogger.error('Error processing login response: $e');
          return Left(Failure('Error processing login response: $e'));
        }
      } else {
        // Log the response for debugging
        AppLogger.error('Login failed: ${response.data}');
        return Left(Failure(response.data['message'] ?? 'Login failed'));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<User> googleLogin({required String email, String? token}) async {
    try {
      // Get FCM token
      String? fcmToken;
      try {
        final notificationService = NotificationService();
        fcmToken = await notificationService.getToken();
      } catch (e) {
        AppLogger.error('Failed to get FCM token: $e');
      }

      final response = await apiService.post(
        url: ApiEndpoints.googleLogin,
        data: {
          'email': email,
          'idToken': token ?? "",
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.data['success'] == true) {
        // Extract user data and token from response
        final userData = response.data['user'] as Map<String, dynamic>;
        final responseToken = response.data['token'] as String?;

        // Create user with token included
        final user = User.fromJson(userData);
        if (responseToken != null) {
          // Update user with token and save to storage
          final userWithToken = user.copyWith(token: responseToken);
          await saveUser(userWithToken);
          return Right(userWithToken);
        }

        return Right(user);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<User> facebookLogin({
    required String email,
    String? token,
  }) async {
    try {
      // Get FCM token
      String? fcmToken;
      try {
        final notificationService = NotificationService();
        fcmToken = await notificationService.getToken();
      } catch (e) {
        AppLogger.error('Failed to get FCM token: $e');
      }

      final response = await apiService.post(
        url: ApiEndpoints.facebookLogin,
        data: {
          'email': email,
          'idToken': token ?? "",
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.data['success'] == true) {
        // Extract user data and token from response
        final userData = response.data['user'] as Map<String, dynamic>;
        final responseToken = response.data['token'] as String?;

        // Create user with token included
        final user = User.fromJson(userData);
        if (responseToken != null) {
          // Update user with token and save to storage
          final userWithToken = user.copyWith(token: responseToken);
          await saveUser(userWithToken);
          return Right(userWithToken);
        }

        return Right(user);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<bool> forgotPassVarifyOtp({
    required String email,
    required String otp,
    required bool isMobile
  }) async {
    try {

      String? fcmToken;
      try {
        final notificationService = NotificationService();
        fcmToken = await notificationService.getToken();
      }
      catch (e) {
        AppLogger.error('Failed to get FCM token: $e');
      }

      final response = await apiService.post(
        url: ApiEndpoints.otpLogin,
        data: {
          isMobile?'email':'phone': email,
          'otp': otp,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.data['success'] == true) {
        // Extract user data and token from response
        // final userData = response.data['user'] as Map<String, dynamic>;
        // final responseToken = response.data['token'] as String?;

        // Create user with token included
        // final user = User.fromJson(userData);
        // if (responseToken != null) {
        //   // Update user with token and save to storage
        //   final userWithToken = user.copyWith(token: responseToken);
        //   await saveUser(userWithToken);
        //   return Right(userWithToken);
        // }

        return Right(true);
      }else{
        return Right(false);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  Future<Object> sendOtp({required String value,required String type,required String countryCode}) async {
    try {
      var data={};
      if(type=='email'){
        data={'email': value, 'type': type};
      }
      else{
        data={'phone': value, 'type': type,"countryCode":countryCode.replaceAll("+", "")};
      }

      final response = await apiService.post(
        url: ApiEndpoints.sendOtp,
        data: data,
      );

      if (response.data['success'] == true) {
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('User not found'));
  }

  ResultFuture<String> sendOtpForRegistration({required String value,required String countryCode}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.sendOtp,
        data: {'phone': value, 'type': 'phone',"countryCode":countryCode.replaceAll("+", "")},
      );

      if (response.statusCode == 200) {
        return Right('OTP sent successfully');
      } else {
        return Left(Failure(response.data['message'] ?? 'Failed to send OTP'));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to send OTP'));
  }

  ResultFuture<bool> sendPasswordResetOtp({required String email,required bool isMobile,required String countryCode}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.forgotPassword,
        data: {isMobile?'phone':'email': email,'countryCode':countryCode},
      );

      if (response.statusCode== 200) {
        return Right(true);
      }
      else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to send password reset OTP'));
  }
  Future<Object> sendOtpWithLogin({required String value,required String type,required String countryCode}) async {
    try {
      var data={};
      if(type=='email'){
        data={'email': value, 'type': type};
      }
      else{
        data={'phone': value, 'type': type,"countryCode":countryCode.replaceAll("+", "")};
      }

      final response = await apiService.post(
        url: ApiEndpoints.sendOtpForLogin,
        data: data,
      );

      if (response.data['success'] == true) {
        return true;
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('User not found'));
  }
  ResultFuture<bool> checkPassword({required String password}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.checkPassword,
        data: {'password': password},
      );

      if (response.statusCode == 200) {
        return Right(true);
      }
      else {
        return Left(Failure(response.data['message'] ?? 'Invalid password'));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Invalid password'),
        );
      }
    }
    return Left(Failure('Failed to verify password'));
  }

  ResultFuture<bool> deleteAccount({required String id}) async {
    try {
      final response = await apiService.delete(
        url: ApiEndpoints.deleteUser+id,
      );

      if (response.data['success'] == true) {
        return Right(true);
      }
      else {
        return Left(Failure(response.data['message']));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to delete account'));
  }

  ResultFuture<bool> updateFcmToken({
    required String token,
    required String? oldToken,
  }) async {
    // try {
    //   final response = await apiService.post(
    //     url: ApiEndpoints.updateFcmToken,
    //     data: {'oldToken': oldToken ?? '', 'newToken': token},
    //   );

    // if (response.data['success'] == true) {
    //   return Right(true);
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     if (e.response?.statusCode == 401) {
    //       await clearHive();
    //       await _navigationService.clearStackAndShow(Routes.login);
    //     }
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Something went wrong'),
    //     );
    //   }
    // }
    return Left(Failure('Failed to update FCM token'));
  }

  ResultFuture<bool> logout(String? fcmToken) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            // Call logout API
            await apiService.post(url: ApiEndpoints.logout, data: {});
          } catch (e) {
            // Log error but continue with logout process
            AppLogger.error('Logout API error: $e');
          }

          // Always clear local data and redirect to login
          await clearHive();
          await _navigationService.clearStackAndShow(Routes.login);
        },
        message: "Logging out...",
      ),
    );

    return Right(true);
  }

  ResultFuture<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      // You might need a separate endpoint for this or use the existing otpLogin
      final response = await apiService.post(
        url:
            ApiEndpoints.otpLogin, // Temporary - you might need a different endpoint
        data: {'email': email, 'otp': otp},
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify password reset OTP'));
  }
}
