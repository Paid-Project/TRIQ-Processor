import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/features/machines/add_machine/add_machine.view.dart';
import 'package:manager/features/machines/machines_list/machines_list.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/confirmation/confirmation_dialog.view.dart';
import '../../../widgets/dialogs/machine_details/machine_details_dialog.view.dart';
import '../../organization/add_partner/add_partner.view.dart';

class MachinesListInfo {
  final List<Machine> machines;
  final User? manufacturer;
  final User? processor;

  MachinesListInfo({required this.machines, this.manufacturer, this.processor});

  factory MachinesListInfo.fromJson(Map<String, dynamic> json) {
    return MachinesListInfo(
      machines:
          (json['machines'] as List?)
              ?.map((machine) => Machine.fromJson(machine))
              .toList() ??
          [],
      manufacturer:
          json['manufacturerDetails'] != null
              ? User.fromJson(json['manufacturerDetails'])
              : null,
      processor:
          json['processorDetails'] != null
              ? User.fromJson(json['processorDetails'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': machines.map((machine) => machine.toJson()).toList(),
      'manufacturerDetails': manufacturer?.toJson(),
      'processorDetails': processor?.toJson(),
    };
  }
}

class MachinesListViewModel extends ReactiveViewModel {
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _machineService = locator<MachineService>();
  final _organizationService = locator<OrganizationService>();

  // Optional initial filters
  String initialProcessorId = '';
  String initialOrganizationId = '';

  // Filters
  String? selectedStatus;
  String? selectedDepartment;
  String _searchQuery = '';

  final ReactiveValue<User?> _manufacturer = ReactiveValue(null);
  User? get manufacturer => _manufacturer.value;

  final ReactiveValue<User?> _processor = ReactiveValue(null);
  User? get processor => _processor.value;

  // Reactive values
  final ReactiveValue<List<Machine>> _machines = ReactiveValue<List<Machine>>(
    [],
  );
  final ReactiveValue<List<Machine>> _filteredMachines =
      ReactiveValue<List<Machine>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  List<Machine> get machines => _filteredMachines.value;
  bool get isLoading => _isLoading.value;

  // Search query
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    applyFilters();
    notifyListeners();
  }

  // Department list for filter dropdown
  List<String> departments = [];

  // Status options for filter dropdown
  final List<String> statusOptions = [
    'All',
    'Operational',
    'Maintenance',
    'Out of Service',
    'Standby',
  ];
  bool get isManufacturer =>
      initialProcessorId.isEmpty  && initialOrganizationId.isEmpty?getUser().organizationType == OrganizationType.manufacturer:initialOrganizationId==getUser().organizationId?false:true;

  final _user = ReactiveValue(getUser());
  User get user => _user.value;

  void init(MachinesListViewAttributes attributes) {
    // If no specific processor or organization is provided,
    // use the current user's context
    if (attributes.organizationId.isEmpty && attributes.processorId.isEmpty) {
      // Default logic for current user
      loadMachines(
        processorId:
            getUser().organizationType == OrganizationType.processor
                ? getUser().organizationId
                : null,
        manufacturerId:
            getUser().organizationType == OrganizationType.manufacturer
                ? getUser().organizationId
                : null,
      );
    } else {
      initialOrganizationId = attributes.organizationId;
      initialProcessorId = attributes.processorId;
      loadMachines(
        processorId: initialProcessorId,
        manufacturerId: initialOrganizationId,
      );
    }
  }

  Future<void> removeProcessor({
    required String processorId,
  }) async {
    final dialogResponse = await _dialogService.showCustomDialog(
      variant: DialogType.confirmation,
      data: ConfirmationDialogAttributes(title: 'Do you want to remove this processor?', description: 'This action can not be undone',  confirmText: 'Yes',
        cancelText: 'No',),
    );

    if(dialogResponse?.confirmed != true){
      return;
    }

    final result = await _organizationService.removeManufacturer(
      processorId: processorId,
    );

    result.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
          (isSuccess) {
            Fluttertoast.showToast(msg: 'Processor removed successfully');
            loadMachines(
              processorId: initialProcessorId,
              manufacturerId: initialOrganizationId,
            );
            _navigationService.back();

      },
    );
  }

