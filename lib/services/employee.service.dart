import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/designation.model.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';

import '../core/models/api_response.dart';
import '../core/utils/failures.dart';

class EmployeeService {
  final apiService = locator<ApiService>();

  ResultFuture<List<Employee>> getEmployees({
    required String? role,
    required String? employeeType,
  }) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.getEmployees,
        queryParameters: {'role': role, 'type': employeeType},
      );

      if (response.data['success'] == true) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Employee.fromJson(e))
              .toList(),
        );
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to get employees'));
  }

  Future<ApiResponse<List<DesignationModel>>> getCustomDesignation() async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.getCustomDesignation}',
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        List<dynamic> departmentData = response.data['data'];
        List<DesignationModel> departments =
            departmentData
                .map((json) => DesignationModel.fromJson(json))
                .toList();
        return ApiResponse<List<DesignationModel>>(
          data: departments,
          message: response.data['message'],
          success: true,
          statusCode: 200,
        );
      } else {
        return ApiResponse<List<DesignationModel>>(
          success: false,
          statusCode: 500,
          message: response.data['message'] ?? 'Failed to get departments',
        );
      }
    } catch (e) {
      return ApiResponse<List<DesignationModel>>(
        success: false,
        statusCode: 500,
        message: 'An error occurred: $e',
      );
    }
  }

  /// Adds a new department
  Future<ApiResponse> addCustomDesignation(String name) async {
    try {
      final response = await apiService.post(
        url: '${ApiEndpoints.addCustomDesignation}',
        data: {'name': name.capitalizeWords},
      );

      return ApiResponse<DesignationModel>(
        data: DesignationModel.fromJson(response.data['data']),
        message: response.data['message'],
        success: true,
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'An error occurred: $e',
      );
    }
  }

  ResultFuture<List<Employee>> getAllEmployees() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.getAllEmployee);

      if (response.data['status'] == 1) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Employee.fromJson(e))
              .toList(),
        );
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to get all employees'));
  }

  ResultFuture<List<Employee>> searchEmployees(String query) async {
    try {
      AppLogger.info("Searching employee with query: $query");

      final response = await apiService.get(
        url: ApiEndpoints.searchEmployee,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List<dynamic> employeeData = data['data'];
          final employee =
              employeeData.map((json) => Employee.fromJson(json)).toList();
          AppLogger.info("Found ${employee.length} employee for query: $query");
          return Right(employee);
        } else {
          AppLogger.warning("No employee found for query: $query");
          return Right([]);
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to search employee';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while searching employee: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while searching employee: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  ResultFuture<Employee> getEmployeeById(String id) async {
    try {
      AppLogger.info("📡 API Call: getEmployeeById - ID: $id");

      final response = await apiService.get(
        url: '${ApiEndpoints.getEmployeeById}/$id',
      );

      // ✅ FIX: Check 'status' instead of 'success'
      if (response.statusCode == 200 && response.data['status'] == 1) {
        return Right(Employee.fromJson(response.data['data']));
      } else {
        AppLogger.error("❌ API Error: ${response.data['message']}");
        return Left(
          Failure(response.data['message'] ?? 'Failed to get employee'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(
          "❌ DioException: ${e.response?.data?['message'] ?? e.message}",
        );
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      AppLogger.error("❌ Unknown Error: $e");
      return Left(Failure('Failed to get employee: $e'));
    }
  }

  Future<bool> createEmployee({
    bool isUpdate = false,
    required String name,
    String? id,
    required String phone,
    required String email,
    required String employeeId,
    required String departmentId,
    required String designationId,
    required String joiningDate,

    String? bloodGroup,
    String? country,
    String? area,
    String? reportTo,
    String? machineId,
    String? employeeType,
    String? shiftTiming,
    required PersonalAddress personalAddress,
    required EmergencyContact emergencyContact,
    required Permissions permissions,
    File? profilePhoto,
  }) async {
    try {
      final Map<String, String> fields = {
        'name': name,
        'phone': phone,
        'email': email,
        'employeeId': employeeId,
        'department': departmentId,
        'designation': designationId,
        'joiningDate': joiningDate,
        'personalAddress': json.encode(personalAddress.toJson()),
        'emergencyContact': json.encode(emergencyContact.toJson()),
        'permissions': json.encode(permissions.toJson()),
        'machine': machineId ?? '',
      };

      if (bloodGroup != null) fields['bloodGroup'] = bloodGroup;
      if (country != null) fields['country'] = country;
      if (area != null) fields['area'] = area;
      if (reportTo != null) fields['reportTo'] = reportTo;
      if (employeeType != null) fields['employeeType'] = employeeType;
      if (shiftTiming != null) fields['shiftTiming'] = shiftTiming;

      final List<File> files = [];
      if (profilePhoto != null) {
        files.add(profilePhoto);
      }

      late final response;

      if (!isUpdate) {
        response = await apiService.postMultipart(
          ApiEndpoints.addEmployee,
          data: fields,
          files: files,
          fileField: 'profilePhoto',
        );
      } else {
        response = await apiService.putMultipart(
          "${ApiEndpoints.updateEmployeeById}/$id",
          data: fields,
          files: files,
          fileField: 'profilePhoto',
        );
      }

      if (response != null &&
          (response.data['success'] == true || response.data['status'] == 1)) {
        return true; // Success
      } else {
        print('Error creating employee: ${response?.data['message']}');
        return false;
      }
    } catch (e) {
      print('Exception in createEmployee: $e');
      return false;
    }
  }

  ResultFuture<List<Employee>> getEligibleReportToList({
    required String designationId,
    required String departmentId,
  }) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.getEligibleReportToList,
        queryParameters: {
          'designationId': designationId,
          'departmentId': departmentId,
        },
      );

      if (response.data['status'] == 1) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Employee.fromJson(e))
              .toList(),
        );
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to get report to list'));
  }

  ResultFuture<bool> deleteEmployee(String employeeId) async {
    try {
      final response = await apiService.delete(
        url: '${ApiEndpoints.employee}/$employeeId',
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to delete employee'));
  }

  ResultFuture<bool> updateEmployeePermissions(
    String employeeId,
    Map<String, dynamic> permissions,
  ) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.employee}/$employeeId/permissions',
        data: {'permissions': permissions},
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to update employee permissions'));
  }
}
