// department_hierarchy.vm.dart
import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../core/locator.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../../routes/routes.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import '../../employee/add_employee/add_employee.view.dart';
import '../../employee/detail_employee/employee_details.dart';
import '../../search/search_view.dart';
import 'employee_role_cards.vm.dart';

// ViewModel for the hierarchy view
class DepartmentHierarchyViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final employeeService = locator<EmployeeService>();
  final _bottomSheetService = locator<BottomSheetService>();

  List<Employee> _allEmployees = [];
  Department? _currentDepartment;

  // Updated role priority mapping with country-based structure
  final Map<String, int> rolePriority = {
    // Manufacturer
    "Head of Global Service": 1,
    "Country Service Manager": 3,
    "Local Service Engineers": 5,
    "Installation Engineers": 7,

    // Processor
    "Plant Head": 2,
    "Line Incharge": 4,
    "Maintenance Head": 6,
    "Maintenance Engineers": 8,
    "Machine Operators": 10,
    "Labour": 12,
  };

  Future<void> init(Department department) async {
    _currentDepartment = department;
    await _loadDepartmentEmployees();
  }

  Future<void> _loadDepartmentEmployees() async {
    setBusy(true);

    try {
      final response = await employeeService.getAllEmployees();
      response.fold(
            (exception) {
          _allEmployees = [];
        },
            (allEmployees) {
          final departmentRoles = _getRolesForDepartment(_currentDepartment!)
              .map((role) => _getRoleDisplayName(role))
              .toList();

          _allEmployees = allEmployees.where((employee) {
            return departmentRoles.contains(employee.role);
          }).toList();
        },
      );
    } catch (e) {
      _allEmployees = [];
    }
    setBusy(false);
  }

  List<UserRole> _getRolesForDepartment(Department department) {
    switch (department) {
      case Department.serviceDepartment:
        return [
          UserRole.headOfGlobalService,
          UserRole.countryServiceManager,
          UserRole.localServiceEngineers,
          UserRole.installationEngineers,
        ];
      case Department.productionDepartmentProcessor:
        return [
          UserRole.plantHead,
          UserRole.lineInCharge,
          UserRole.maintenanceHead,
          UserRole.maintenanceEngineer,
          UserRole.machineOperator,
          UserRole.labour,
        ];
      default:
        return [];
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.headOfGlobalService:
        return 'Head of Global Service';
      case UserRole.countryServiceManager:
        return 'Country Service Manager';
      case UserRole.localServiceEngineers:
        return 'Local Service Engineers';
      case UserRole.installationEngineers:
        return 'Installation Engineers';
      case UserRole.plantHead:
        return 'Plant Head';
      case UserRole.lineInCharge:
        return 'Line Incharge';
      case UserRole.maintenanceHead:
        return 'Maintenance Head';
      case UserRole.maintenanceEngineer:
        return 'Maintenance Engineers';
      case UserRole.machineOperator:
        return 'Machine Operators';
      case UserRole.labour:
        return 'Labour';
      default:
        return 'Unknown Role';
    }
  }

  List<HierarchyLevel> getHierarchyData() {
    if (_allEmployees.isEmpty) return [];

    // For manufacturer service department, create country-based hierarchy
    if (_currentDepartment == Department.serviceDepartment) {
      return _createCountryBasedServiceHierarchy();
    }

    // For processor production department, create role-based hierarchy
    if (_currentDepartment == Department.productionDepartmentProcessor) {
      return _createProductionDepartmentHierarchy();
    }

    // Default simple role-based grouping for other departments
    return _createSimpleRoleHierarchy();
  }

  List<HierarchyLevel> _createCountryBasedServiceHierarchy() {
    List<HierarchyLevel> hierarchyLevels = [];

    // First, add Head of Global Service (global level)
    final globalHeads = _allEmployees.where((e) => e.role == 'Head of Global Service').toList();
    if (globalHeads.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Head of Global Service',
        employees: globalHeads,
        indentLevel: 0,
        priority: 1,
        countryCode: null, // Global role, no specific country
      ));
    }

    // Group all employees by country
    Map<String, List<Employee>> employeesByCountry = {};

    // Get all non-global employees and group by country
    final countryEmployees = _allEmployees.where((e) => e.role != 'Head of Global Service').toList();

    for (final employee in countryEmployees) {
      final country = employee?.currentCountry ?? employee?.country ?? "Country Name";
      if (!employeesByCountry.containsKey(country)) {
        employeesByCountry[country] = [];
      }
      employeesByCountry[country]!.add(employee);
    }

    // Sort countries alphabetically
    final sortedCountries = employeesByCountry.keys.toList()..sort();

    // For each country, create a complete hierarchy
    for (final country in sortedCountries) {
      final countryEmployees = employeesByCountry[country]!;
      final countryCode = _getCountryCode(country);

      // Country Service Managers for this country
      final countryManagers = countryEmployees.where((e) => e.role == 'Country Service Manager').toList();
      if (countryManagers.isNotEmpty) {
        hierarchyLevels.add(HierarchyLevel(
          roleTitle: 'Country Service Manager - $country',
          employees: countryManagers,
          indentLevel: 1,
          priority: 3,
          countryCode: countryCode,
        ));
      }

      // Local Service Engineers for this country
      final localEngineers = countryEmployees.where((e) => e.role == 'Local Service Engineers').toList();
      if (localEngineers.isNotEmpty) {
        hierarchyLevels.add(HierarchyLevel(
          roleTitle: 'Local Service Engineers - $country',
          employees: localEngineers,
          indentLevel: 2,
          priority: 5,
          countryCode: countryCode,
        ));
      }

      // Installation Engineers for this country
      final installationEngineers = countryEmployees.where((e) => e.role == 'Installation Engineers').toList();
      if (installationEngineers.isNotEmpty) {
        hierarchyLevels.add(HierarchyLevel(
          roleTitle: 'Installation Engineers - $country',
          employees: installationEngineers,
          indentLevel: 2,
          priority: 7,
          countryCode: countryCode,
        ));
      }
    }

    return hierarchyLevels;
  }

  List<HierarchyLevel> _createProductionDepartmentHierarchy() {
    List<HierarchyLevel> hierarchyLevels = [];

    // Plant Head at the top
    final plantHeads = _allEmployees.where((e) => e.role == 'Plant Head').toList();
    if (plantHeads.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Plant Head',
        employees: plantHeads,
        indentLevel: 0,
        priority: 2,
        countryCode: plantHeads.first.currentCountry != null ? _getCountryCode(plantHeads.first.currentCountry!) : null,
      ));
    }

    // Line Incharge
    final lineIncharge = _allEmployees.where((e) => e.role == 'Line Incharge').toList();
    if (lineIncharge.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Line Incharge',
        employees: lineIncharge,
        indentLevel: 1,
        priority: 4,
        countryCode: lineIncharge.first.currentCountry != null ? _getCountryCode(lineIncharge.first.currentCountry!) : null,
      ));
    }

    // Maintenance Head
    final maintenanceHeads = _allEmployees.where((e) => e.role == 'Maintenance Head').toList();
    if (maintenanceHeads.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Maintenance Head',
        employees: maintenanceHeads,
        indentLevel: 1,
        priority: 6,
        countryCode: maintenanceHeads.first.currentCountry != null ? _getCountryCode(maintenanceHeads.first.currentCountry!) : null,
      ));

      // Maintenance Engineers under Maintenance Head
      final maintenanceEngineers = _allEmployees.where((e) => e.role == 'Maintenance Engineers').toList();
      if (maintenanceEngineers.isNotEmpty) {
        hierarchyLevels.add(HierarchyLevel(
          roleTitle: 'Maintenance Engineers / Technicians',
          employees: maintenanceEngineers,
          indentLevel: 2,
          priority: 8,
          countryCode: maintenanceEngineers.first.currentCountry != null ? _getCountryCode(maintenanceEngineers.first.currentCountry!) : null,
        ));
      }
    }

    // Machine Operators
    final machineOperators = _allEmployees.where((e) => e.role == 'Machine Operators').toList();
    if (machineOperators.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Machine Operators',
        employees: machineOperators,
        indentLevel: 1,
        priority: 10,
        countryCode: machineOperators.first.currentCountry != null ? _getCountryCode(machineOperators.first.currentCountry!) : null,
      ));
    }

    // Labour
    final labour = _allEmployees.where((e) => e.role == 'Labour').toList();
    if (labour.isNotEmpty) {
      hierarchyLevels.add(HierarchyLevel(
        roleTitle: 'Labour',
        employees: labour,
        indentLevel: 1,
        priority: 12,
        countryCode: labour.first.currentCountry != null ? _getCountryCode(labour.first.currentCountry!) : null,
      ));
    }

    return hierarchyLevels;
  }

  List<HierarchyLevel> _createSimpleRoleHierarchy() {
    // Group employees by role
    Map<String, List<Employee>> employeesByRole = {};

    for (final employee in _allEmployees) {
      final role = employee.role ?? 'Unknown Role';
      if (!employeesByRole.containsKey(role)) {
        employeesByRole[role] = [];
      }
      employeesByRole[role]!.add(employee);
    }

    // Sort roles by priority and create hierarchy levels
    final sortedRoles = employeesByRole.keys.toList()
      ..sort((a, b) {
        final priorityA = rolePriority[a] ?? 999;
        final priorityB = rolePriority[b] ?? 999;
        return priorityA.compareTo(priorityB);
      });

    List<HierarchyLevel> hierarchyLevels = [];

    for (int i = 0; i < sortedRoles.length; i++) {
      final role = sortedRoles[i];
      final employees = employeesByRole[role]!;
      final priority = rolePriority[role] ?? 999;

      hierarchyLevels.add(HierarchyLevel(
        roleTitle: role,
        employees: employees,
        indentLevel: i > 0 ? 1 : 0,
        priority: priority,
        countryCode: employees.first.currentCountry != null ? _getCountryCode(employees.first.currentCountry!) : null,
      ));
    }

    return hierarchyLevels;
  }

  String? _getCountryCode(String countryName) {
    try {
      final country = countries.firstWhere(
            (c) => c.name.toLowerCase() == countryName.toLowerCase(),
      );
      return country.code;
    } catch (e) {
      // Try to find partial matches for common variations
      try {
        final country = countries.firstWhere(
              (c) => c.name.toLowerCase().contains(countryName.toLowerCase()) ||
              countryName.toLowerCase().contains(c.name.toLowerCase()),
        );
        return country.code;
      } catch (e) {
        return null; // Return null if country not found
      }
    }
  }

  showScanQrOptions() async {
    final response = await _bottomSheetService
        .showCustomSheet<QrScanSheetResponse, QrScanSheetAttributes>(
      variant: BottomSheetType.qrScan,
      data: QrScanSheetAttributes(),
      isScrollControlled: true,
    );
    if (response?.confirmed == true) {
      await Future.delayed(Duration.zero);
      if (response?.data?.qrSource == QrSource.gallery) {
        navigateToScanQRFromGallery(
              (data) => navigateToAddEmployee(
            AddEmployeeViewAttributes(id: data as String),
          ),
        );
      }
      if (response?.data?.qrSource == QrSource.camera) {
        navigateToScanQRFromCamera(
              (data) => navigateToAddEmployee(
            AddEmployeeViewAttributes(id: data as String),
          ),
        );
      }
      if ([
        QrSource.phoneNumber,
        QrSource.email,
      ].contains(response?.data?.qrSource)) {
        navigateToSearch(
          SearchViewAttributes(
            title: 'Employee',
            apiEndPoint: 'employee/search',
            onSelect: (data) {
              _navigationService.back();
              navigateToAddEmployee(
                AddEmployeeViewAttributes(id: data as String),
              );
            },
          ),
        );
      }
      if ([
        QrSource.addNew,
      ].contains(response?.data?.qrSource)) {
        navigateToAddEmployee(
          AddEmployeeViewAttributes(
            id: null,
            hasPasswordField: true,
            hasReadOnly: false,
          ),
        );
      }
    }
  }

  void navigateToEmployeeDetail(Employee employee) {
    _navigationService.navigateTo(
      Routes.employee,
      parameters: EmployeeDetailsViewAttributes(employeeId: employee.id!).toJson(),
    );
  }

  void navigateToAddEmployee(AddEmployeeViewAttributes attributes) async {
    await _navigationService.navigateTo(
      Routes.addEmployee,
      arguments: attributes,
    );
  }
}

// Updated data class for hierarchy levels with country support
class HierarchyLevel {
  final String roleTitle;
  final List<Employee> employees;
  final int indentLevel;
  final int priority;
  final String? countryCode; // Added country code for flag display

  HierarchyLevel({
    required this.roleTitle,
    required this.employees,
    required this.indentLevel,
    required this.priority,
    this.countryCode,
  });
}