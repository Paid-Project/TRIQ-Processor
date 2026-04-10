import 'package:stacked/stacked.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/machine_overview_model.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/core/locator.dart';

class MachineOverviewViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  List<MachineOverviewList> _machines = [];
  List<MachineOverviewList> _filteredMachines = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<MachineOverviewList> get filteredMachines => _filteredMachines;

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
      final response = await _apiService.get(url: ApiEndpoints.getMachineOverview);

      if (response.statusCode == 200) {
        final machineOverviewModel = MachineOverviewModel.fromJson(response.data);
        _machines = machineOverviewModel.data ?? [];
        _filteredMachines = _machines;
      } else {
        _hasError = true;
        _errorMessage = 'Failed to load machines. Please try again.';
      }
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
        _machines.where((machine) {
          bool matchesSearch =
              _searchQuery.isEmpty ||
              (machine.machineName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (machine.modelNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (machine.machineType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (machine.serialNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

          return matchesSearch;
        }).toList();

    notifyListeners();
  }
}
