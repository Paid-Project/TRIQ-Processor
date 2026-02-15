import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dio/dio.dart';

// import '../../../api_endpoints.dart';
import '../../../core/locator.dart';
import '../../../core/models/employee.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/failures.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/api.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';

class CreateGroupChatViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _apiService = locator<ApiService>();

  // Controllers
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Employee lists
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> _selectedEmployees = [];

  // Getters
  List<Employee> get allEmployees => _allEmployees;
  List<Employee> get filteredEmployees => _filteredEmployees;
  List<Employee> get selectedEmployees => _selectedEmployees;

  // Initialize the view model
  void init(List<Employee>? preselectedEmployees) async {
    setBusy(true);
    await fetchEmployees();

    if (preselectedEmployees != null && preselectedEmployees.isNotEmpty) {
      _selectedEmployees = List.from(preselectedEmployees);
      notifyListeners();
    }

    setBusy(false);
  }

  // Fetch all employees from the organization
  Future<void> fetchEmployees() async {
    // try {
    //   final response = await _apiService.get(url: 'employee/get-all');

    // if (response.data['success'] == true) {
    //   final employees = (response.data['data'] as List).map((employeeData) {
    //     return Employee(
    //       id: employeeData['_id'],
    //       name: employeeData['fullName'],
    //       email: employeeData['email'],
    //       role: employeeData['role'],
    //     );
    //   }).toList();

    //   _allEmployees = employees;
    //   _filteredEmployees = List.from(_allEmployees);
    //   notifyListeners();
    // } else {
    //   Fluttertoast.showToast(msg: "Failed to fetch employees");
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error("DioError fetching employees: ${e.message}");
    //     AppLogger.error("Response: ${e.response?.data}");
    //     Fluttertoast.showToast(msg: e.response?.data['message'] ?? "Error fetching employees");
    //   } else {
    //     AppLogger.error("Error fetching employees: $e");
    //     Fluttertoast.showToast(msg: "Error fetching employees");
    //   }
    // }
    _allEmployees = [];
    _filteredEmployees = [];
    notifyListeners();
  }

  // Search employees based on query
  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
    } else {
      _filteredEmployees =
          _allEmployees.where((employee) {
            final nameMatch =
                employee.name?.toLowerCase().contains(query.toLowerCase()) ??
                false;
            final roleMatch = employee.designation?.name?.toLowerCase().contains(query.toLowerCase()) ??
                false;
            final emailMatch =
                employee.email?.toLowerCase().contains(query.toLowerCase()) ??
                false;
            return nameMatch || roleMatch || emailMatch;
          }).toList();
    }
    notifyListeners();
  }

  // Toggle employee selection
  void toggleEmployeeSelection(Employee employee) {
    if (isEmployeeSelected(employee)) {
      _selectedEmployees.removeWhere(
        (selectedEmployee) => selectedEmployee.id == employee.id,
      );
    } else {
      _selectedEmployees.add(employee);
    }
    notifyListeners();
  }

  // Check if employee is already selected
  bool isEmployeeSelected(Employee employee) {
    return _selectedEmployees.any(
      (selectedEmployee) => selectedEmployee.id == employee.id,
    );
  }

  // Create group chat
  Future<void> createGroupChat() async {
    if (_selectedEmployees.isEmpty) {
      Fluttertoast.showToast(msg: "Please select at least one employee");
      return;
    }

    if (groupNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter a group name");
      return;
    }

    try {
      setBusy(true);

      final employeeIds =
          _selectedEmployees.map((employee) => employee.id!).toList();
      final groupName = groupNameController.text.trim();

      AppLogger.info(
        "Creating group chat: $groupName with employees: $employeeIds",
      );

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.post(
                url: 'chat/org-room-create',
                data: {'groupName': groupName, 'employeeIds': employeeIds},
              );

              AppLogger.info("API Response: ${apiResponse.data}");

              if (apiResponse.data['success'] == true) {
                return Right<Failure, String>(
                  apiResponse.data['data']['chatRoomId'],
                );
              } else {
                return Left<Failure, String>(
                  Failure(apiResponse.data['message']),
                );
              }
            } catch (e) {
              if (e is DioException) {
                AppLogger.error("DioError creating chat: ${e.message}");
                AppLogger.error("Response: ${e.response?.data}");
                return Left<Failure, String>(
                  Failure(
                    e.response?.data?['message'] ?? 'Something went wrong',
                  ),
                );
              }
              AppLogger.error("Error creating chat: $e");
              return Left<Failure, String>(
                Failure('An unexpected error occurred'),
              );
            }
          },
        ),
      );

      if (response?.data != null) {
        final result = response?.data as EitherResult<String>;
        result.fold(
          (failure) {
            AppLogger.error("Failed to create chat: $failure");
            Fluttertoast.showToast(msg: failure.message);
          },
          (chatRoomId) {
            AppLogger.info("Chat created successfully with ID: $chatRoomId");
            Fluttertoast.showToast(msg: "Group chat created successfully!");
            _navigationService.back(result: chatRoomId);
          },
        );
      }
    } catch (e) {
      AppLogger.error("Exception in createGroupChat: $e");
      Fluttertoast.showToast(msg: "Failed to create group chat");
    } finally {
      setBusy(false);
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];

  @override
  void dispose() {
    groupNameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
