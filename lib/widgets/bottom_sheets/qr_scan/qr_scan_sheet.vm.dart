import 'package:manager/widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class QrScanSheetViewModel extends ReactiveViewModel {
  void init() {}

  navigateToScanQRFromCamera(
    Function(SheetResponse<QrScanSheetResponse>) completer,
  ) async {
    completer(
      SheetResponse<QrScanSheetResponse>(
        confirmed: true,
        data: QrScanSheetResponse(qrSource: QrSource.camera),
      ),
    );
  }

  navigateToScanQRFromGallery(
    Function(SheetResponse<QrScanSheetResponse>) completer,
  ) async {
    completer(
      SheetResponse<QrScanSheetResponse>(
        confirmed: true,
        data: QrScanSheetResponse(qrSource: QrSource.gallery),
      ),
    );
  }

  void navigateToSearchByPhone(Function(SheetResponse<QrScanSheetResponse>) completer) {
    completer(SheetResponse(
      confirmed: true,
      data: QrScanSheetResponse(qrSource: QrSource.phoneNumber),
    ));
  }

  void navigateToSearchByEmail(Function(SheetResponse<QrScanSheetResponse>) completer) {
    completer(SheetResponse(
      confirmed: true,
      data: QrScanSheetResponse(qrSource: QrSource.email),
    ));
  }

  void navigateToAddNew(Function(SheetResponse<QrScanSheetResponse>) completer) {
    completer(SheetResponse(
      confirmed: true,
      data: QrScanSheetResponse(qrSource: QrSource.addNew),
    ));
  }
}
