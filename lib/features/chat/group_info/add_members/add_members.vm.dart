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
  final _navigationService = locator<NavigationService>();
  final _employeeService = locator<EmployeeService>();
  final TextEditingController searchController = TextEditingController();
  final _chatService = locator<ChatService>();
  final List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> get filteredEmployees => _filteredEmployees;

  String? _loadError;
  String? get loadError => _loadError;
  final Set<String> _selectedMemberIds = <String>{};
  List<String> get selectedMemberIds =>
      _selectedMemberIds.toList(growable: false);

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String getEmployeeLabel(Employee employee) {
    final candidates = [
      employee.fullName,
      employee.name,
      employee.email,
      employee.phone,
      employee.employeeId,
    ];

    for (final candidate in candidates) {
      final value = candidate?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return 'Unknown member';
  }

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

  String? getMemberId(Employee employee) {
    if ((employee.id ?? '').isNotEmpty) return employee.id;
    if ((employee.user ?? '').isNotEmpty) return employee.user;
    if ((employee.linkedUser ?? '').isNotEmpty) return employee.linkedUser;

    return null;
  }

  bool isSelected(Employee employee) {
    final memberId = getMemberId(employee);
    return memberId != null && _selectedMemberIds.contains(memberId);
  }

  void toggleMemberSelection(Employee employee) {
    final memberId = getMemberId(employee);
    if (memberId == null) {
      Fluttertoast.showToast(msg: 'User ID not available for this member');
      return;
    }

    if (_selectedMemberIds.contains(memberId)) {
      _selectedMemberIds.remove(memberId);
    } else {
      _selectedMemberIds.add(memberId);
    }

    notifyListeners();
  }

  Future<void> addMember(String groupId, List<String> memberIds) async {
    if (groupId.trim().isEmpty || memberIds.isEmpty || _isSubmitting) {
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final response = await _chatService.addMember(
        groupId: groupId,
        memberIds: memberIds,
      );

      response.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message);
        },
            (_) async {
          _selectedMemberIds.clear();
          _navigationService.back();
          // Fluttertoast.showToast(msg: 'Members added successfully');
        },
      );
    } catch (e) {
      AppLogger.error('Error adding members: $e');
      Fluttertoast.showToast(msg: 'Failed to add members');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void searchEmployees(String query) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) {
      _filteredEmployees = List<Employee>.from(_allEmployees);
    } else {
      _filteredEmployees = _allEmployees.where((employee) {
        final name = getEmployeeLabel(employee).toLowerCase();
        final fullName = (employee.fullName ?? '').toLowerCase();
        final email = (employee.email ?? '').toLowerCase();
        final phone = (employee.phone ?? '').toLowerCase();
        final employeeId = (employee.employeeId ?? '').toLowerCase();
        final memberId = (getMemberId(employee) ?? '').toLowerCase();
        final designation = (employee.designation?.name ?? '').toLowerCase();
        final department = (employee.department?.name ?? '').toLowerCase();

        return name.contains(normalized) ||
            fullName.contains(normalized) ||
            email.contains(normalized) ||
            phone.contains(normalized) ||
            employeeId.contains(normalized) ||
            memberId.contains(normalized) ||
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
