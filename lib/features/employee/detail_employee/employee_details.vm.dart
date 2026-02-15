import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/employee.dart';
import '../../../core/utils/failures.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/employee.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../add_employee/add_employee.view.dart';
import 'employee_details.dart';

class EmployeeDetailsViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _employeeService = locator<EmployeeService>();

  Employee? _employee;
  Employee? get employee => _employee;

  void init(EmployeeDetailsViewAttributes attributes) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchEmployeeDetails(attributes.employeeId);
    });
  }

  Future<void> _fetchEmployeeDetails(String employeeId) async {
    setBusy(true);
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () => _employeeService.getEmployeeById(employeeId),
      ),
    );

    if (response?.data != null) {
      ((response?.data) as EitherResult<Employee>).fold(
            (exception) {
          Fluttertoast.showToast(msg: exception.message.toString());
        },
            (employee) {
          _employee = employee;
          notifyListeners();
        },
      );
    }
    setBusy(false);
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void onEditEmployee(BuildContext context) {
    if (_employee != null) {
      _navigationService.navigateToView(
        AddEmployeeView(
          attributes: AddEmployeeViewAttributes(
            id: _employee!.id,
            hasPasswordField: false,
            hasReadOnly: true,
          ),
        ),
      );
    }
  }

  void handleMenuAction(String action, BuildContext context) async {
    if (action == 'delete' && _employee != null) {
      final confirmed = await _showDeleteConfirmation(context);
      if (confirmed == true) {
        await _deleteEmployee();
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: Text('Are you sure you want to delete this employee? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmployee() async {
    if (_employee == null) return;

    setBusy(true);

    try {
      final result = await _employeeService.deleteEmployee(_employee!.id!);

      result.fold(
            (failure) {
          Fluttertoast.showToast(msg: failure.message.toString());
        },
            (success) {
          Fluttertoast.showToast(msg: 'Employee deleted successfully');
          _navigationService.back();
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting employee: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }
}