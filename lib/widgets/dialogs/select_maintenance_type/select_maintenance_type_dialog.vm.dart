import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SelectMaintenanceTypeDialogViewModel extends ReactiveViewModel {
  String? _selectedType;
  bool _isGeneralCheckUpDisabled = false;

  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  String? get selectedType => _selectedType;
  bool get isGeneralCheckUpDisabled => _isGeneralCheckUpDisabled;
  bool get isLoading => _isLoading.value;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedOrganizationId;
  String? selectedMachineId;

  void init({bool isGeneralCheckUpDisabled = false}) {
    _isGeneralCheckUpDisabled = isGeneralCheckUpDisabled;

    // If General Check Up is disabled, automatically select Full Machine Service
    if (isGeneralCheckUpDisabled) {
      _selectedType = 'Full Machine Service';
    }

    notifyListeners();
  }

  void selectType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> submit(
    String maintenanceType,
    Future<void> Function(String) onSubmit,
  ) async {
    if (_selectedType == null) return;

    _isLoading.value = true;
    notifyListeners();

    try {
      await onSubmit(maintenanceType);
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoading.value = false;
      notifyListeners();
    }
  }

  bool validateForm() {
    bool isFormValid = formKey.currentState?.validate() ?? false;
    return isFormValid;
  }
}
