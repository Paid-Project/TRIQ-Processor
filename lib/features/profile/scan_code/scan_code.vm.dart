import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/models/profile_details_model.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/hive/user/user.dart' as hive_user;
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/contact.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/widgets/qr_dialog.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/employee.dart';
import '../../../routes/routes.dart';
import '../../../widgets/dialogs/common_conformation_dialog.dart';
import '../../employee/add_employee/add_employee.view.dart';

enum ScanScreenType{
  profileScan,
  externalContact,
  employee,
}
class ScanCodeViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();
  final _contactService = locator<ContactService>();
  bool _isScanning = true;
  bool _isProcessing = false;
  DateTime? _lastScanTime;

  // Add required properties for QRDialog
  hive_user.User get user => getUser();

  String? get organizationName => getUser().organizationName;

  bool get isScanning => _isScanning;

  bool get isProcessing => _isProcessing;
  ScanScreenType get screenType => _screenType;
  ScanScreenType _screenType = ScanScreenType.profileScan;
  Customer? get customer => null;

  void setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }
  init(ScanScreenType screen){
    _screenType=screen;
  }
  Future<void> handleScannedCode(String code, BuildContext context) async {
    if (!_isScanning || _isProcessing) return;

    final now = DateTime.now();
    // if (_lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 4) {
    //   AppLogger.info('Scan ignored - too soon after last scan');
    //   return;
    // }

    AppLogger.info('🎨 Build called - _screenType: ${screenType}');
    AppLogger.info('🎨 Build called - _screenType: ${_screenType}');
    _lastScanTime = now;
    _isProcessing = true;
    setScanning(false);

    switch(_screenType){
      case ScanScreenType.profileScan:
        _handleProfileScan(code, context);
        break;
      case ScanScreenType.externalContact:
        _handleExternalEmployeeScan(code, context);
        break;
      case ScanScreenType.employee:
        _handleEmployeeScan(code, context);
        break;
      default:
        _handleExternalEmployeeScan(code, context);
        break;
    }

  }

  _handleProfileScan(String code, BuildContext context) async {
    final now = DateTime.now();
    // if (_lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 4) {
    //   AppLogger.info('Scan ignored - too soon after last scan');
    //   return;
    // }

    _lastScanTime = now;
    _isProcessing = true;
    setScanning(false);
    final response = await _apiService.get(url: ApiEndpoints.getProfileDetails+"/${code}");

    // 2. Check for a successful response
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData;

      // 3. Handle if response.data is a String or Map
      if (response.data is String) {
        responseData = jsonDecode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else {
        AppLogger.error('Invalid response format');
        return;
      }

      // 4. Parse the response using the new model
      // The ProfileResponse.fromJson factory expects the full map
      final profileResponse = ProfileResponse.fromJson(responseData);

      // 5. Check if the profile object was successfully parsed
      if (profileResponse.profile != null) {

        // 6. Save the chat language (same as your example)
        if((profileResponse.profile?.chatLanguage ?? "").isNotEmpty) {
          saveSelectedChatLanguage(profileResponse.profile?.chatLanguage ?? "en");
        }

        Get.dialog(
          QRConfirmDialog(
            model: profileResponse, onConfirm: () async {
            /// On Confirm Send
            AppLogger.info('Scanned code: $code');
            await Future.delayed(Duration(milliseconds: 500));

            final response = await _dialogService.showCustomDialog(
              variant: DialogType.loader,
              data: LoaderDialogAttributes(
                task: () async {
                  try {

                    final requestData = {'organizationId': code};
                    final apiResponse = await _apiService.post(
                      url: ApiEndpoints.sendOrganizationRequest,
                      data: requestData,
                    );

                    AppLogger.info("API Response: ${apiResponse.data}");

                    if (apiResponse.statusCode == 200) {
                      // API call successful
                      return true;
                    } else {
                      throw Exception(
                        apiResponse.data?['msg'] ??
                            'Failed to send organization request',
                      );
                    }
                  } catch (e) {
                    AppLogger.error("Error sending organization request: $e");
                    throw e;
                  }
                },
                message: 'Sending organization request...',
              ),
            );

            if (response?.confirmed == true) {
              Get.back(); // Close dialog
              // API call was successful, show success dialog and navigate back
              _showSuccessDialog(context);
            } else {
              _handleError(response?.data ?? "Unknown error");
            }
            Get.back();
          },),
        );
        AppLogger.info('Profile fetched from API');

      } else {
        // This can happen if the 'profile' key is null or missing
        AppLogger.error('Failed to parse profile data from response');
      }

    } else {
      AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
    }
  }

  _handleExternalEmployeeScan(String code, BuildContext context)async{
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await _apiService.get(
              url: '${ApiEndpoints.getEmployeeById}/$code',
            );


            if (apiResponse.statusCode == 200) {
              final employee = Employee.fromJson(apiResponse.data['data']);
              return employee;
            } else {
              throw Exception(
                apiResponse.data?['message'] ?? 'Failed to fetch Employee',
              );
            }
          } catch (e) {
            AppLogger.error("Error fetching Employee: $e");
            throw e;
          }
        },
        message: 'Fetching Employee data...',
      ),
    );
    if (response?.confirmed == true && response?.data is Employee) {

      final employee = response?.data;
      showCustomActionDialog(
        context: context,
        image: employee.profilePhoto??'',
        title: 'Send Request Employee : ${employee.name?? ''}',
        subtitle: 'Confirm Send Request',
        primaryButtonText: 'Send Request',
        secondaryButtonText: 'Cancel',
        badge:employee.flag??'',
        onPrimaryButtonPressed: () async {
          try{
            final res = await _contactService.sendExternalContactRequest(id:employee.id??'');
            if(res.isRight()){
              _isProcessing = false;
              setScanning(true);

            }else{
              // _handleError(res.value.message);
            }
            Get.back();
            Get.back();
          }catch(e){
            _handleError(e.toString());
          }
          Get.back();
        },
        onSecondaryButtonPressed: () {
          Get.back();
        },
      );

    } else {
      _handleError(response?.data ?? "Unknown error");
    }
  }
  _handleEmployeeScan(String code, BuildContext context)async{
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await _apiService.get(
              url: '${ApiEndpoints.getEmployeeById}/$code',
            );

            AppLogger.info("API Response: ${apiResponse.data}");

            if (apiResponse.statusCode == 200) {
              final employee = Employee.fromJson(apiResponse.data);
              return employee;
            } else {
              throw Exception(
                apiResponse.data?['message'] ?? 'Failed to fetch Employee',
              );
            }
          } catch (e) {
            AppLogger.error("Error fetching Employee: $e");
            throw e;
          }
        },
        message: 'Fetching Employee data...',
      ),
    );
    if (response?.confirmed == true && response?.data is Employee) {
      final employee = response!.data as Employee;
      showCustomActionDialog(
        context: context,
        image: employee.profilePhoto??'',
        title: 'Edit Employee : ${employee.name?? ''}',
        subtitle: 'Confirm Employee',
        secondaryButtonText: 'Cancel',
        primaryButtonText: 'Edit',
        badge:employee.flag??'',
        onPrimaryButtonPressed: () async {
          final _navigationService = locator<NavigationService>();
          await _navigationService.navigateTo(
            Routes.addEmployee,
            arguments: AddEmployeeViewAttributes(
              id: employee.id,
              hasReadOnly: true,
            ),
          );
        },
        onSecondaryButtonPressed: () {
          Get.back();
        },
      );
    } else {
      _handleError(response?.data ?? "Unknown error");
    }
  }
  hive_user.User getFreshUserData() {
    final user =
    getUser(); // This will always get the latest user data from storage
    AppLogger.info(
      'QR Dialog - User data: ID=${user.id}, Name=${user.name}, Email=${user.email}, Organization=${user.organizationName}',
    );
    return user;
  }
  void _showSuccessDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Success'),
        content: Text('Request sent successfully'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Navigate back to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handleError(String errorMessage) {
    _isProcessing = false;
    setScanning(true);
  }

  void resetScanning() {
    setScanning(true);
  }

  void resetProcessingState() {
    _isProcessing = false;
    setScanning(true);
  }
}
