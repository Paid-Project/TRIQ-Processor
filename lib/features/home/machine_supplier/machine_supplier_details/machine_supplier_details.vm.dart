import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine_supplier_details_model.dart';
import 'package:manager/services/machine_supplier_details.service.dart';
import 'supplier_machine_details/supplier_machine_details.view.dart';

class MachineSupplierDetailsViewModel extends BaseViewModel {
  final MachineSupplierDetailsService _machineSupplierDetailsService = locator<MachineSupplierDetailsService>();

  MachineSupplierDetailsModel? _customerDetails;
  String? _customerId;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  MachineSupplierDetailsModel? get customerDetails => _customerDetails;

  String? get customerId => _customerId;

  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  void init(String customerId) {
    _customerId = customerId;
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    if (_customerId == null) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final result = await _machineSupplierDetailsService.getCustomerById(_customerId!);

      result.fold(
        (failure) {
          _hasError = true;
          _errorMessage = failure.message;
        },
        (customerDetails) {
          _customerDetails = customerDetails;
        },
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshCustomerDetails() async {
    await _loadCustomerDetails();
  }

  void onMachineTap(BuildContext context, MachineElement machineElement) async {
    final organizationId = _customerDetails?.organization?.id;
    if (organizationId != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => SupplierMachineDetailsView(machineElement: machineElement, organizationId: organizationId)));
    }
  }
}
