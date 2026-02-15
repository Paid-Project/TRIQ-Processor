import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/features/search/search_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../features/qr/scan_qr/scan_qr.view.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../app_logger.dart';
import 'debounce.dart';

Future<String> getCurrentAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

navigateToScanQRFromCamera(Function(dynamic) onScanQr) async {
  locator<NavigationService>().navigateTo(
    Routes.scanQr,
    arguments: ScanQRViewAttributes(onScanQr: (data) => onScanQr(data)),
  );
}

navigateToSearch(SearchViewAttributes attributes) async {
  locator<NavigationService>().navigateTo(Routes.search, arguments: attributes);
}

navigateToScanQRFromGallery(Function(dynamic) onScanQr) async {
  final picker = ImagePicker();
  final statusStorage = await Permission.storage.request();
  if (!statusStorage.isGranted) {
    Fluttertoast.showToast(msg: 'Gallery permission denied');
    return null;
  }

  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    try {
      final MobileScannerController controller = MobileScannerController();
      final result = await controller.analyzeImage(pickedFile.path);
      if (result == null ||
          result.barcodes.isEmpty ||
          result.barcodes.first.rawValue == null) {
        Fluttertoast.showToast(msg: 'Could not scan the image');
      } else {
        await onScanQr(result.barcodes.first.rawValue);
      }
    } catch (e) {
      AppLogger.error(e);
      Fluttertoast.showToast(msg: "No QR found in image");
    }
  }
}

String formatStatus(String status) {
  // Convert camelCase statuses to space-separated words
  switch (status) {
    case 'Pending':
      return 'Pending Remark';
    case 'Open':
      return 'Waiting to Accept';
    case 'InProgress':
      return 'In Progress';
    case 'OnHold':
      return 'On Hold';
    default:
      // For other camelCase statuses we might encounter
      // Use regex to add spaces before capital letters
      // This will convert camelCase to space-separated words
      return status
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
          .trim();
  }
}

AppLocalizations get appLocalizations => lookupAppLocalizations(Locale('en'));
