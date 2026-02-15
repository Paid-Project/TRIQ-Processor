import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/bottom_sheets/qr_scan/qr_scan_sheet.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/navigation/app_navigation_observer.dart';
import '../../../routes/routes.dart';

class QrScanSheetAttributes {
  QrScanSheetAttributes();
}

class QrScanSheetResponse {
  final QrSource qrSource;
  QrScanSheetResponse({required this.qrSource});
}

enum QrSource {
  gallery,
  camera,
  phoneNumber,
  email,
  addNew
}

class QrScanBottomSheet extends StatelessWidget {
  const QrScanBottomSheet({
    super.key,
    required this.request,
    required this.completer,
  });

  final SheetRequest<QrScanSheetAttributes> request;
  final Function(SheetResponse<QrScanSheetResponse>) completer;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrScanSheetViewModel>.reactive(
      viewModelBuilder: () => QrScanSheetViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.w20),
                topRight: Radius.circular(AppSizes.w20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.h20,
              horizontal: AppSizes.w20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: AppSizes.w40,
                    height: AppSizes.h4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppSizes.w2),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h20),
                Text(
                  LanguageService.get("scan_qr_code"),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizes.h10),
                Text(
                 LanguageService.get("choose_method_scan_search"),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.h20),
                _buildScanOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  title: LanguageService.get("scan_from_camera"),
                  subtitle: LanguageService.get("open_camera_and_point_at_the_qr_code"),
                  onTap: () => model.navigateToScanQRFromCamera(completer),
                ),
                SizedBox(height: AppSizes.h10),
                _buildScanOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  title: LanguageService.get("scan_from_gallery"),
                  subtitle: LanguageService.get("select_an_image_from_the_gallery"),
                  onTap: () => model.navigateToScanQRFromGallery(completer),
                ),
                SizedBox(height: AppSizes.h10),
                _buildScanOption(
                  context,
                  icon: Icons.phone_rounded,
                  title: LanguageService.get('search_by_phone_number'),
                  subtitle: LanguageService.get('find_by_entering_a_phone_number'),
                  onTap: () => model.navigateToSearchByPhone(completer),
                ),
                SizedBox(height: AppSizes.h10),
                _buildScanOption(
                  context,
                  icon: Icons.email_rounded,
                  title: LanguageService.get('search_by_email'),
                  subtitle: LanguageService.get('find_by_entering_an_email'),
                  onTap: () => model.navigateToSearchByEmail(completer),
                ),

                SizedBox(height: AppSizes.h10),
                if (getUser().organizationType == OrganizationType.manufacturer || (getUser().organizationType == OrganizationType.processor && AppNavigatorObserver.isRouteActive(Routes.employeesList)))
                  _buildScanOption(
                    context,
                    icon: Icons.add_circle_rounded,
                    title: LanguageService.get('add_new'),
                    subtitle: LanguageService.get('create_a_new_manually'),
                    onTap: () => model.navigateToAddNew(completer),
                  ),
                SizedBox(height: AppSizes.h20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.v14),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.softGray,
          borderRadius: BorderRadius.circular(AppSizes.v14),
          border: Border.all(color: AppColors.lightGrey, width: 1),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w16,
          vertical: AppSizes.h16,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.v12),
              ),
              padding: EdgeInsets.all(AppSizes.w10),
              child: Icon(icon, color: AppColors.primary, size: AppSizes.v24),
            ),
            SizedBox(width: AppSizes.w16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSizes.h4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: AppSizes.v24,
            ),
          ],
        ),
      ),
    );
  }
}