import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/features/machines/add_machine/add_machine.view.dart';
import 'package:manager/features/organization/add_partner/add_partner.view.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/models/machine.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/failures.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../../routes/routes.dart';

class MachineAssignment {
  final String id;
  DateTime? startDate;
  DateTime? purchaseDate;
  DateTime? expirationDate;
  DateTime? installationDate;
  String? invoiceNo;
  final Machine machine;

  MachineAssignment({
    required this.id,
    this.startDate,
    this.purchaseDate,
    this.expirationDate,
    this.installationDate,
    this.invoiceNo,
    required this.machine,
  });

  // Check if all required fields are filled
  bool get isComplete =>
      startDate != null && purchaseDate != null && expirationDate != null;

  Map<String, dynamic> toJson() {
    return {
      'machineId': id,
      'startDate': startDate?.toIso8601String().split('T')[0],
      'purchaseDate': purchaseDate?.toIso8601String().split('T')[0],
      'expirationDate': expirationDate?.toIso8601String().split('T')[0],
      'installationDate': installationDate?.toIso8601String().split('T')[0],
      'invoiceNo': invoiceNo,
    };
  }
}

class AddPartnerViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _organizationService = locator<OrganizationService>();
  final _machineService = locator<MachineService>();

  final formKey = GlobalKey<FormState>();

  final ReactiveValue<String> _phoneNumber = ReactiveValue('');
  final ReactiveValue<String> _email = ReactiveValue('');
  final ReactiveValue<String> _contactPerson = ReactiveValue('');
  final ReactiveValue<String> _name = ReactiveValue('');

  final ReactiveValue<String> _designationType = ReactiveValue<String>('md');
  String get designationType => _designationType.value;
  void updateDesignationType(String? value) {
    if (value != null) {
      _designationType.value = value;
      notifyListeners();
    }
  }

  final ReactiveValue<bool> _showOtherDesignation = ReactiveValue<bool>(false);
  bool get showOtherDesignation => _showOtherDesignation.value;
  set showOtherDesignation(bool value) {
    _showOtherDesignation.value = value;
    notifyListeners();
  }

  String _countryCode = '';
  String get countryCode => _countryCode;
  String get phoneNumber => _phoneNumber.value;
  String get email => _email.value;
  String get contactPerson => _contactPerson.value;
  String get name => _name.value;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  User? _partner;
  User? get partner => _partner;

  List<Machine>? _machines;
  List<Machine>? get machines => _machines;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Add a new controller for invoice number
  final TextEditingController invoiceNoController = TextEditingController();

  List<MachineAssignment> _machineAssignments = [];
  List<MachineAssignment> get machineAssignments => _machineAssignments;

  // Updated getter to check if save button should be enabled
  bool get isSaveEnabled {
    if(getUser().organizationType==OrganizationType.processor) return true;

    // Check that form is valid
    if (!isFormValid) return false;

    // Check that at least one machine is selected
    if (_machineAssignments.isEmpty) return false;

    // Check that all machine assignments have their required dates
    for (var assignment in _machineAssignments) {
      if (!assignment.isComplete) return false;
    }

    return true;
  }

  // Find incomplete machine assignments
  List<MachineAssignment> get incompleteMachineAssignments {
    return _machineAssignments
        .where((assignment) => !assignment.isComplete)
        .toList();
  }

  late AddPartnerViewAttributes _attributes;

  Future init(AddPartnerViewAttributes attributes) async {
    AppLogger.error("${attributes.id}");
    _attributes = attributes;
    if (attributes.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setBusy(true);
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            tasks: [
                  () =>
                  _organizationService.getPendingProcessorById(attributes.id!),
                  () => _machineService.getMyMachines(),
            ],
            message: "Loading partner data...",
          ),
        );
        if (response?.data != null) {
          final results = response!.data as List;
          final userResult = results[0] as EitherResult<User>;
          final machinesResult = results[1] as EitherResult<List<Machine>>;

          userResult.fold(
                (exception) {
              Fluttertoast.showToast(msg: exception.message.toString());
              _navigationService.back();
            },
                (user) async {
              _partner = user;
              _partner = _partner?.copyWith(id: attributes.id!);
              _phoneNumber.value = user.phone ?? '';
              _email.value = user.email ?? '';
              _name.value = user.name ?? '';
              _contactPerson.value = user.yourName ?? '';
              notifyListeners();
            },
          );

          machinesResult.fold(
                (exception) {
              Fluttertoast.showToast(msg: exception.message.toString());
            },
                (machines) {
              _machines = machines;
              notifyListeners();
            },
          );
        }
        _updateFormValidity();
        setBusy(false);
      });
    }
    else{
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setBusy(true);
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.loader,
          data: LoaderDialogAttributes(
            task: () => _machineService.getMyMachines(),
            message: "Loading partner data...",
          ),
        );
        if (response?.data != null) {
          final machinesResult = response!.data as EitherResult<List<Machine>>;

          machinesResult.fold(
                (exception) {
              Fluttertoast.showToast(msg: exception.message.toString());
            },
                (machines) {
              _machines = machines;
              notifyListeners();
            },
          );
        }
        _updateFormValidity();
        setBusy(false);
      });
    }
  }

  void _updateFormValidity() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  setSaving(bool value){
    _isSaving = value;
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _countryCode = phoneNumber.countryCode;
    _updateFormValidity();
  }

  void onSave() async {
    _updateFormValidity();
    setSaving(true);
    if (getUser().organizationType==OrganizationType.processor) {
      await addManufacturer();
      setSaving(false);
      return;
    }

    if (_machineAssignments.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one machine');
      setSaving(false);
      return;
    }

    // Check for incomplete machine assignments
    final incomplete = incompleteMachineAssignments;
    if (incomplete.isNotEmpty) {
      final machineNames = incomplete
          .map(
            (assignment) => assignment.machine.machineName ?? 'Unnamed Machine',
      )
          .join(', ');
      Fluttertoast.showToast(
        msg: 'Please fill all date fields for: $machineNames',
        toastLength: Toast.LENGTH_LONG,
      );
      setSaving(false);
      return;
    }

    if (isSaveEnabled) {
      await addProcessor();
      setSaving(false);
    }
  }

  void addMachineAssignment(Machine machine) {
    // Check if machine is already added
    if (_machineAssignments.any((assignment) => assignment.id == machine.id)) {
      Fluttertoast.showToast(msg: 'Machine already added');
      return;
    }

    AppLogger.info('Adding machine: ${machine.id}');
    _machineAssignments.add(
      MachineAssignment(id: machine.id ?? '', machine: machine),
    );
    _updateFormValidity();
    notifyListeners();
  }

  void removeMachineAssignment(String machineId) {
    _machineAssignments.removeWhere((assignment) => assignment.id == machineId);
    _updateFormValidity();
    notifyListeners();
  }

  void updateMachineStartDate(String machineId, DateTime date) {
    final index = _machineAssignments.indexWhere((a) => a.id == machineId);
    if (index != -1) {
      _machineAssignments[index].startDate = date;
      notifyListeners();
    }
  }

  void updateMachineInstallationDate(String machineId, DateTime date) {
    final index = _machineAssignments.indexWhere((a) => a.id == machineId);
    if (index != -1) {
      _machineAssignments[index].installationDate = date;
      notifyListeners();
    }
  }

  void updateMachinePurchaseDate(String machineId, DateTime date) {
    final index = _machineAssignments.indexWhere((a) => a.id == machineId);
    if (index != -1) {
      _machineAssignments[index].purchaseDate = date;
      notifyListeners();
    }
  }

  void updateMachineExpirationDate(String machineId, DateTime date) {
    final index = _machineAssignments.indexWhere((a) => a.id == machineId);
    if (index != -1) {
      _machineAssignments[index].expirationDate = date;
      notifyListeners();
    }
  }


  // Add a method to update invoice number
  void updateMachineInvoiceNo(String machineId, String invoiceNo) {
    final index = _machineAssignments.indexWhere((a) => a.id == machineId);
    if (index != -1) {
      _machineAssignments[index].invoiceNo = invoiceNo;
      notifyListeners();
    }
  }

  // Add navigation to add machine
  void navigateToAddMachine() async {
    final result = await _navigationService.navigateTo(
      Routes.addMachine,
      parameters: AddMachineViewAttributes(isAssignedToPartner: false).toMap(),
    );
    await init(_attributes);
  }

  // Refresh machines after adding a new one
  Future<void> refreshMachines() async {
    setBusy(true);
    final result = await _machineService.getMyMachines();
    result.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
          (machines) {
        _machines = machines;
        notifyListeners();
      },
    );
    setBusy(false);
  }

  Future addManufacturer() async {
    Either<Failure, String>? response;
      response = await _organizationService.addManufacturer(
        id: _partner!.id ?? '',
      );

    response.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
          (success) async {
        Fluttertoast.showToast(msg: 'Request sent successfully!');
        _navigationService.back();
      },
    );
  }


  Future addProcessor() async {
    Either<Failure, String>? response;

    if (_attributes.hasPasswordField) {
      response = await _organizationService.addNewProcessor(
        fullName: nameController.text,
        email: emailController.text,
        contactPerson: contactPersonController.text,
        phone: phoneController.text,
        password: passwordController.text,
        assignedMachines:
        _machineAssignments
            .map((assignment) => assignment.toJson())
            .toList(),
        countryCode: _countryCode,
      );
    } else {
      if(_attributes.isNewProcessor) {
        response = await _organizationService.addProcessor(
          id: _partner!.id ?? '',
          assignedMachines:
              _machineAssignments
                  .map((assignment) => assignment.toJson())
                  .toList(),
        );
      }else{
        response = await _organizationService.addMachinesToProcessor(
          id: _partner!.id ?? '',
          assignedMachines:
          _machineAssignments
              .map((assignment) => assignment.toJson())
              .toList(),
        );
      }
    }

    response.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
          (success) async {
        Fluttertoast.showToast(msg: 'Machine assigned successfully!');
        _navigationService.back();
      },
    );
  }

  final TextEditingController machineSearchController = TextEditingController();
  List<Machine> _filteredMachines = [];
  List<Machine> get filteredMachines => _filteredMachines;

  // Get invoiceNo for a specific machine
  String getInvoiceNo(String machineId) {
    final assignment = _machineAssignments.firstWhere(
          (a) => a.id == machineId,
      orElse: () => MachineAssignment(id: machineId, machine: Machine()),
    );
    return assignment.invoiceNo ?? '';
  }

  void filterMachines(String query) {
    if (query.isEmpty) {
      _filteredMachines = [];
    } else {
      _filteredMachines =
          machines?.where((machine) {
            final nameMatch =
                machine.machineName?.toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                    false;
            final modelMatch =
                machine.modelNumber?.toLowerCase().contains(
                  query.toLowerCase(),
                ) ??
                    false;
            return nameMatch || modelMatch;
          }).toList() ??
              [];
    }
    notifyListeners();
  }
}