import 'package:flutter/material.dart';
import 'package:manager/widgets/bottom_sheets/network_unavailable/network_unavailable_sheet.view.dart';
import 'package:manager/widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/locator.dart';

enum BottomSheetType { networkUnavailable, qrScan, filePickerOptions }

Widget buildSheetVariant(
  BuildContext context,
  SheetRequest request,
  Function(SheetResponse) completer,
) {
  switch (request.variant) {
    case BottomSheetType.networkUnavailable:
      return NetworkUnavailableSheet(
        request: request as SheetRequest<NetworkUnavailableSheetAttributes>,
        completer: completer,
      );
    case BottomSheetType.qrScan:
      return QrScanBottomSheet(
        request: request as SheetRequest<QrScanSheetAttributes>,
        completer: completer,
      );
  }
  return BottomSheet(
    onClosing: () {},
    builder: (_) {
      return SizedBox.shrink();
    },
  );
}

setUpBottomSheets() {
  final Map<BottomSheetType, SheetBuilder> bottomSheetsMap = {
    BottomSheetType.networkUnavailable: buildSheetVariant,
    BottomSheetType.qrScan: buildSheetVariant,
    BottomSheetType.filePickerOptions: buildSheetVariant,
  };

  final BottomSheetService bottomSheetService = locator<BottomSheetService>();
  bottomSheetService.setCustomSheetBuilders(bottomSheetsMap);
}
