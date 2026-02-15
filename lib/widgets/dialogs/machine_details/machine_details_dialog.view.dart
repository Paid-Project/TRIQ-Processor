import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/dialogs/machine_details/machine_details_dialog.vm.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/models/employee.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../resources/app_resources/app_resources.dart';

class MachineDetailsDialogAttributes {
  final String machineId;
  final String? processorId;
  final Function(BuildContext, {required Machine machine}) onEditPressed;
  final Function(BuildContext, {required String machineId}) onRemovePressed;
  final bool isAssignedToPartner;

  MachineDetailsDialogAttributes({
    required this.machineId,
    this.processorId,
    required this.onEditPressed,
    required this.onRemovePressed,
    this.isAssignedToPartner = false,
  });
}

class MachineDetailsDialog extends StatelessWidget {
  const MachineDetailsDialog({
    super.key,
    required DialogRequest<MachineDetailsDialogAttributes> request,
    required Function(DialogResponse) completer,
  }) : _request = request,
       _completer = completer;

  final DialogRequest<MachineDetailsDialogAttributes> _request;
  final Function(DialogResponse) _completer;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineDetailsDialogViewModel>.reactive(
      viewModelBuilder: () => MachineDetailsDialogViewModel(),
      onViewModelReady:
          (model) => model.loadMachineDetails(
            machineId: _request.data!.machineId,
            processorId: _request.data!.processorId,
          ),
      builder: (context, model, child) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.w20,
            vertical: AppSizes.h30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.v20),
          ),
          elevation: 10, // Added elevation for a more pronounced shadow
          clipBehavior:
              Clip.antiAlias, // For clean cutoffs at the rounded corners
          child:
              model.isBusy
                  ? MachineDetailsShimmer()
                  : model.errorMessage != null || model.machine == null
                  ? _buildErrorContent(context, model.errorMessage)
                  : _buildMachineDetailsContent(context, model),
        );
      },
    );
  }

  // Add this method as a new method in the MachineDetailsDialog class
  Widget _buildTechniciansSection(
    BuildContext context,
    String title,
    List<Employee> technicians,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSizes.w8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.h12),
        Container(
          padding: EdgeInsets.all(AppSizes.w16),
          decoration: BoxDecoration(
            color: AppColors.softGray,
            borderRadius: BorderRadius.circular(AppSizes.v16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                technicians.map((technician) {
                  return Container(
                    margin: EdgeInsets.only(bottom: AppSizes.h12),
                    padding: EdgeInsets.all(AppSizes.w12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSizes.w8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.v8),
                          ),
                          child: Icon(
                            Icons.engineering,
                            size: AppSizes.v18,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSizes.w12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                technician.name ?? 'Unnamed Technician',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: AppSizes.v14,
                                ),
                              ),
                              SizedBox(height: AppSizes.h4),
                              Text(
                                technician.email ?? 'No email',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppSizes.v12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (technician.role != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.w8,
                              vertical: AppSizes.h2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.v8),
                            ),
                            child: Text(
                              technician.role!,
                              style: TextStyle(
                                fontSize: AppSizes.v12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, String? errorMessage) {
    return Container(
      padding: EdgeInsets.all(AppSizes.w24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.05), AppColors.white],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.w16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: AppSizes.h48,
            ),
          ),
          SizedBox(height: AppSizes.h16),
          Text(
            errorMessage ?? 'Failed to load machine details',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSizes.h24),
          ElevatedButton(
            onPressed:
                () => Navigator.pop(context, DialogResponse(confirmed: false)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(150, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
              ),
              elevation: 3,
            ),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.v16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineDetailsContent(
      BuildContext context,
      MachineDetailsDialogViewModel model,
      ) {
    final machine = model.machine!;
    final technicalSpecs = machine.technicalSpecifications;
    final machineType = technicalSpecs?.machineType;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Content
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w20,
                        vertical: AppSizes.h24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSizes.w12),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.precision_manufacturing,
                                  color: AppColors.white,
                                  size: AppSizes.h28,
                                ),
                              ),
                              SizedBox(width: AppSizes.w12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${machine.modelNumber}-${machine.machineName}' ?? 'Unnamed Machine',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSizes.v22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Details
                    Container(
                      padding: EdgeInsets.all(AppSizes.w20),
                      decoration: BoxDecoration(color: AppColors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(context, LanguageService.get("basic_information"), [
                            _buildDetailItem(
                              context,
                              LanguageService.get("model_number"),
                              machine.modelNumber ?? 'N/A',
                              Icons.tag,
                            ),
                            _buildDetailItem(
                              context,
                              LanguageService.get("machine_type"),
                              (machineType ?? MachineType.fullyAutomatic)
                                  .toString(),
                              Icons.category_outlined,
                            ),
                          ]),

                          SizedBox(height: AppSizes.h20),

                          if (technicalSpecs?.dimensions != null)
                            _buildDetailSection(context, '${LanguageService.get("maximum_processing_size")} (mm)', [
                              _buildDetailItem(
                                context,
                                LanguageService.get("height"),
                                technicalSpecs!.dimensions!.height != null
                                    ? '${technicalSpecs.dimensions!.height} ${technicalSpecs.dimensions!.unit ?? 'cm'}'
                                    : 'N/A',
                                Icons.height,
                              ),
                              _buildDetailItem(
                                context,
                                LanguageService.get("width"),
                                technicalSpecs.dimensions!.width != null
                                    ? '${technicalSpecs.dimensions!.width} ${technicalSpecs.dimensions!.unit ?? 'cm'}'
                                    : 'N/A',
                                Icons.width_normal,
                              ),
                            ]),

                          SizedBox(height: AppSizes.h20),

                          if (technicalSpecs?.processingArea != null)
                            _buildDetailSection(context, '${LanguageService.get("minimum_processing_size")} (mm)', [
                              _buildDetailItem(
                                context,
                                LanguageService.get("height"),
                                technicalSpecs!.processingArea!.max != null
                                    ? '${technicalSpecs.processingArea!.max} ${technicalSpecs.dimensions!.unit ?? 'cm'}'
                                    : 'N/A',
                                Icons.height,
                              ),
                              _buildDetailItem(
                                context,
                                LanguageService.get("width"),
                                technicalSpecs.processingArea!.min != null
                                    ? '${technicalSpecs.processingArea!.min} ${technicalSpecs.dimensions!.unit ?? 'cm'}'
                                    : 'N/A',
                                Icons.width_normal,
                              ),
                            ]),

                          if (technicalSpecs?.powerRequirements != null) ...[
                            SizedBox(height: AppSizes.h20),
                            _buildDetailSection(context, LanguageService.get("power_information"), [
                              _buildDetailItem(
                                context,
                                LanguageService.get("power_consumption"),
                                technicalSpecs!
                                    .powerRequirements!
                                    .powerConsumption !=
                                    null
                                    ? '${technicalSpecs.powerRequirements!.powerConsumption} Kw'
                                    : 'N/A',
                                Icons.power,
                              ),
                            ]),
                          ],

                          if (_request.data?.isAssignedToPartner == true &&
                              (machine.warranty != null ||
                                  machine.warranty?.purchaseDate != null)) ...[
                            SizedBox(height: AppSizes.h20),
                            _buildDetailSection(context, LanguageService.get("machine_ownership"), [
                              if (machine.warranty?.purchaseDate != null)
                                _buildDetailItem(
                                  context,
                                  LanguageService.get("purchase_date"),
                                  _formatDate(machine.warranty!.purchaseDate!),
                                  Icons.shopping_cart_outlined,
                                ),
                              if (machine.warranty?.purchaseDate != null)
                                _buildDetailItem(
                                  context,
                                  LanguageService.get("installation_date"),
                                  _formatDate(machine.warranty!.installationDate!),
                                  Icons.shopping_cart_outlined,
                                ),
                              if (machine.warranty != null) ...[
                                _buildDetailItem(
                                  context,
                                  LanguageService.get("warranty_status"),
                                  _calculateWarrantyStatusText(machine.warranty!),
                                  Icons.shield_outlined,
                                ),
                                if (machine.warranty!.startDate != null)
                                  _buildDetailItem(
                                    context,
                                    LanguageService.get("warranty_start"),
                                    _formatDate(
                                      machine.warranty!.startDate!,
                                    ),
                                    Icons.event_outlined,
                                  ),
                                if (machine.warranty!.expirationDate !=
                                    null)
                                  _buildDetailItem(
                                    context,
                                    LanguageService.get("warranty_end"),
                                    _formatDate(
                                      machine.warranty!.expirationDate!,
                                    ),
                                    Icons.event_busy_outlined,
                                  ),
                                if (machine.warranty!.invoiceNo !=
                                    null)
                                  _buildDetailItem(
                                    context,
                                    LanguageService.get("invoice_no"),
                                    machine.warranty!.invoiceNo!,
                                    Icons.monetization_on,
                                  ),
                              ],
                            ]),
                          ],

                          if (technicalSpecs?.additionalInfo != null &&
                              technicalSpecs!.additionalInfo!.isNotEmpty) ...[
                            SizedBox(height: AppSizes.h20),
                            _buildAdditionalInfoSection(
                              context,
                              LanguageService.get("additional_information"),
                              technicalSpecs.additionalInfo!,
                            ),
                          ],

                          // Add bottom padding to ensure content doesn't get cut off by the action buttons
                          SizedBox(height: AppSizes.h20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Positioned(
                top: AppSizes.h8,
                right: AppSizes.w8,
                child: IconButton(
                  onPressed:
                      () => Navigator.pop(
                    context,
                    DialogResponse(confirmed: false),
                  ),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Fixed action buttons at the bottom
        if (getUser().organizationType == OrganizationType.manufacturer)
          Container(
            padding: EdgeInsets.all(AppSizes.w20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.2),
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.v20),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                // Edit button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _request.data!.onEditPressed(
                      context,
                      machine: machine,
                    ),
                    icon: Icon(Icons.edit, color: AppColors.primary),
                    label: Text(
                      LanguageService.get("edit"),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.w12),

                // Remove button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => model.showDeleteConfirmation(
                      context,
                      machineId: machine.id ?? '',
                      machineName: machine.machineName ?? 'this machine',
                      onRemovePressed: _request.data!.onRemovePressed,
                      completer: _completer,
                    ),
                    icon: Icon(Icons.delete, color: AppColors.white),
                    label: Text(
                      LanguageService.get("remove"),
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

// Helper method to calculate warranty status text for display
  String _calculateWarrantyStatusText(Warranty warranty) {
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
      return 'Not Started Yet';
    }

    if (startDate == null || endDate == null) {
      return LanguageService.get("not_started");
    }

    final now = DateTime.now();

    if (now.isBefore(startDate)) {
      return LanguageService.get("not_started");
    } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
      return LanguageService.get("in_warranty");
    } else {
      return LanguageService.get("out_of_warranty");
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColors.gray;

    switch (status.toLowerCase()) {
      case 'Active':
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline;

    switch (status.toLowerCase()) {
      case 'Active':
        return Icons.check_circle_outline;
    default:
        return Icons.cancel_outlined;
    }
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSizes.w8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.h12),
        Container(
          padding: EdgeInsets.all(AppSizes.w16),
          decoration: BoxDecoration(
            color: AppColors.softGray,
            borderRadius: BorderRadius.circular(AppSizes.v16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.w8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.v8),
            ),
            child: Icon(icon, size: AppSizes.v18, color: AppColors.primary),
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.gray,
                    fontSize: AppSizes.v12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSizes.h2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.v14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(
    BuildContext context,
    String title,
    List<AdditionalInfo> additionalInfoItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSizes.w8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.h12),
        Container(
          padding: EdgeInsets.all(AppSizes.w16),
          decoration: BoxDecoration(
            color: AppColors.softGray,
            borderRadius: BorderRadius.circular(AppSizes.v16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                additionalInfoItems.map((info) {
                  return Container(
                    margin: EdgeInsets.only(bottom: AppSizes.h12),
                    padding: EdgeInsets.all(AppSizes.w12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withOpacity(0.05),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: AppSizes.v16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: AppSizes.w8),
                            Expanded(
                              child: Text(
                                info.title ?? 'Additional Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (info.description != null) ...[
                          SizedBox(height: AppSizes.h8),
                          Text(
                            info.description!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppSizes.v13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  int _calculateDaysUntilExpiration(String expirationDateString) {
    try {
      final expirationDate = DateTime.parse(expirationDateString);
      final now = DateTime.now();
      return expirationDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}

class MachineDetailsShimmer extends StatelessWidget {
  const MachineDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.w20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.v20),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSizes.h52,
                        height: AppSizes.h52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSizes.w12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: AppSizes.h8),
                            Container(
                              height: 16,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h16),
                  Container(
                    height: 28,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body shimmer
          Container(
            padding: EdgeInsets.all(AppSizes.w20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: AppSizes.w8),
                      Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h12),

                  // Details container
                  Container(
                    padding: EdgeInsets.all(AppSizes.w16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(AppSizes.v16),
                    ),
                    child: Column(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.h16),
                          child: Row(
                            children: [
                              Container(
                                width: AppSizes.h36,
                                height: AppSizes.h36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.v8,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.w12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.h6),
                                    Container(
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.h20),

                  // Second section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: AppSizes.w8),
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h12),

                  // Second details container
                  Container(
                    padding: EdgeInsets.all(AppSizes.w16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(AppSizes.v16),
                    ),
                    child: Column(
                      children: List.generate(
                        2,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.h16),
                          child: Row(
                            children: [
                              Container(
                                width: AppSizes.h36,
                                height: AppSizes.h36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.v8,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.w12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.h6),
                                    Container(
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizes.h24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.v12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.w12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.v12),
                          ),
                        ),
                      ),
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
}
