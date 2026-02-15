import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:manager/core/models/department.model.dart';
import 'package:manager/core/models/api_response.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/hierarchy_node.model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/employee/search_employee/search_employee_view.dart';
import 'package:manager/features/profile/scan_code/scan_code.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/employee.service.dart';
import 'package:manager/services/team.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../employee/add_employee/add_employee.view.dart';

import '../../profile/scan_code/scan_code.vm.dart';
import '../department_hierarchy.view.dart';
class TeamListVM extends BaseViewModel {
  final _teamService = locator<TeamService>();
  final _employeeService = locator<EmployeeService>();
  final _navigationService = locator<NavigationService>();
  List<HierarchyNode> _hierarchy = [];
  List<HierarchyNode> get hierarchy => _hierarchy;

  String? _selectedDepartmentId;
  String? get selectedDepartmentId => _selectedDepartmentId;


  final TextEditingController departmentNameController = TextEditingController();

  List<DepartmentModel> _departments = [];
  List<DepartmentModel> get departments => _departments;

  /// Called when the ViewModel is ready
  Future<void> onModelReady() async {
    await fetchAllDepartments();
  }

  /// Fetches the list of departments from the API
  Future<void> fetchAllDepartments() async {
    setBusy(true); // Main page loader ON
    try {
      final response = await _teamService.getAllDepartments();
      if (response.success  && response.data != null) {
        _departments = response.data!;
      } else {

      }
    } catch (e) {

    }
    setBusy(false); // Main page loader OFF
  }

  /// Creates a new department
  Future<void> createNewDepartment() async {
    if (departmentNameController.text.trim().isEmpty) {
      AppLogger.error( 'Department name cannot be empty.');
      return;
    }

    // Use a specific busy key for the dialog loader
    setBusyForObject('dialog', true);

    try {
      final response = await _teamService.addNewDepartment(departmentNameController.text.trim());

      if (response.success) {
        Get.back();
        departmentNameController.clear();
        await fetchAllDepartments(); // Refresh the list
        Fluttertoast.showToast(msg:  response.message ?? 'Department created successfully.',backgroundColor: AppColors.success);
      } else {
        AppLogger.error(response.message ?? 'Failed to create department.');
      }
    } catch (e) {
      AppLogger.error( 'An unexpected error occurred: $e');
    }

    // Turn off dialog loader
    setBusyForObject('dialog', false);
  }

  void onScanFromCamera(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ScanCodeView(
      attributes: ScanCodeViewAttributes(
        isFromProfile: false,
        screen: ScanScreenType.employee,
      ),
    )));

    // If customer was edited from scan code, refresh the customers list
    if (result == true) {
     // await _loadCustomers();
    }
  }
  void onSearchByPhone(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchEmploeeView()),
    );

    // If customer was edited from search organization, refresh the customers list
    if (result == true) {
      // await _loadCustomers();
    }
  }

  void onAddNewEmployee(BuildContext context) async {
    final result =     await _navigationService.navigateTo(
      Routes.addEmployee,
      arguments: AddEmployeeViewAttributes(
        id: null,
        hasReadOnly: false,
      ),
    );

    if (result == true) {
      _employeeService.getAllEmployees();
    }
    // If customer was edited from search organization, refresh the customers list
    if (result == true) {
      // await _loadCustomers();
    }
  }
  Future<bool> fetchDepartmentHierarchy(String departmentId) async {
    _selectedDepartmentId = departmentId;
    setBusy(true);

    try {

      final response = await _teamService.getEmployeeHierarchy(departmentId);

      if (response.success && response.data != null) {
        _hierarchy = response.data!;
        setBusy(false);
        notifyListeners();
        return true;
      }
      else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to load hierarchy',
          backgroundColor: AppColors.error,
        );
        _hierarchy = [];
        setBusy(false);
        notifyListeners();
        return false;
      }

    } catch (e) {
      AppLogger.error('Error fetching hierarchy: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred while loading hierarchy',
        backgroundColor: AppColors.error,
      );
      _hierarchy = [];
      setBusy(false);
      notifyListeners();
      return false;
    }
  }
  /// Navigate to hierarchy screen
  void navigateToHierarchy(BuildContext context, String departmentName) {
    if (_hierarchy.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HierarchyScreen(
            departmentName: departmentName,
            viewModel: this,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'No hierarchy data available',
        backgroundColor: AppColors.error,
      );
    }
  }
  @override
  void dispose() {
    departmentNameController.dispose();
    super.dispose();
  }
}