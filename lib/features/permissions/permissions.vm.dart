import 'package:flutter/material.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/permissions/permissions.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../core/locator.dart';

class PermissionsViewModel extends BaseViewModel {
  // Permission status tracking
  bool _notificationPermission = false;
  bool _cameraPermission = false;
  bool _storagePermission = false;
  bool _microphonePermission = false;
  bool _photosPermission = false;

  // Permission interaction tracking
  bool _notificationInteracted = false;
  bool _cameraInteracted = false;
  bool _storageInteracted = false;
  bool _microphoneInteracted = false;
  bool _photosInteracted = false;

  // Getters for permission status
  bool get notificationPermission => _notificationPermission;
  bool get cameraPermission => _cameraPermission;
  bool get storagePermission => _storagePermission;
  bool get microphonePermission => _microphonePermission;
  bool get photosPermission => _photosPermission;

  // Check if all permissions are granted
  bool get allPermissionsGranted =>
      _notificationPermission &&
          _cameraPermission &&
          // _storagePermission &&
          _microphonePermission &&
          _photosPermission;

  // Check if all permissions have been interacted with
  bool get allPermissionsInteracted =>
      _notificationInteracted &&
          _cameraInteracted &&
          // _storageInteracted &&
          _microphoneInteracted &&
          _photosInteracted;

  final _navigationService = locator<NavigationService>();

  init() async {
    // Check all permissions on initialization
    await _checkInitialPermissions();

    // If all permissions are already granted, navigate to stage
    if (allPermissionsGranted) {
      navigateToStage();
    }
  }

  navigateToStage() {
    _navigationService.clearStackAndShow(
        Routes.stage,
        arguments: StageViewAttributes(selectedBottomNavIndex: 2)
    );
  }

  // Check initial status for all permissions
  Future<void> _checkInitialPermissions() async {
    _notificationPermission = await Permission.notification.isGranted;
    _cameraPermission = await Permission.camera.isGranted;
    _storagePermission = await Permission.storage.isGranted;
    _microphonePermission = await Permission.microphone.isGranted;
    _photosPermission = await Permission.photos.isGranted;

    // Update UI
    notifyListeners();
  }

  // Request notification permission
  Future<void> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      _notificationPermission = status.isGranted;
      _notificationInteracted = true;

      _showPermissionToast('Notification', status);
      notifyListeners();
      _checkNavigationEligibility();
    } catch (e) {
      _showErrorToast('notification');
    }
  }

  // Request camera permission
  Future<void> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _cameraPermission = status.isGranted;
      _cameraInteracted = true;

      _showPermissionToast('Camera', status);
      notifyListeners();
      _checkNavigationEligibility();
    } catch (e) {
      _showErrorToast('camera');
    }
  }

  // Request storage permission
  Future<void> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      final statusPhotos = await Permission.photos.request();
      _storagePermission = status.isGranted || statusPhotos.isGranted;
      _storageInteracted = true;

      _showPermissionToast('Storage', status);
      notifyListeners();
      _checkNavigationEligibility();
    } catch (e) {
      _showErrorToast('storage');
    }
  }

  // Request microphone permission
  Future<void> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      _microphonePermission = status.isGranted;
      _microphoneInteracted = true;

      _showPermissionToast('Microphone', status);
      notifyListeners();
      _checkNavigationEligibility();
    } catch (e) {
      _showErrorToast('microphone');
    }
  }

  // Request photos permission
  Future<void> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      _photosPermission = status.isGranted;
      _photosInteracted = true;

      _showPermissionToast('Photos', status);
      notifyListeners();
      _checkNavigationEligibility();
    } catch (e) {
      _showErrorToast('photos');
    }
  }

  // Helper method to show consistent toast messages
  void _showPermissionToast(String permissionName, PermissionStatus status) {
    if (status.isGranted) {
      Fluttertoast.showToast(
        msg: '$permissionName permission granted',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else if (status.isDenied) {
      Fluttertoast.showToast(
        msg: '$permissionName permission denied',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: '$permissionName permission permanently denied. Please enable in manager settings.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  // Error toast for unexpected issues
  void _showErrorToast(String permissionName) {
    Fluttertoast.showToast(
      msg: 'Error requesting $permissionName permission',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // Check if we should navigate after each permission interaction
  void _checkNavigationEligibility() {
    if (allPermissionsInteracted) {
      // All permissions have been interacted with, can proceed
      navigateToStage();
    }
  }
}