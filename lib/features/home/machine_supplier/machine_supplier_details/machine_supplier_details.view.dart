import 'package:flutter/material.dart';
import 'package:manager/features/contacts/create_group/create_group.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/core/models/machine_supplier_details_model.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'machine_supplier_details.vm.dart';

class MachineSupplierDetailsView extends StatefulWidget {
  final String customerId;

  const MachineSupplierDetailsView({super.key, required this.customerId});

  @override
  State<MachineSupplierDetailsView> createState() => _MachineSupplierDetailsViewState();
}

class _MachineSupplierDetailsViewState extends State<MachineSupplierDetailsView> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineSupplierDetailsViewModel>.reactive(
      viewModelBuilder: () => MachineSupplierDetailsViewModel(),
      onViewModelReady: (MachineSupplierDetailsViewModel model) => model.init(widget.customerId),
      disposeViewModel: false,
      builder: (BuildContext context, MachineSupplierDetailsViewModel model, Widget? child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(context, model),
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              Padding(padding: const EdgeInsets.all(12), child: _buildCustomerContactCard(model)),
              Expanded(
                child: Container(color: AppColors.scaffoldBackground, padding: const EdgeInsets.all(12), child: _buildMachineList(context, model)),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MachineSupplierDetailsViewModel model) {
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
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        model.customerDetails?.organization?.fullName?.toUpperCase()?? 'Loading...',
        style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCustomerContactCard(MachineSupplierDetailsViewModel model) {
    final customer = model.customerDetails;
    final organization = customer?.organization;

    if (model.isLoading) {
      return _buildShimmerContactCard();
    }

    if (model.hasError) {
      return _buildErrorState(model);
    }

    if (customer == null) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorF0F2FC,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('contact_person'.lang, customer.contactPerson?.capitalize() ?? 'N/A'),
                const SizedBox(height: 12),
                _buildContactInfoRow('email'.lang, organization?.email ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('designation'.lang, customer.designation ?? 'N/A'),
                const SizedBox(height: 12),
                _buildContactInfoRow('phone'.lang, organization?.phone ?? customer.phoneNumber ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMachineList(BuildContext context, MachineSupplierDetailsViewModel model) {
    if (model.isLoading) {
      return _buildShimmerMachineList();
    }

    if (model.hasError) {
      return _buildErrorState(model);
    }

    final machines = model.customerDetails?.machines ?? [];

    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
            const SizedBox(height: 20),
            Text('no_machines_assigned'.lang, style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text('this_customer_has_no_machines'.lang, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(children: machines.map((machineElement) => _buildMachineCard(context, machineElement, model)).toList()),
    );
  }

  Widget _buildMachineCard(BuildContext context, MachineElement machineElement, MachineSupplierDetailsViewModel model) {
    final machine = machineElement.machine;
    final machineName = machine?.machineName ?? 'Unknown Machine';
    final modelNumber = machine?.modelNumber ?? 'N/A';
    final machineType = machine?.machineType ?? 'Unknown Type';

    bool isInWarranty = machineElement.warrantyStatus!.toLowerCase().contains('in warranty');


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: AppColors.colorF0F2FC, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  machineName.length >= 2 ? machineName.substring(0, 2).toUpperCase() : 'NA',
                  style: TextStyle(color: AppColors.colorBlue, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(machineName.toUpperCase(), style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold))),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: isInWarranty?AppColors.success.withValues(alpha: 0.15):AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(machineElement.warrantyStatus ?? "", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,color: isInWarranty?AppColors.success:AppColors.error)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => model.onMachineTap(context, machineElement),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                  ),
                  child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.lightGrey),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMachineInfoRow('model_number'.lang, modelNumber.toUpperCase())),
              const SizedBox(width: 24),
              Expanded(child: _buildMachineInfoRow('machine_type'.lang, machineType)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMachineInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildShimmerContactCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.colorF0F2FC,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 80, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 120, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 40, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 150, color: AppColors.lightGrey),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 70, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 100, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 35, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 130, color: AppColors.lightGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMachineList() {
    return Column(children: List.generate(3, (index) => _buildShimmerMachineCard()));
  }

  Widget _buildShimmerMachineCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(16)),
                  child: Container(height: 14, width: 20, color: AppColors.lightGrey),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 16, color: AppColors.lightGrey)),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6)),
                  child: Container(height: 12, width: 50, color: AppColors.lightGrey),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
                  child: Container(height: 16, width: 16, color: AppColors.lightGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.lightGrey),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 80, color: AppColors.lightGrey),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 100, color: AppColors.lightGrey),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 70, color: AppColors.lightGrey),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 120, color: AppColors.lightGrey),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MachineSupplierDetailsViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.redBack),
          const SizedBox(height: 20),
          Text('Error loading customer details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(model.errorMessage, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: model.refreshCustomerDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
          const SizedBox(height: 20),
          Text('No customer details found', style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