  Future<void> loadMachines({
    String? processorId,
    String? manufacturerId,
  }) async {
    _isLoading.value = true;
    notifyListeners();

    dynamic result ;

    if(processorId?.isNotEmpty == true && manufacturerId?.isNotEmpty == true){
      result = await _machineService.getMachines(
        status: selectedStatus == 'All' ? null : selectedStatus,
        department: selectedDepartment == 'All' ? null : selectedDepartment,
        manufacturerId: manufacturerId!,
        processorId: processorId!,
      );
    }
   else{
      result = await _machineService.getMachines(
        status: selectedStatus == 'All' ? null : selectedStatus,
        department: selectedDepartment == 'All' ? null : selectedDepartment,
        manufacturerId: getUser().organizationType == OrganizationType.manufacturer
            ? getUser().organizationId ?? ''
            : '',
        processorId: getUser().organizationType == OrganizationType.processor
            ? getUser().organizationId ?? ''
            : '',
      );
    }

    result.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
        _machines.value = [];
        _filteredMachines.value = [];
      },
      (machinesListInfo) {
        _machines.value = machinesListInfo.machines;
        if (getUser().organizationType == OrganizationType.processor) {
          _manufacturer.value = machinesListInfo.manufacturer;
        } else {
          _processor.value = machinesListInfo.processor;
        }
        _updateDepartmentsList(machinesListInfo.machines);
        applyFilters();
      },
    );

    _isLoading.value = false;
    notifyListeners();
  }

  void applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredMachines.value = [..._machines.value];
    } else {
      _filteredMachines.value =
          _machines.value.where((machine) {
            final query = _searchQuery.toLowerCase();

            // Search across different machine properties
            return (machine.machineName?.toLowerCase().contains(query) ??
                    false) ||
                (machine.modelNumber?.toLowerCase().contains(query) ?? false) ||
                (machine.serialNumber?.toLowerCase().contains(query) ??
                    false) ||
                (machine.department?.toLowerCase().contains(query) ?? false) ||
                (machine.status?.toLowerCase().contains(query) ?? false);
          }).toList();
    }
    notifyListeners();
  }

  void _updateDepartmentsList(List<Machine> machines) {
    // Extract unique departments from machines
    final Set<String> uniqueDepartments = {};

    for (final machine in machines) {
      if (machine.department != null && machine.department!.isNotEmpty) {
        uniqueDepartments.add(machine.department!);
      }
    }

    // Add 'All' option to the beginning
    departments = ['All', ...uniqueDepartments.toList()..sort()];

    // If the currently selected department is not in the list anymore, reset it
    if (selectedDepartment != null &&
        selectedDepartment != 'All' &&
        !departments.contains(selectedDepartment)) {
      selectedDepartment = null;
    }
  }

  void updateStatusFilter(String? status) {
    // Only update if value is valid or null
    if (status == null || statusOptions.contains(status)) {
      selectedStatus = status;
      notifyListeners();
    }
  }

  void updateDepartmentFilter(String? department) {
    // Only update if value is valid or null
    selectedDepartment = department;
    notifyListeners();
  }

  void resetFilters() {
    selectedStatus = null;
    selectedDepartment = null;
    _searchQuery = '';
    notifyListeners();
  }

  void onMachineTap(String machineId) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.machineDetails,
      data: MachineDetailsDialogAttributes(
        processorId: initialProcessorId,
        machineId: machineId,
        onEditPressed: onEditMachineTap,
        onRemovePressed: onRemoveMachineTap,
        isAssignedToPartner: initialProcessorId.isNotEmpty||initialOrganizationId.isNotEmpty,
      ),
    );
  }

  void onEditMachineTap(
    BuildContext context, {
    required Machine machine,
  }) async {
    Navigator.pop(context);
    await _navigationService.navigateTo(
      Routes.addMachine,
      parameters:
          AddMachineViewAttributes(
            id: machine.id ?? '',
            isAssignedToPartner: initialProcessorId.isNotEmpty||initialOrganizationId.isNotEmpty,
            processorId: initialProcessorId,
          ).toMap(),
    );

    // Reload machines after returning from edit screen
    if (initialProcessorId.isEmpty && initialProcessorId.isEmpty) {
      // Default logic for current user
      loadMachines(
        processorId:
        getUser().organizationType == OrganizationType.processor
            ? getUser().organizationId
            : null,
        manufacturerId:
        getUser().organizationType == OrganizationType.manufacturer
            ? getUser().organizationId
            : null,
      );
    } else {
      loadMachines(
        processorId: initialProcessorId,
        manufacturerId: initialOrganizationId,
      );
    }
  }

  void onAddMachineTap(BuildContext context) async {
    await _navigationService.navigateTo(
      Routes.addMachine,
      parameters: AddMachineViewAttributes(
        isAssignedToPartner: initialProcessorId.isNotEmpty||initialOrganizationId.isNotEmpty,
      ).toMap(),
    );

    // Reload machines after returning from add screen
    loadMachines(
      processorId: initialProcessorId,
      manufacturerId: initialOrganizationId,
    );
  }



  void onAssignMachineTap(String id) async {
    await _navigationService.navigateTo(
      Routes.addPartner,
      arguments: AddPartnerViewAttributes(id: id,isNewProcessor: initialProcessorId.isEmpty),
    );

    // Reload machines after returning from add screen
    loadMachines(
      processorId: initialProcessorId,
      manufacturerId: initialOrganizationId,
    );
  }

  // void onRemoveMachineTap(
  //   BuildContext context, {
  //   required String machineId,
  // }) async {
  //   Navigator.pop(context);
  //
  //   // Show confirmation dialog
  //   final confirmed = await _dialogService.showConfirmationDialog(
  //     title: 'Remove Machine',
  //     description: 'Are you sure you want to remove this machine?',
  //     confirmationTitle: 'Remove',
  //     cancelTitle: 'Cancel',
  //   );
  //
  //   if (confirmed?.confirmed == true) {
  //     _isLoading.value = true;
  //     notifyListeners();
  //
  //     // Call machine service to delete
  //     // final result = await _machineService.deleteMachine(machineId);
  //     //
  //     // result.fold(
  //     //   (exception) {
  //     //     Fluttertoast.showToast(
  //     //       msg: 'Failed to remove: ${exception.toString()}',
  //     //     );
  //     //   },
  //     //   (_) {
  //     //     Fluttertoast.showToast(msg: 'Machine removed successfully');
  //     //     // Reload machines to refresh the list
  //     //     loadMachines();
  //     //   },
  //     // );
  //   }
  // }
  // void onRemoveMachineTap(
  //     BuildContext context, {
  //       required String machineId,
  //     }) async {
  //   // Don’t pop the dialog again—showDeleteConfirmation has already popped it.
  //   // Just show a confirmation dialog, wait for “confirmed”, then delete + refresh.
  //
  //   // (At this point, you already popped both dialogs;
  //   // the MachineDetailsDialog is gone, and the alert is gone.)
  //
  //   _isLoading.value = true;
  //   notifyListeners();
  //
  //   final result = await _machineService.deleteMachine(machineId);
  //
  //   result.fold(
  //         (exception) {
  //       Fluttertoast.showToast(
  //         msg: 'Failed to remove: ${exception.toString()}',
  //       );
  //       _isLoading.value = false;
  //       notifyListeners();
  //     },
  //         (_) {
  //       Fluttertoast.showToast(msg: 'Machine removed successfully');
  //       // 👇 Reload machines so the MachineCard list refreshes.
  //       loadMachines();
  //       _isLoading.value = false;
  //       notifyListeners();
  //     },
  //   );
  // }
  void onRemoveMachineTap(
      BuildContext context, {
        required String machineId,
      }) async {
   // print(' onRemoveMachineTap called for $machineId');
    _isLoading.value = true;
    notifyListeners();


    final result = await _machineService.deleteMachine(machineId);

    result.fold(
          (failure) {
        Fluttertoast.showToast(msg: 'Failed to remove: ${failure.message}');
        _isLoading.value = false;
        notifyListeners();
      },
          (_) {
        Fluttertoast.showToast(msg: 'Machine removed successfully');
        loadMachines();
        _isLoading.value = false;
        notifyListeners();
      },
    );
  }
}
