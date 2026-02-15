import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/features/organization/add_partner/add_partner.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/app_logger.dart';

class QRViewModel extends ReactiveViewModel {
  final GlobalKey qrKey = GlobalKey();

  void init() {}

  final _navigationService = locator<NavigationService>();

  final _user = ReactiveValue(getUser());
  User get user => _user.value;

  final _isSaving = ReactiveValue(false);
  bool get isSaving => _isSaving.value;

  final _isSharing = ReactiveValue(false);
  bool get isSharing => _isSharing.value;

  Future<void> downloadQR() async {
    if (_isSaving.value) return;

    try {
      _isSaving.value = true;
      notifyListeners();

      // Check storage permission
      final permissionStatus = await _checkPermission();
      if (!permissionStatus) {
        Fluttertoast.showToast(
          msg: 'Storage permission is required to save QR code',
        );
        return;
      }

      final qrImage = await _captureQRImage();
      if (qrImage == null) {
        Fluttertoast.showToast(msg: 'Failed to capture QR image');
        return;
      }

      // Get temporary directory for creating the file
      final directory = await getTemporaryDirectory();
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      // Write to temporary file
      final file = File(filePath);
      await file.writeAsBytes(qrImage);

      // Save to gallery using saver_gallery
      final result = await SaverGallery.saveImage(
        qrImage,
        fileName: fileName,
        skipIfExists: true,
      );

      AppLogger.info('QR code save result: $result');

      if (result.isSuccess) {
        Fluttertoast.showToast(msg: 'QR code saved to gallery');
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to save QR code to gallery: ${result.errorMessage}',
        );
      }

      // Delete the temporary file
      await file.delete();
    } catch (e) {
      AppLogger.error('Error downloading QR: $e');
      Fluttertoast.showToast(
        msg: 'Failed to download QR code: ${e.toString()}',
      );
    } finally {
      _isSaving.value = false;
      notifyListeners();
    }
  }

  Future<void> shareQR() async {
    if (_isSharing.value) return;

    try {
      _isSharing.value = true;
      notifyListeners();

      final qrImage = await _captureQRImage();
      if (qrImage == null) {
        Fluttertoast.showToast(msg: 'Failed to capture QR image');
        return;
      }

      // Get temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      // Write to temporary file
      final file = File(filePath);
      await file.writeAsBytes(qrImage);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'My QR Code',
        text: 'Here is my QR code',
      );
    } catch (e) {
      AppLogger.error('Error sharing QR: $e');
      Fluttertoast.showToast(msg: 'Failed to share QR code: ${e.toString()}');
    } finally {
      _isSharing.value = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> _captureQRImage() async {
    try {
      // Find the RenderRepaintBoundary using the key
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        AppLogger.error('RenderRepaintBoundary is null');
        return null;
      }

      // Convert to image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        AppLogger.error('ByteData is null');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      AppLogger.error('Error capturing QR image: $e');
      return null;
    }
  }

  Future<bool> _checkPermission() async {
    // For iOS, we don't need to explicitly check permission as it's handled by the OS
    if (Platform.isIOS) {
      return true;
    }

    // For Android, check and request permission if needed
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) {
        return true;
      }

      // Request permission
      final result = await Permission.storage.request();
      final resultPhotos = await Permission.photos.request();
      if (result.isGranted || resultPhotos.isGranted) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        // User needs to enable permission from settings
        Fluttertoast.showToast(
          msg:
              'Photo permission is permanently denied. Please enable it in manager settings.',
          toastLength: Toast.LENGTH_LONG,
        );

        await openAppSettings();
      }
    }

    return false;
  }

  void navigateToAddPartner(String id) async {
    AppLogger.info("idfhjkl $id");

    _navigationService.back();

    await _navigationService.navigateTo(
      Routes.addPartner,
      arguments: AddPartnerViewAttributes(id: id),
    );
  }
}
