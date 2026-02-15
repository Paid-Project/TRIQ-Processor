import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/employee/add_employee/add_employee.view.dart';
import 'package:manager/features/employee/detail_employee/employee_details.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/storage/storage.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../../routes/routes.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import '../../search/search_view.dart';
import 'employees_list.view.dart';

class EmployeesListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final employeeService = locator<EmployeeService>();

  // Reactive values
  final ReactiveValue<List<Employee>> _employeesList =
      ReactiveValue<List<Employee>>([]);
  final ReactiveValue<List<Employee>> _filteredEmployees =
      ReactiveValue<List<Employee>>([]);
  final ReactiveValue<String> _searchQuery = ReactiveValue<String>('');
  final ReactiveValue<String> _selectedRole = ReactiveValue<String>('all');
  final ReactiveValue<String> _selectedEmployeeType = ReactiveValue<String>(
    'all',
  );

  // Getters
  List<Employee> get employeesList => _employeesList.value;
  List<Employee> get filteredEmployees => _filteredEmployees.value;
  String get searchQuery => _searchQuery.value;
  String get selectedRole => _selectedRole.value;
  String get selectedEmployeeType => _selectedEmployeeType.value;

  // Setters
  set searchQuery(String value) {
    _searchQuery.value = value;
    _applyFilters();
    notifyListeners();
  }

  // Filter options
  List<String> rolesFilter = getUser().organizationType == OrganizationType.manufacturer ?
  [
    'Head of Global Service', 'Country Service Manager', 'Local Service Engineers', 'Installation Engineers',
  ] :
  ['Plant Head', 'Line Incharge', 'Maintenance Head', 'Maintenance Engineers', 'Machine Operators', 'Labour'];


  void init( EmployeeListViewAttributes attributes ) {
    AppLogger.info("someMoreRole ${attributes.role}");
    getEmployees(
      role: attributes.role,
      employeeType: _selectedEmployeeType.value,
    );
  }

  Future<void> getEmployees({
    required String? role,
    required String? employeeType,
  }) async {
    setBusy(true);

    final response = await employeeService.getEmployees(
      role: role == 'all' ? null : role,
      employeeType: employeeType == 'all' ? null : employeeType,
    );

    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
        _employeesList.value = [];
        _filteredEmployees.value = [];
      },
      (employees) {
        _employeesList.value = employees;
        _applyFilters();
      },
    );

    setBusy(false);
  }

  void _applyFilters() {
    if (_searchQuery.value.isEmpty) {
      _filteredEmployees.value = [..._employeesList.value];
    } else {
      final query = _searchQuery.value.toLowerCase();
      _filteredEmployees.value =
          _employeesList.value.where((employee) {
            final nameMatch =
                employee.name?.toLowerCase().contains(query) ?? false;
            final emailMatch =
                employee.email?.toLowerCase().contains(query) ?? false;
            final idMatch = employee.id?.toLowerCase().contains(query) ?? false;

            return nameMatch || emailMatch || idMatch;
          }).toList();
    }
    notifyListeners();
  }

  void updateSelectedRole(String role) {
    // Only update if the role actually changed
    if (_selectedRole.value != role) {
      _selectedRole.value = role;
      getEmployees(
        role: _selectedRole.value,
        employeeType: _selectedEmployeeType.value,
      );
    }
  }

  void updateSelectedEmployeeType(String employeeType) {
    if (_selectedEmployeeType.value != employeeType) {
      _selectedEmployeeType.value = employeeType;
      getEmployees(
        role: _selectedRole.value,
        employeeType: _selectedEmployeeType.value,
      );
    }
  }

  Future<void> refreshEmployees() async {
    return getEmployees(
      role: _selectedRole.value,
      employeeType: _selectedEmployeeType.value,
    );
  }

  void onEmployeeTap(Employee employee) {
    _navigationService.navigateTo(Routes.employee,parameters: EmployeeDetailsViewAttributes(employeeId: employee.id!).toJson());
    //  _dialogService
    //     .showDialog(
    //       title: 'Employee Details',
    //       description: 'View or manage ${employee.name}\'s details?',
    //       buttonTitle: 'View Details',
    //       cancelTitle: 'Cancel',
    //     )
    //     .then((response) {
    //       if (response != null && response.confirmed) {
    //         // Navigate to employee details page
    //         // This would need to be implemented
    //       }
    //     });
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

  void navigateToAddEmployee(AddEmployeeViewAttributes attributes) async {
    await _navigationService.navigateTo(
      Routes.addEmployee,
      arguments: attributes,
    );
    // Refresh the employee list after returning
    getEmployees(
      role: _selectedRole.value,
      employeeType: _selectedEmployeeType.value,
    );
  }
}
