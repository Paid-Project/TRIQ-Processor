import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddMembersViewModel extends BaseViewModel {
  final _employeeService = locator<EmployeeService>();
  final _navigationService = locator<NavigationService>();
  final TextEditingController searchController = TextEditingController();
  final _chatService = locator<ChatService>();
  final List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> get filteredEmployees => _filteredEmployees;

  String? _loadError;
  String? get loadError => _loadError;

  Future<void> init() async {
    await fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setBusy(true);
    _loadError = null;

    try {
      final Either<Failure, List<Employee>> response =
          await _employeeService.getAllEmployees();

      response.fold(
        (failure) {
          _allEmployees.clear();
          _filteredEmployees = [];
          _loadError = failure.message;
        },
        (employees) {
          _allEmployees
            ..clear()
            ..addAll(employees);
          _filteredEmployees = List<Employee>.from(_allEmployees);
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching add members list: $e');
      _allEmployees.clear();
      _filteredEmployees = [];
      _loadError = 'Failed to load employees';
    }

    setBusy(false);
    notifyListeners();
  }
  Future<void> addMember(String groupId) async {
    try {
      final response = await _chatService.addMember(groupId: groupId);

      response.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message);
        },
            (_) async {
          Fluttertoast.showToast(msg: 'Successfully left group');
        },
      );
    } catch (e) {
      AppLogger.error('Error leaving group: $e');
      _navigationService.back();
      _navigationService.back();
    }
  }
  void searchEmployees(String query) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) {
      _filteredEmployees = List<Employee>.from(_allEmployees);
    } else {
      _filteredEmployees =
          _allEmployees.where((employee) {
            final name = (employee.name ?? '').toLowerCase();
            final email = (employee.email ?? '').toLowerCase();
            final phone = (employee.phone ?? '').toLowerCase();
            final designation =
                (employee.designation?.name ?? '').toLowerCase();
            final department = (employee.department?.name ?? '').toLowerCase();

            return name.contains(normalized) ||
                email.contains(normalized) ||
                phone.contains(normalized) ||
                designation.contains(normalized) ||
                department.contains(normalized);
          }).toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
