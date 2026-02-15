import 'package:flutter/material.dart';
import 'package:manager/features/profile/qr/qr.vm.dart';
import 'package:manager/features/qr/scan_qr/scan_qr.view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';

import 'package:flutter/material.dart';
import 'package:manager/features/profile/qr/qr.vm.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';

class QRView extends StatelessWidget {
  const QRView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QRViewModel>.reactive(
      viewModelBuilder: () => QRViewModel(),
      onViewModelReady: (model) => model.init(),
      disposeViewModel: false,
      builder: (context, model, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: Text(
                LanguageService.get("qr_code"),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(color: AppColors.white),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: AppColors.white),
                  onPressed: model.isSharing ? null : () => model.shareQR(),
                ),
                IconButton(
                  icon: Icon(Icons.download, color: AppColors.white),
                  onPressed: model.isSaving ? null : model.downloadQR,
                ),
              ],
              bottom: TabBar(
                indicatorColor: Colors.green,
                tabs: [
                  Tab(
                    child: Text(
                      LanguageService.get("my_code"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      LanguageService.get("scan_code"),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    _buildQRHeader(context),
                    Expanded(child: _buildQRCard(context, model)),
                    _buildFooter(context),
                  ],
                ),
                SafeArea(
                  child: ScanQRView(
                    attributes: ScanQRViewAttributes(
                      onScanQr: (scannedData) {
                        model.navigateToAddPartner(scannedData as String);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.h20,
        horizontal: AppSizes.w20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.v30),
          bottomRight: Radius.circular(AppSizes.v30),
        ),
      ),
      child: Column(
        children: [
          Text(
            LanguageService.get("scan_qr_to_connect"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCard(BuildContext context, QRViewModel model) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSizes.w20,
          vertical: AppSizes.h20,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: RepaintBoundary(
          key: model.qrKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.v20),
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.all(AppSizes.v24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Organization logo or branding
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.w16,
                      vertical: AppSizes.h8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                    ),
                    child: Text(
                      'TRIQ',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.h24),
                  // QR Code with custom styling
                  Container(
                    padding: EdgeInsets.all(AppSizes.v12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: QrImageView(
                      backgroundColor: AppColors.white,
                      data: model.user.id ?? '',
                      version: QrVersions.auto,
                      size: AppSizes.w220,
                      gapless: true,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.primary,
                      ),
                      embeddedImage: AssetImage('assets/icons/app_icon.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.h24),
                  // User information
                  Text(
                    model.user.name ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (model.user.email != null) ...[
                    SizedBox(height: AppSizes.h6),
                    Text(
                      model.user.email!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: AppSizes.h16),
                  // Organization role or type
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.w12,
                      vertical: AppSizes.h4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.v20),
                    ),
                    child: Text(
                      model.user.userRole?.toString().split('.').last ??
                          LanguageService.get("member"),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QRViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1, // Equal flex for both buttons
            child: _buildActionButton(
              context,
              icon: Icons.download_rounded,
              label: LanguageService.get("download"),
              onPressed: model.isSaving ? null : () => model.downloadQR(),
              isLoading: model.isSaving,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SizedBox(width: AppSizes.w16),
          // Expanded(
          //   flex: 1, // Equal flex for both buttons
          //   child: _buildActionButton(
          //     context,
          //     icon: Icons.share_rounded,
          //     label: 'Share',
          //     onPressed: model.isSharing ? null : () => model.shareQR(),
          //     gradient: LinearGradient(
          //       colors: [AppColors.secondary, AppColors.secondaryDark],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    required Gradient gradient,
  }) {
    // Create a fixed-width button with equal size
    return SizedBox(
      // This ensures both buttons take the exact same width from their Expanded parents
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize: Size(
            double.infinity,
            AppSizes.h56,
          ), // Full width, fixed height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v16),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSizes.v16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: double.infinity, // Full width container
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.h16,
              horizontal: AppSizes.w16,
            ),
            constraints: BoxConstraints(minHeight: AppSizes.h56),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(icon, color: AppColors.white, size: 20),
                SizedBox(width: AppSizes.w8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w24,
        vertical: AppSizes.h20,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: LanguageService.get("by_using_this_app_you_agree_to_our"),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: LanguageService.get("terms_conditions"),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
            TextSpan(text: LanguageService.get("and")),
            TextSpan(
              text: LanguageService.get("privacy_policy"),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.v20),
            ),
            title: Text(
              'QR Code Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  icon: Icons.info_outline,
                  text: 'Your QR code contains your unique identifier',
                ),
                SizedBox(height: AppSizes.h8),
                _buildInfoItem(
                  icon: Icons.security,
                  text: 'Only share with trusted organizations and partners',
                ),
                SizedBox(height: AppSizes.h8),
                _buildInfoItem(
                  icon: Icons.link,
                  text: 'Scan to connect with other TRIQ users',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        SizedBox(width: AppSizes.w12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
