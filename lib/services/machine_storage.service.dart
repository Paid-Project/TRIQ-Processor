import 'package:manager/core/models/machine_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/locator.dart';

class MachineStorageService {
  static final MachineStorageService _instance = MachineStorageService._internal();

  factory MachineStorageService() => _instance;

  MachineStorageService._internal();

  final _machineService = locator<MachineService>();
  final _dialogService = locator<DialogService>();

  // In-memory cache only
  List<Datum> _machines = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  List<Datum> get machines => _machines;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  /// Initialize machines data - called only once per manager lifecycle
  Future<void> initializeMachines({bool isUpdate = false}) async {
    if (_isInitialized && !isUpdate) {
      AppLogger.info("Machines already initialized, skipping...");
      return;
    }

    try {
      _isLoading = true;
      AppLogger.info("Initializing machines data...");

      // Always fetch from API, no local storage
      await _fetchMachinesFromAPI();
      _isInitialized = true;
    } catch (e) {
      AppLogger.error("Exception while initializing machines: $e");
      _dialogService.showDialog(title: LanguageService.get('error'), description: LanguageService.get('failed_to_load_machines'));
    } finally {
      _isLoading = false;
    }
  }

  /// Get machines - returns from cache if available
  Future<List<Datum>> getMachines() async {
    if (_machines.isNotEmpty) {
      return _machines;
    }
    return [];
  }

  /// Refresh machines from API (manual refresh)
  Future<void> refreshMachines() async {
    try {
      _isLoading = true;
      AppLogger.info("Refreshing machines from API...");

      await _fetchMachinesFromAPI();
    } catch (e) {
      AppLogger.error("Exception while refreshing machines: $e");
      _dialogService.showDialog(title: LanguageService.get('error'), description: LanguageService.get('failed_to_load_machines'));
    } finally {
      _isLoading = false;
    }
  }

  /// Fetch machines from API and store in memory only
  Future<void> _fetchMachinesFromAPI() async {
    final result = await _machineService.getAllMachines();

    result.fold(
      (failure) {
        AppLogger.error("Failed to load machines: ${failure.message}");
        _dialogService.showDialog(title: LanguageService.get('error'), description: LanguageService.get('failed_to_load_machines'));
        throw Exception(failure.message);
      },
      (machineModel) {
        _machines = machineModel.data ?? [];
      },
    );
  }

  /// Clear machine cache (e.g., on logout or manager reset)
  Future<void> clearMachineStorage() async {
    _machines.clear();
    _isInitialized = false;
    AppLogger.info("Cleared machine cache");
  }

  /// Get machine names for dropdown (commonly used)
  List<String> getMachineNames() {
    return _machines.map((machine) => machine.machineName ?? '').where((name) => name.isNotEmpty).toList();
  }

  /// Find machine by name
  Datum? findMachineByName(String machineName) {
    try {
      return _machines.firstWhere((machine) => machine.machineName == machineName);
    } catch (e) {
      return null;
    }
  }

  /// Check if machines are available
  bool get hasMachines => _machines.isNotEmpty;

  /// Get machine count
  int get machineCount => _machines.length;
}
