import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/language.service.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/models/machine.dart';
import '../../../../resources/app_resources/app_resources.dart';

class MachineCardAttributes {
  final Machine machine;
  final Function(String) onMachineTap;
  final bool isMyMachine;
  MachineCardAttributes({required this.machine, required this.onMachineTap, this.isMyMachine = false});
}

class MachineCard extends StatelessWidget {
  const MachineCard({super.key, required this.attributes});

  final MachineCardAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => attributes.onMachineTap(attributes.machine.id ?? ''),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.h8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v10),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCardHeader(context),
            _buildCardBody(context),
          ],
        ),
      ),
    );
  }

  // Calculate warranty status based on dates instead of backend status
  String _calculateWarrantyStatus() {
    final warranty = attributes.machine.warranty;
    if (warranty == null) return 'unknown';

    DateTime? startDate;
    DateTime? endDate;

    try {
      if (warranty.startDate != null) {
        startDate = DateTime.parse(warranty.startDate!);
      }
      if (warranty.expirationDate != null) {
        endDate = DateTime.parse(warranty.expirationDate!);
      }
    } catch (e) {
      return 'unknown';
    }

    if (startDate == null || endDate == null) {
      return 'unknown';
    }

    final now = DateTime.now();

    if (now.isBefore(startDate)) {
      return 'not_started';
    } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
      return 'active';
    } else {
      return 'expired';
    }
  }

  Widget _buildWarrantyStatusTag(BuildContext context) {
    final warranty = attributes.machine.warranty;

    if (warranty == null) {
      return Container(); // Return empty container if no warranty data
    }

    // Calculate status based on dates instead of using backend status
    final calculatedStatus = _calculateWarrantyStatus();

    Color tagColor;
    Color textColor;
    String statusText;

    switch (calculatedStatus) {
      case 'active':
        tagColor = Color(0xFF10B981);
        textColor = Colors.white;
        statusText = LanguageService.get("in_warranty");
        break;
      case 'expired':
        tagColor = Color(0xFFEF4444);
        textColor = Colors.white;
        statusText = LanguageService.get("out_of_warranty");
        break;
      case 'not_started':
      case 'unknown':
      default:
        tagColor = Color(0xFF3B82F6);
        textColor = Colors.white;
        statusText = LanguageService.get("not_started");
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w12,
        vertical: AppSizes.h6,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(AppSizes.v8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.v10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(AppSizes.v16),
            ),
            child: Center(
              child: Text(
                'US', // You can make this dynamic based on machine data
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.w8),
          // Machine Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attributes.machine.machineName != null
                      ? '${attributes.machine.modelNumber}-${attributes.machine.machineName}'
                      : attributes.machine.modelNumber ?? '',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Warranty Status and Arrow
          if (getUser().organizationType == OrganizationType.processor) ...[
            Column(
              children: [
                _buildWarrantyStatusTag(context),
                SizedBox(height: AppSizes.h8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF6B7280),
                    size: 14,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: 32,
              height: 32,
              padding: EdgeInsets.all(AppSizes.v8),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(AppSizes.v10),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    // Get machine type from the updated model structure
    final machineType = attributes.machine.technicalSpecifications?.machineType ?? MachineType.fullyAutomatic;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSizes.v10, 0, AppSizes.v10, AppSizes.v10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
          SizedBox(height: AppSizes.h20),
          // Info Items
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  title: LanguageService.get("model_number"),
                  value: attributes.machine.modelNumber ?? 'N/A',
                ),
              ),
              SizedBox(width: AppSizes.w24),
              Expanded(
                child: _buildInfoItem(
                  context,
                  title: LanguageService.get("machine_type"),
                  value: _formatMachineType(machineType),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSizes.h4),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatMachineType(MachineType machineType) {
    switch (machineType) {
      case MachineType.fullyAutomatic:
        return 'Fully Automatic';
      case MachineType.semiAutomatic:
        return 'Semi Automatic';
      case MachineType.manual:
        return 'Manual';
      default:
        return 'Fully Automatic';
    }
  }

  String _formatDimensions(Dimensions? dimensions) {
    if (dimensions == null) return 'N/A';

    final height = dimensions.height;
    final width = dimensions.width;
    final depth = dimensions.depth;
    final unit = dimensions.unit ?? 'cm';

    if (height != null && width != null && depth != null) {
      return '$height × $width $unit';
    } else {
      return 'N/A';
    }
  }

  String _getWarrantyStatus(Machine machine) {
    final statusKey = _getWarrantyStatusKey(machine);
    switch (statusKey.toLowerCase()) {
      case 'active':
        return LanguageService.get("in_warranty");
      case 'not_started':
        return LanguageService.get("not_started");
      case 'expired':
        return LanguageService.get("out_of_warranty");
      default:
        return "N/A";
    }
  }

  // Helper method to get the raw warranty status key
  String _getWarrantyStatusKey(Machine machine) {
    DateTime? startDate;
    DateTime? endDate;
    if(machine.warranty != null) {
      startDate = DateTime.parse(
          machine.warranty?.startDate ??
              DateTime.now().toUtc().toIso8601String());
      endDate = DateTime.parse(
          machine.warranty?.expirationDate ??
              DateTime.now().toUtc().toIso8601String());
    }

    String status = 'n/a';
    if(startDate != null && endDate != null) {
      if (DateTime.now().isBefore(startDate)) {
        status = 'not_started';
      } else if (DateTime.now().isAfter(startDate) &&
          DateTime.now().isBefore(endDate)) {
        status = 'active';
      } else {
        status = 'expired';
      }
    }
    return status;
  }

  String _getFirstAdditionalInfo() {
    final additionalInfo = attributes.machine.technicalSpecifications?.additionalInfo;
    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      final firstInfo = additionalInfo.first;
      return firstInfo.title ?? LanguageService.get("additional_info");
    }
    return LanguageService.get("additional_info");
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Color(0xFF10B981);
      case 'not_started':
        return Color(0xFF3B82F6);
      case 'expired':
        return Color(0xFFEF4444);
      default:
        return AppColors.gray;
    }
  }
}

class MachineCardShimmer extends StatelessWidget {
  const MachineCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header shimmer
          Container(
            padding: EdgeInsets.all(AppSizes.v20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v16),
                    ),
                  ),
                  SizedBox(width: AppSizes.w16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.v8),
                        ),
                      ),
                      SizedBox(height: AppSizes.h8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Body shimmer
          Container(
            padding: EdgeInsets.fromLTRB(AppSizes.v20, 0, AppSizes.v20, AppSizes.v20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(height: 1, color: Colors.white),
                  SizedBox(height: AppSizes.h20),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerInfoItem()),
                      SizedBox(width: AppSizes.w24),
                      Expanded(child: _buildShimmerInfoItem()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}