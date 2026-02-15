import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/features/profile/home/profile.vm.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/qr_dialog.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:stacked/stacked.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
as mlkit;
import '../../../../core/utils/app_logger.dart';
import 'scan_code.vm.dart';

class ScanCodeViewAttributes {
  final bool isFromProfile;
  final ScanScreenType screen;

  ScanCodeViewAttributes({this.isFromProfile = false,required this.screen});
}

class ScanCodeView extends StatelessWidget {
  const ScanCodeView({super.key, this.attributes});

  final ScanCodeViewAttributes? attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScanCodeViewModel>.reactive(
      viewModelBuilder: () => ScanCodeViewModel(),
      onViewModelReady: (model)=>model.init(attributes?.screen ?? ScanScreenType.profileScan),
      builder: (context, model, child) {
        return _ScanCodeViewContent(attributes: attributes, model: model,);
      },
    );
  }
}

class _ScanCodeViewContent extends StatefulWidget {
  const _ScanCodeViewContent({this.attributes,    required this.model,});
  final ScanCodeViewModel model;
  final ScanCodeViewAttributes? attributes;

  @override
  State<_ScanCodeViewContent> createState() => _ScanCodeViewContentState();
}

class _ScanCodeViewContentState extends State<_ScanCodeViewContent> {
  MobileScannerController? _scannerController;
  final ImagePicker _imagePicker = ImagePicker();
  late ScanCodeViewModel model;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model=widget.model;
  }
  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onCodeDetected(BarcodeCapture capture, ScanCodeViewModel model) {
    if (!model.isScanning || model.isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        model.handleScannedCode(barcode.rawValue!, context);
        break;
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImageFromGallery(image.path);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image from gallery')),
      );
    }
  }

  Future<void> _processImageFromGallery(String imagePath) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing image...'),
            ],
          ),
        ),
      );

      final inputImage = mlkit.InputImage.fromFilePath(imagePath);
      final barcodeScanner = mlkit.BarcodeScanner(
        formats: [mlkit.BarcodeFormat.qrCode],
      );
      final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(
        inputImage,
      );
      await barcodeScanner.close();
      Navigator.of(context).pop();

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.displayValue != null) {
          await model.handleScannedCode(barcode.displayValue!, context);
        } else {
          _showNoQRCodeDialog();
        }
      } else {
        _showNoQRCodeDialog();
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('Error processing image: $e');
      _showErrorDialog('Failed to process the image. Please try again.');
    }
  }

  void _showNoQRCodeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('No QR Code Found'),
        content: Text(
          'No QR code was detected in the selected image. Please try another image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          if (model.isScanning && !model.isProcessing)
            MobileScanner(
              onDetect: (capture) => _onCodeDetected(capture, model),
              controller: _scannerController,
            )
          else if (model.isProcessing)
            Container(
              color: AppColors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing scan...',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              color: AppColors.black,
              child: Center(
                child: Text(
                  'Camera paused',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),

          _buildStatusBarAndHeader(),
          if (model.isScanning && !model.isProcessing)
            _buildScanningFrame(),
          _buildBottomActionBar(model),

          Positioned(
            bottom: 25,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Row(
                mainAxisAlignment:
                widget.attributes?.isFromProfile ?? false
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (!(widget.attributes?.isFromProfile ?? false))
                    _buildActionButton(
                      icon: Icons.qr_code,
                      label: 'My Qr Code',
                      image: AppImages.qr,
                      isDisabled: model.isProcessing,
                      onTap: () {
                        Get.dialog(
                          QRDialog(
                            user: model.getFreshUserData(),
                            organizationName:
                            model.getFreshUserData().organizationName,
                            customer: model.customer,
                            hideScanButton: true,
                          ),
                        );
                      },
                    ),
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Album',
                    image: AppImages.gallery,
                    isDisabled: model.isProcessing,
                    onTap: _pickFromGallery,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBarAndHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset(
                AppImages.back,
                width: 24,
                height: 24,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Scan Code',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 350,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppImages.scannerBody,
                fit: BoxFit.contain,
                height: 500,
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _AnimatedScanningLine(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(ScanCodeViewModel model) {
    final bool isDisabled = model.isProcessing;

    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: isDisabled ? null : () => model.setScanning(!model.isScanning),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
            isDisabled ? AppColors.white.withOpacity(0.5) : AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
            isDisabled
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.black,
              ),
            )
                : Image.asset(
              AppImages.camera,
              width: 36,
              height: 36,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? image,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
              isDisabled
                  ? AppColors.white.withOpacity(0.5)
                  : AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
              image != null
                  ? Image.asset(
                image,
                width: 22,
                height: 22,
                color:
                isDisabled
                    ? AppColors.textGrey.withOpacity(0.5)
                    : AppColors.textGrey,
              )
                  : Icon(
                icon,
                size: 22,
                color:
                isDisabled
                    ? AppColors.black.withOpacity(0.5)
                    : AppColors.black,
              ),
            ),
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color:
                isDisabled
                    ? AppColors.white.withOpacity(0.5)
                    : AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedScanningLine extends StatefulWidget {
  @override
  _AnimatedScanningLineState createState() => _AnimatedScanningLineState();
}

class _AnimatedScanningLineState extends State<_AnimatedScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(painter: ScanningLinePainter(_animation.value));
      },
    );
  }
}

class ScanningLinePainter extends CustomPainter {
  final double animationValue;

  ScanningLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.blue.withOpacity(0.8),
          AppColors.blue.withOpacity(0.9),
          AppColors.blue.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final lineHeight = 4.0;
    final lineY = (size.height - lineHeight - 10) * animationValue;

    canvas.drawRect(Rect.fromLTWH(0, lineY, size.width, lineHeight), paint);
    final glowPaint =
    Paint()
      ..color = AppColors.blue.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRect(
      Rect.fromLTWH(0, lineY - 1, size.width, lineHeight + 2),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(ScanningLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
