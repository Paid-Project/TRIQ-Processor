import 'package:dartz/dartz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/services/chat.service.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class GroupInfoViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();
  final _employeeService = locator<EmployeeService>();

  bool _isDropdownLoading = false;
  bool get isDropdownLoading => _isDropdownLoading;

  String? _employeeLoadError;
  String? get employeeLoadError => _employeeLoadError;

  final List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  Future<void> init() async {
    await fetchDropdownData();
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final response = await _chatService.leaveGroup(groupId: groupId);

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

  Future<void> fetchDropdownData() async {
    _isDropdownLoading = true;
    _employeeLoadError = null;
    notifyListeners();

    try {
      final Either<Failure, List<Employee>> response =
          await _employeeService.getAllEmployees();

      response.fold(
        (exception) {
          AppLogger.warning(exception.message);
          _employees.clear();
          _employeeLoadError = exception.message;
        },
        (allEmployees) {
          _employees
            ..clear()
            ..addAll(allEmployees);
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching employee data: $e');
      _employees.clear();
      _employeeLoadError = 'Failed to load employees';
    }

    _isDropdownLoading = false;
    notifyListeners();
  }
}
