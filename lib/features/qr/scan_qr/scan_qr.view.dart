import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager/features/qr/scan_qr/scan_qr.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:stacked/stacked.dart';

class ScanQRViewAttributes {
  final Function(dynamic) onScanQr;
  ScanQRViewAttributes({required this.onScanQr});
}

class ScanQRView extends StatefulWidget {
  const ScanQRView({super.key, required this.attributes});

  final ScanQRViewAttributes attributes;

  @override
  State<ScanQRView> createState() => _ScanQRViewState();
}

class _ScanQRViewState extends State<ScanQRView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScanQrViewModel>.reactive(
      viewModelBuilder: () => ScanQrViewModel(),
      onViewModelReady: (ScanQrViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, ScanQrViewModel model, Widget? child) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated:
                          (controller) => _onQRViewCreated(controller, model),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child:
                          (result != null)
                              ? Text(
                                'Barcode Type: ${(result!.format.name)}   Data: ${result!.code}',
                              )
                              : Text('Scan a code'),
                    ),
                  ),
                ],
              ),
              if (model.isBusy)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.v8),
                      ),
                      padding: EdgeInsets.all(AppSizes.v16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller, ScanQrViewModel model) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        model.executeOnScanQr(widget.attributes.onScanQr, result!.code);
      });
    });
  }
}
