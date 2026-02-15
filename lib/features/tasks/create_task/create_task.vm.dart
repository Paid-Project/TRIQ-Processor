import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ADD THIS IMPORT
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/employee.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/task.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/machine.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/failures.dart';
import '../../../widgets/common/custom_date_picker.dart';

class CreateTaskViewModel extends ReactiveViewModel {
  final _taskService = locator<TaskService>();
  final _navigationService = locator<NavigationService>();
  // REMOVE THIS: final _snackbarService = locator<SnackbarService>();
  final _filePickerService = locator<FilePickerService>();
  final _employeeService = locator<EmployeeService>();
  final _machineService = locator<MachineService>();

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final webUrlController = TextEditingController();

  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endDateController = TextEditingController();
  final endTimeController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  final List<String> priorities = ['High', 'Medium', 'Low'];

  String? _selectedPriority;
  Employee? _selectedEmployee;

  List<File> _pickedFiles = [];
  List<File> get pickedFiles => _pickedFiles;

  bool _isDropdownLoading = false;
  bool get isDropdownLoading => _isDropdownLoading;

  // Helper method for showing toast
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void onModelReady() {
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    _isDropdownLoading = true;
    notifyListeners();
    try {
      // final employeeData = await _employeeService.getAllEmployees() ?? [];
      // _employees = (employeeData as List<dynamic>)
      //     .map((json) => Employee.fromJson(json))
      //     .toList();
      Either<Failure, List<Employee>> response = await _employeeService.getAllEmployees();
      response.fold(
            (exception) {
              AppLogger.warning(exception.message);
              _employees = [];
        },
            (allEmployees) {
              _employees.clear();
              _employees.addAll(allEmployees);

        },
      );
    } catch (e) {
      print('Error fetching dropdown data: $e');
      _showToast('Failed to load employee data', isError: true); // UPDATED
    }
    _isDropdownLoading = false;
    notifyListeners();
  }

  void onPrioritySelected(String? value) {
    _selectedPriority = value;
  }

  void onEmployeeSelected(Employee? value) {
    _selectedEmployee = value;
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? date = await CustomDatePicker.show(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;
    _startDate = date;
    startDateController.text = DateFormat('yyyy/MM/dd').format(date);
    notifyListeners();
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: CustomDatePicker.themeBuilder(context),
    );
    if (time == null) return;
    _startTime = time;
    startTimeController.text = time.format(context);
    notifyListeners();
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? date = await CustomDatePicker.show(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;
    _endDate = date;
    endDateController.text = DateFormat('yyyy/MM/dd').format(date);
    notifyListeners();
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: CustomDatePicker.themeBuilder(context),
    );
    if (time == null) return;
    _endTime = time;
    endTimeController.text = time.format(context);
    notifyListeners();
  }

  Future<void> pickMedia() async {
    final result = await _filePickerService.pickImageFromGallery();
    List<File> files = [];
    result.fold(
          (failure) {},
          (response) {
        files = [response];
      },
    );
    if (files.isNotEmpty) {
      _pickedFiles.addAll(files);
      notifyListeners();
    }
  }

  void removeFile(int index) {
    _pickedFiles.removeAt(index);
    notifyListeners();
  }

  Future<void> createTask() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      _showToast('Please select start and end time', isError: true); // UPDATED
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showToast('End date cannot be before start date', isError: true); // UPDATED
      return;
    }

    setBusy(true);

    final fields = <String, String>{
      'title': titleController.text,
      'description': descriptionController.text,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'priority': _selectedPriority!,
      'assignTo': _selectedEmployee?.id ?? '',
    };

    if (webUrlController.text.isNotEmpty) {
      fields['webUrl'] = webUrlController.text;
    }

    final success = await _taskService.createTask(
      fields: fields,
      files: _pickedFiles,
    );

    setBusy(false);

    if (success) {
      _showToast('Task Created Successfully'); // UPDATED
      _navigationService.back(result: true);
    } else {
      _showToast('Failed to create task', isError: true); // UPDATED
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    webUrlController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}