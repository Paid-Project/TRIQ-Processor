import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:manager/widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';
import 'package:manager/widgets/dialogs/select_maintenance_type/select_maintenance_type_dialog.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/core/models/machine_supplier_details_model.dart';
import 'package:manager/core/enums/warranty_status_enum.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/home/machine_supplier/machine_supplier_details/supplier_machine_details/supplier_machine_details.vm.dart';

class SupplierMachineDetailsView extends StatefulWidget {
  final MachineElement machineElement;
  final String organizationId;

  const SupplierMachineDetailsView({
    super.key,
    required this.machineElement,
    required this.organizationId,
  });

  @override
  State<SupplierMachineDetailsView> createState() =>
      _SupplierMachineDetailsViewState();
}

class _SupplierMachineDetailsViewState extends State<SupplierMachineDetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onOnlineSupportPressed(
    SupplierMachineDetailsViewModel viewModel,
  ) async {
    _toggle();
    Get.dialog(
      CreateTicketDialogWidget(
        attributes: CreateTicketDialogAttributes(
          onSubmit: (problem, errorCode, additionalNotes, attachments, machineId, organizationId) async {
            print('Problem: $problem');
            print('Error Code: $errorCode');
            print('Additional Notes: $additionalNotes');
            print('Attachments: ${attachments.length} files');
            await viewModel.createTicket(
              problem: problem,
              errorCode: errorCode,
              additionalNotes: additionalNotes,
              attachments: attachments,
            );
          },
          onCancel: () {
            print('Ticket creation cancelled');
          },
        ),
      ),
    );
  }

  void _onSiteVisitPressed(SupplierMachineDetailsViewModel viewModel) {
    _toggle();
    Get.dialog(
      SelectMaintenanceTypeDialog(
        isWarrantyActive: widget.machineElement.warrantyStatus == "In warranty",
        attributes: SelectMaintenanceTypeDialogAttributes(
          onSubmit: (String maintenanceType, String organizationId, String machineId) async {
            await viewModel.createTicket(
              maintenanceType: maintenanceType,
              isFromSiteVisit: true,
            );
          },
          onCancel: () {},
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SupplierMachineDetailsViewModel>.reactive(
      viewModelBuilder:
          () =>
              SupplierMachineDetailsViewModel()..init(
                widget.machineElement.machine?.id ?? '',
                widget.organizationId,

              ),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child:
                viewModel.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildMachineDetails(),
                    ),
          ),
          floatingActionButton: _buildExpandableFloatingActionButton(viewModel),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final machine = widget.machineElement.machine;
    final machineName = machine?.machineName ?? 'Unknown Machine';

    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
      ),
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        machineName.toUpperCase(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String getMachineType() =>
      widget.machineElement.machine?.machineType ?? 'Unknown Type';

  String getModelNumber() =>
      widget.machineElement.machine?.modelNumber?.toUpperCase() ?? 'N/A';

  String getTotalPower() =>
      widget.machineElement.machine?.totalPower?.toString() ?? '0';

  String getWarrantyStatus() =>
      widget.machineElement.warrantyStatus ?? 'Unknown';

  String getInvoiceContractNo() =>
      widget.machineElement.invoiceContractNo ?? 'N/A';

  String getMaxHeight() =>
      widget.machineElement.machine?.processingDimensions?.maxHeight
          ?.toString() ??
      'N/A';

  String getMaxWidth() =>
      widget.machineElement.machine?.processingDimensions?.maxWidth
          ?.toString() ??
      'N/A';

  String getMinHeight() =>
      widget.machineElement.machine?.processingDimensions?.minHeight
          ?.toString() ??
      'N/A';

  String getMinWidth() =>
      widget.machineElement.machine?.processingDimensions?.minWidth
          ?.toString() ??
      'N/A';

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String getPurchaseDate() => formatDate(widget.machineElement.purchaseDate);

  String getInstallationDate() =>
      formatDate(widget.machineElement.installationDate);

  String getWarrantyStart() => formatDate(widget.machineElement.warrantyStart);

  String getWarrantyEnd() => formatDate(widget.machineElement.warrantyEnd);

  WarrantyStatus? get warrantyStatusEnum =>
      WarrantyStatus.fromString(widget.machineElement.warrantyStatus);

  bool isWarrantyActive() => widget.machineElement.warrantyStatus == "Active";

  Widget _buildMachineDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'basic_information'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.modelNumber,
                      'model_number'.lang,
                      getModelNumber(),
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.machineType,
                      'machine_type'.lang,
                      getMachineType(),
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text(
                'maximum_processing_size'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      getMaxHeight(),
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      getMaxWidth(),
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text(
                'minimum_processing_size'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.height,
                      'height'.lang,
                      getMinHeight(),
                      AppColors.color41C293,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoCard(
                      AppImages.width,
                      'width'.lang,
                      getMinWidth(),
                      AppColors.primarySuperLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),
              Text(
                'power_information'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                AppImages.powerConsumption,
                'power_consumption'.lang,
                '${getTotalPower()} kw',
                AppColors.primarySuperLight,
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 14),

              Text(
                'machine_ownership'.lang,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.purchaseDate,
                      'purchase_date'.lang,
                      getPurchaseDate(),
                      AppColors.colorF2A22E,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.installationDate,
                      'installation_date'.lang,
                      getInstallationDate(),
                      AppColors.colorFF6868,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_start'.lang,
                      getWarrantyStart(),
                      AppColors.primarySuperLight,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyDate,
                      'warranty_end'.lang,
                      getWarrantyEnd(),
                      AppColors.primarySuperLight,
                      isWarning: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.warrantyStatus,
                      'warranty_status'.lang,
                      widget.machineElement.warrantyStatus ?? "",
                      AppColors.color41C293,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      AppImages.invoice,
                      'invoice_contract_no'.lang,
                      getInvoiceContractNo(),
                      AppColors.color41C293,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildInfoRow(
    String iconPath,
    String label,
    String value,
    Color iconColor, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isWarning ? AppColors.redBack : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String iconPath,
    String label,
    String value,
    Color iconColor,
  ) {
    return _buildInfoRow(iconPath, label, value, iconColor);
  }

  Widget _buildExpandableFloatingActionButton(
    SupplierMachineDetailsViewModel viewModel,
  ) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(viewModel),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          !_open ? 0.7 : 1.0,
          !_open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: !_open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "supplier_machine_close_fab",
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.close_rounded),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons(
    SupplierMachineDetailsViewModel viewModel,
  ) {
    final children = <Widget>[];
    final count = 2;
    final step = 40.0 / (count - 1);
    final buttons = [
      _ActionButton(
        onPressed: () => _onSiteVisitPressed(viewModel),
        label: 'site_visit'.lang,
        backgroundColor: AppColors.primaryLight,
      ),
      _ActionButton(
        onPressed: () => _onOnlineSupportPressed(viewModel),
        label: 'online_support'.lang,
        backgroundColor: AppColors.primary,
      ),
    ];

    for (
      var i = 0, angleInDegrees = 0.0;
      i < count;
      i++, angleInDegrees += step
    ) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: 90,
          progress: _expandAnimation,
          child: buttons[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            heroTag: "supplier_machine_open_fab",
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'create_ticket'.lang,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: -10 + offset.dx,
          bottom: 6 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.onPressed,
    required this.label,
    required this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
