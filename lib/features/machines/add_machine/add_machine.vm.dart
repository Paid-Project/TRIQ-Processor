import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/machines/add_machine/add_machine.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/machine.service.dart';

class AdditionalInfoSection {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  AdditionalInfoSection({
    required this.titleController,
    required this.descriptionController,
  });
}

class AddMachineViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _machineService = locator<MachineService>();

  final formKey = GlobalKey<FormState>();

  // Basic machine info controllers
  final TextEditingController machineNameController = TextEditingController();
  final TextEditingController modelNumberController = TextEditingController();
  final TextEditingController invoiceNoController = TextEditingController();

  // Machine size controllers
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController dimensionUnitController = TextEditingController(
    text: 'mm',
  );

  // Power controller
  final TextEditingController powerController = TextEditingController();

  // Warranty controllers
  final TextEditingController warrantyStartDateController =
      TextEditingController();
  final TextEditingController warrantyExpiryDateController =
      TextEditingController();
  final TextEditingController warrantyStatusController = TextEditingController(
    text: 'Active',
  );
  final List<String> warrantyStatusOptions = ['Active', 'Expired', 'N/A'];

  // Purchase Date controller
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController installationDateController =
      TextEditingController();

  final TextEditingController maximumAreaController = TextEditingController();
  final TextEditingController minimumAreaController = TextEditingController();
  final TextEditingController dimensionAreaUnitController =
      TextEditingController(text: 'mm');

  // Date variables
  DateTime? warrantyStartDate;
  DateTime? warrantyExpiryDate;
  DateTime? purchaseDate;
  DateTime? installationDate;

  // Additional info sections
  final List<AdditionalInfoSection> _additionalInfoSections = [];

  List<AdditionalInfoSection> get additionalInfoSections => _additionalInfoSections;

  // For editing existing machine
  String? machineId;
  String? processorId;
  bool _isEditing = false;

  bool get isEditing => _isEditing;

  // Machine type
  MachineType _selectedMachineType = MachineType.fullyAutomatic;

  MachineType get selectedMachineType => _selectedMachineType;

  // Dimension unit options
  final List<String> dimensionUnitOptions = ['mm', 'cm', 'm', 'inch', 'ft'];

  bool _isFormValid = false;

  bool get isFormValid => _isFormValid;

  void init(AddMachineViewAttributes attributes) {
    if (attributes.id.isNotEmpty) {
      machineId = attributes.id;
      processorId = attributes.processorId;
      _isEditing = true;
      _loadMachineData(
        machineId: attributes.id,
        processorId: attributes.processorId,
      );
    }
  }

  void _loadMachineData({
    required String machineId,
    String? processorId,
  }) async {
    setBusy(true);
    final result = await _machineService.getMachineById(
      machineId: machineId,
      processorId: processorId,
    );

    result.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.toString());
        _navigationService.back();
      },
      (machine) {
        // Populate existing controllers
        machineNameController.text = machine.machineName ?? '';
        modelNumberController.text = machine.modelNumber ?? '';

        // Technical specifications
        if (machine.technicalSpecifications != null) {
          // Power
          if (machine.technicalSpecifications!.powerRequirements != null) {
            powerController.text =
                machine
                    .technicalSpecifications!
                    .powerRequirements!
                    .powerConsumption
                    ?.toString() ??
                '';
          }

          // Machine Type
          _selectedMachineType =
              machine.technicalSpecifications!.machineType ??
              MachineType.fullyAutomatic;

          // Dimensions
          if (machine.technicalSpecifications!.dimensions != null) {
            widthController.text =
                machine.technicalSpecifications!.dimensions!.width
                    ?.toString() ??
                '';
            heightController.text =
                machine.technicalSpecifications!.dimensions!.height
                    ?.toString() ??
                '';
            depthController.text =
                machine.technicalSpecifications!.dimensions!.depth
                    ?.toString() ??
                '';
            dimensionUnitController.text =
                machine.technicalSpecifications!.dimensions!.unit ?? 'cm';
            maximumAreaController.text =
                machine.technicalSpecifications!.processingArea!.max
                    ?.toString() ??
                '';
            minimumAreaController.text =
                machine.technicalSpecifications!.processingArea!.min
                    ?.toString() ??
                '';
            dimensionAreaUnitController.text =
                machine.technicalSpecifications!.processingArea!.unit
                    ?.toString() ??
                '';
          }

          // Load additional info sections
          if (machine.technicalSpecifications!.additionalInfo != null &&
              machine.technicalSpecifications!.additionalInfo!.isNotEmpty) {
            for (var info in machine.technicalSpecifications!.additionalInfo!) {
              final section = AdditionalInfoSection(
                titleController: TextEditingController(text: info.title ?? ''),
                descriptionController: TextEditingController(
                  text: info.description ?? '',
                ),
              );
              _additionalInfoSections.add(section);
            }
          }
        }

        // Load warranty information
        if (machine.warranty != null && machine.warranty != null) {
          warrantyStatusController.text = machine.warranty?.status ?? 'Active';

          if (machine.warranty?.startDate != null) {
            try {
              warrantyStartDate = DateTime.parse(machine.warranty!.startDate!);
              warrantyStartDateController.text = _formatDate(
                warrantyStartDate!,
              );
            } catch (e) {
              // Handle parsing error
            }
          }

          if (machine.warranty!.expirationDate != null) {
            try {
              warrantyExpiryDate = DateTime.parse(
                machine.warranty!.expirationDate!,
              );
              warrantyExpiryDateController.text = _formatDate(
                warrantyExpiryDate!,
              );
            } catch (e) {
              // Handle parsing error
            }
          }

          // Load purchase date
          if (machine.warranty!.purchaseDate != null) {
            try {
              purchaseDate = DateTime.parse(machine.warranty!.purchaseDate!);
              purchaseDateController.text = _formatDate(purchaseDate!);
            } catch (e) {
              // Handle parsing error
            }
          }

          if (machine.warranty!.installationDate != null) {
            try {
              installationDate = DateTime.parse(
                machine.warranty!.installationDate!,
              );
              installationDateController.text = _formatDate(installationDate!);
            } catch (e) {
              // Handle parsing error
            }
          }

          invoiceNoController.text = machine.warranty?.invoiceNo ?? '';
        }

        notifyListeners();
      },
    );

    setBusy(false);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> selectWarrantyStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: warrantyStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      warrantyStartDate = date;
      warrantyStartDateController.text = _formatDate(date);
      notifyListeners();
    }
  }

  Future<void> selectWarrantyExpiryDate(BuildContext context) async {
    final DateTime firstDate = DateTime(2000);
    DateTime initialDate;

    if (warrantyExpiryDate != null) {
      // If we have an existing expiry date, use it but ensure it's not before firstDate
      initialDate =
          warrantyExpiryDate!.isBefore(firstDate)
              ? firstDate
              : warrantyExpiryDate!;
    } else {
      // If no expiry date, use warrantyStartDate or DateTime.now(), whichever is later
      final DateTime fallbackDate = warrantyStartDate ?? DateTime.now();
      initialDate = fallbackDate.isBefore(firstDate) ? firstDate : fallbackDate;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      warrantyExpiryDate = date;
      warrantyExpiryDateController.text = _formatDate(date);
      notifyListeners();
    }
  }

  Future<void> selectPurchaseDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      purchaseDate = date;
      purchaseDateController.text = _formatDate(date);
      notifyListeners();
    }
  }

  Future<void> selectInstallationDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: installationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      installationDate = date;
      installationDateController.text = _formatDate(date);
      notifyListeners();
    }
  }

  void addNewInfoSection() {
    _additionalInfoSections.add(
      AdditionalInfoSection(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
      ),
    );
    notifyListeners();
  }

  void removeInfoSection(int index) {
    if (index >= 0 && index < _additionalInfoSections.length) {
      _additionalInfoSections.removeAt(index);
      notifyListeners();
    }
  }

  void _updateFormValidity() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }

    setBusy(false);
  }

  void updateMachineType(dynamic value) {
    if (value != null && value is MachineType) {
      _selectedMachineType = value;
      notifyListeners();
    }
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void onSave() async {
    if (formKey.currentState?.validate() ?? false) {
      setSaving(true);
      if (_isEditing) {
        await _updateMachine();
      } else {
        await _createMachine();
      }
      setSaving(false);
    } else {
      Fluttertoast.showToast(msg: 'Please fill all required fields');
    }
  }

  Future<void> _createMachine() async {
    setBusy(true);
    // Gather all form data
    final Map<String, dynamic> dimensions = {
      'width': double.tryParse(widthController.text) ?? 0,
      'height': double.tryParse(heightController.text) ?? 0,
      'depth': double.tryParse(depthController.text) ?? 0,
      'unit': dimensionUnitController.text.trim(),
    };

    final Map<String, dynamic> processingArea = {
      'max': double.tryParse(maximumAreaController.text) ?? 0,
      'min': double.tryParse(minimumAreaController.text) ?? 0,
      'unit': dimensionAreaUnitController.text.trim(),
    };

    final Map<String, dynamic> powerRequirements = {
      'powerConsumption': double.tryParse(powerController.text) ?? 0,
      'voltage': 0,
      'amperage': 0,
      'phase': 1,
    };

    // Process additional info sections
    List<Map<String, dynamic>> additionalInfo =
        _additionalInfoSections.map((section) {
          return {
            'title': section.titleController.text.trim(),
            'description': section.descriptionController.text.trim(),
          };
        }).toList();

    final Map<String, dynamic> technicalSpecifications = {
      'dimensions': dimensions,
      'processingArea': processingArea,
      'powerRequirements': powerRequirements,
      'machineType': _selectedMachineType.name,
      'additionalInfo': additionalInfo,
    };

    // Warranty data
    final Map<String, dynamic> warranty = {
      'status': warrantyStatusController.text.trim(),
      'startDate': warrantyStartDate?.toIso8601String() ?? '',
      'expirationDate': warrantyExpiryDate?.toIso8601String() ?? '',
    };

    final response = await _machineService.createMachine(
      machineName: machineNameController.text.trim(),
      modelNumber: modelNumberController.text.trim(),
      operatingHours: 0,
      // Default value
      technicalSpecifications: technicalSpecifications,
      warranty: warranty,
      purchaseDate: purchaseDate?.toIso8601String() ?? '',
    );

    setBusy(false);
    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: 'Machine created successfully!');
        _navigationService.back();
      },
    );
  }

  Future<void> _updateMachine() async {
    setBusy(true);
    final updateData = {
      'machineName': machineNameController.text.trim(),
      'modelNumber': modelNumberController.text.trim(),
      'technicalSpecifications': {
        'dimensions': {
          'width': double.tryParse(widthController.text) ?? 0,
          'height': double.tryParse(heightController.text) ?? 0,
          'depth': double.tryParse(depthController.text) ?? 0,
          'unit': dimensionUnitController.text.trim(),
        },
        'processingArea': {
          'max': double.tryParse(maximumAreaController.text) ?? 0,
          'min': double.tryParse(minimumAreaController.text) ?? 0,
          'unit': dimensionAreaUnitController.text.trim(),
        },
        'powerRequirements': {
          'powerConsumption': double.tryParse(powerController.text) ?? 0,
          'voltage': 0,
          'amperage': 0,
          'phase': 1,
        },
        'machineType': _selectedMachineType.name,
        'additionalInfo':
            _additionalInfoSections.map((section) {
              return {
                'title': section.titleController.text.trim(),
                'description': section.descriptionController.text.trim(),
              };
            }).toList(),
      },
      'warranty': {
        'status': warrantyStatusController.text.trim(),
        'startDate': warrantyStartDate?.toIso8601String() ?? '',
        'expirationDate': warrantyExpiryDate?.toIso8601String() ?? '',
        'purchaseDate': purchaseDate?.toIso8601String() ?? '',
      },
    };

    final response = await _machineService.updateMachine(
      machineId: machineId!,
      processorId: processorId!,
      updateData: updateData,
    );

    setBusy(false);
    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.toString());
      },
      (success) {
        Fluttertoast.showToast(msg: 'Machine updated successfully!');
        _navigationService.back();
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    machineNameController.dispose();
    modelNumberController.dispose();
    widthController.dispose();
    heightController.dispose();
    depthController.dispose();
    dimensionUnitController.dispose();
    powerController.dispose();
    warrantyStartDateController.dispose();
    warrantyExpiryDateController.dispose();
    warrantyStatusController.dispose();
    purchaseDateController.dispose();

    // Dispose additional info section controllers
    for (var section in _additionalInfoSections) {
      section.titleController.dispose();
      section.descriptionController.dispose();
    }

    super.dispose();
  }
}
