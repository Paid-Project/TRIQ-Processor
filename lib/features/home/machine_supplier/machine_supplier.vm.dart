import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine_supplier_model.dart';
import 'package:manager/services/machine_supplier.service.dart';
import 'machine_supplier_details/machine_supplier_details.view.dart';

// Dummy data models
class DummyMachine {
  final String id;
  final String machineName;
  final String? notes;
  final String? organizationName;

  DummyMachine({required this.id, required this.machineName, this.notes, this.organizationName});
}

class DummyOrganization {
  final String id;
  final String fullName;

  DummyOrganization({required this.id, required this.fullName});
}

class MachineSupplierViewModel extends BaseViewModel {
  final MachineSupplierService _machineSupplierService = locator<MachineSupplierService>();
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  List<MachineSupplier> _machineSupplierData = [];
  List<MachineSupplier> _filteredMachines = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<MachineSupplier> get machines => _machineSupplierData;

  List<MachineSupplier> get filteredMachines => _filteredMachines;

  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  void init() {
    _searchQuery = '';
    _loadMachines();
  }

  void clearSearch() {
    _isSearching = false; //
    _searchQuery = '';
    _applyFilters();
  }

  Future<void> _loadMachines() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final result = await _machineSupplierService.getMachineSupplier();

      result.fold(
        (failure) {
          _hasError = true;
          _errorMessage = failure.message;
        },
        (machineSupplierModel) {
          _machineSupplierData = machineSupplierModel.data ?? [];
          _filteredMachines = _machineSupplierData;
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

  Future<void> refreshMachines() async {
    await _loadMachines();
  }

  void onSearchChanged(String query) {
    _isSearching = query.isNotEmpty;
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredMachines =
        _machineSupplierData.where((datum) {
          final customer = datum.customer;
          if (customer == null) return false;

          bool matchesSearch =
              _searchQuery.isEmpty ||
              (customer.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (customer.organization?.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (customer.machines?.any((machine) => machine.machine?.machineName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ??
                  false);

          return matchesSearch;
        }).toList();

    notifyListeners();
  }

  Organization? getOrganizationForMachine(MachineSupplier datum) {
    return datum.customer?.organization;
  }

  void onMachineTap(BuildContext context, MachineSupplier datum) async {
    final customerId = datum.customer?.id;
    if (customerId != null) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => MachineSupplierDetailsView(customerId: customerId)));
    }
  }
}
