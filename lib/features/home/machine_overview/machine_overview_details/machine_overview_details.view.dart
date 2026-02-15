import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:manager/widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';
import 'package:manager/widgets/dialogs/select_maintenance_type/select_maintenance_type_dialog.view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/home/machine_overview/machine_overview_details/machine_overview_details.vm.dart';
import 'package:manager/core/models/machine_overview_model.dart';
import 'package:manager/core/enums/warranty_status_enum.dart';

class MachineOverviewDetailsView extends StatefulWidget {
  final MachineOverviewList? machine;

  const MachineOverviewDetailsView({super.key, this.machine});

  @override
  State<MachineOverviewDetailsView> createState() =>
      _MachineOverviewDetailsViewState();
}

class _MachineOverviewDetailsViewState extends State<MachineOverviewDetailsView>
    with SingleTickerProviderStateMixin {
  final _navigationService = locator<NavigationService>();
  late TextEditingController _remarkController;
  late TextEditingController _notesController;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
    _notesController = TextEditingController();
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
    _remarkController.dispose();
    _notesController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onOnlineSupportPressed(
    MachineOverviewDetailsViewModel viewModel,
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
              onSucess: () {
                Get.back();
              },
            );
          },
          onCancel: () {
            print('Ticket creation cancelled');
          },
        ),
      ),
    );
  }

  void _onSiteVisitPressed(MachineOverviewDetailsViewModel viewModel) {
    _toggle();
    Get.dialog(
      SelectMaintenanceTypeDialog(
        isWarrantyActive: true,
        attributes: SelectMaintenanceTypeDialogAttributes(
          onSubmit: (String maintenanceType, String organizationId, String machineId) async {
            await viewModel.createTicket(
              maintenanceType: maintenanceType,
              isFromSiteVisit: true,
              onSucess: () {
                Get.back();
              },
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

  WarrantyStatus? get warrantyStatusEnum =>
      WarrantyStatus.fromString(widget.machine?.warrantyStatus);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineOverviewDetailsViewModel>.reactive(
      viewModelBuilder:
          () =>
              MachineOverviewDetailsViewModel()..init(
                widget.machine?.machineId ?? '',
                widget.machine?.organization ?? '',
              ),
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).pop(viewModel.hasChanges);
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(context, viewModel),
            backgroundColor: AppColors.white,
            body: SafeArea(
              child:
                  viewModel.isLoading
                      ? _buildLoadingState()
                      : viewModel.hasError
                      ? _buildErrorState(viewModel)
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildMachineDetails(viewModel),
                      ),
            ),
            floatingActionButton: _buildExpandableFloatingActionButton(
              viewModel,
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableFloatingActionButton(
    MachineOverviewDetailsViewModel viewModel,
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
            heroTag: "machine_overview_close_fab",
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
    MachineOverviewDetailsViewModel viewModel,
  ) {
    final children = <Widget>[];
    final count = 2; // Online Support and Site Visit
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
            heroTag: "machine_overview_open_fab",
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MachineOverviewDetailsViewModel viewModel,
  ) {
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
        onPressed: () {
          if (mounted) {
            _navigationService.back();
          }
        },
      ),
      titleSpacing: 0,
      title: Text(
        "${widget.machine?.modelNumber?.toUpperCase() ?? ""} - ${viewModel.machineDetails?.machineName ?? widget.machine?.machineName?.toUpperCase() ?? "Unknown "
                "Machine"}".toUpperCase(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildShimmerContent(),
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerTextField(),
          const SizedBox(height: 16),

          _buildShimmerTextField(),
          const SizedBox(height: 16),

          _buildShimmerTextField(),
          const SizedBox(height: 16),

          _buildShimmerTextField(),
          const SizedBox(height: 24),

          _buildShimmerSectionTitle(),
          const SizedBox(height: 16),

          _buildShimmerProcessingDimensions(),
          const SizedBox(height: 24),

          _buildShimmerTextField(maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildShimmerTextField({int maxLines = 1}) {
    return Container(
      height: maxLines == 1 ? 60 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildShimmerSectionTitle() {
    return Container(
      height: 20,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmerProcessingDimensions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerInfoRow()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildShimmerInfoRow()),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 56, color: AppColors.lightGrey, width: 1),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerInfoRow()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildShimmerInfoRow()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.lightGrey),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildShimmerInfoRow()),
            const SizedBox(width: 14),
            Expanded(child: _buildShimmerInfoRow()),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.lightGrey),
        const SizedBox(height: 20),

        _buildShimmerInfoRow(),
      ],
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MachineOverviewDetailsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.refreshMachineDetails,
            child: Text('retry'.lang),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineDetails(MachineOverviewDetailsViewModel viewModel) {
    final machineData = viewModel.machineDetails;
    if (machineData == null) return const SizedBox.shrink();

    _remarkController.text = machineData.remarks ?? '';
    _notesController.text = machineData.notes ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: TextEditingController(
            text: "${machineData.modelNumber?.toUpperCase()} - ${machineData.machineName?.toUpperCase()}",
          ),
          label: 'machine_model_name'.lang,
          placeholder: '',
          readOnly: true,
          textStyle: TextStyle(color: AppColors.black),

          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: TextEditingController(
            text: "${machineData.modelNumber?.toUpperCase()}",
          ),
          textStyle: TextStyle(color: AppColors.black),
          label: 'model_number'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: TextEditingController(
            text: machineData.machineType ?? 'N/A',
          ),
          label: 'functionality'.lang,
          placeholder: '',
          textStyle: TextStyle(color: AppColors.black),

          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        Stack(
          alignment: Alignment.centerRight,
          children: [
            CommonTextField(
              controller: _remarkController,
              label: 'remark'.lang,
              textStyle: TextStyle(color: AppColors.black),
              readOnly: true,
              enabled: false,
              placeholder: 'enter_remark_here'.lang,
              maxLines: 1,
            ),
            Positioned(
              right: 0,
              bottom: 2,
              child: Center(
                child: CustomPopup(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add machine add-ons like:',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '''• Machine with 2/4 station loader\n• Machine with loader & unloader\n• Machine with Auto detection\n• Machine with Single/double blower (furnace/washing)\netc.''',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  position: PopupPosition.top,
                  arrowColor: AppColors.textGrey,
                  backgroundColor: AppColors.textGrey,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Image.asset(AppImages.alert, width: 16, height: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('processing_dimensions'.lang),
        const SizedBox(height: 16),

        if (viewModel.hasProcessingDimensions) ...[
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'maximum_processing_size'.lang,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.height,
                                'height'.lang,
                                '${machineData.processingDimensions?.maxHeight ?? "-"}',
                                AppColors.color41C293,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.width,
                                'width'.lang,
                                '${machineData.processingDimensions?.maxWidth ?? "-"}',
                                AppColors.primarySuperLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 56, color: AppColors.lightGrey, width: 1),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'minimum_processing_size'.lang,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.height,
                                'height'.lang,
                                '${machineData.processingDimensions?.minHeight ?? "-"}',
                                AppColors.color41C293,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.width,
                                'width'.lang,
                                '${machineData.processingDimensions?.minWidth ?? "-"}',
                                AppColors.primarySuperLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Divider(height: 40, color: AppColors.lightGrey),

          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  AppImages.thickness,
                  'thickness'.lang,
                  machineData.processingDimensions?.thickness ?? "-",
                  AppColors.lightCoral,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _buildInfoRow(
                  AppImages.maxSpeed,
                  'max_speed'.lang,
                  '${machineData.processingDimensions?.maxSpeed ?? "-"}',
                  AppColors.blueLagoon,
                ),
              ),
            ],
          ),
          Divider(height: 40, color: AppColors.lightGrey),

          _buildInfoRow(
            AppImages.powerConsumption,
            'total_power'.lang,
            '${machineData.totalPower ?? "-"}',
            AppColors.primarySuperLight,
          ),
        ] else ...[
          Text(
            'No processing dimensions available',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 24),

        CommonTextField(
          controller: _notesController,
          label: 'notes_special_instructions'.lang,
          textStyle: TextStyle(color: AppColors.black),

          readOnly: true,
          enabled: false,
          placeholder: 'link_here'.lang,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
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
          child: Image.asset(iconPath, width: 17, height: 17, color: iconColor),
        ),
        const SizedBox(width: 6),
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
