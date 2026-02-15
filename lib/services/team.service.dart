

import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';

import '../core/models/api_response.dart';
import '../core/models/department.model.dart';
import '../core/models/hierarchy_node.model.dart';
import 'api.service.dart';

class TeamService {
  final _api = locator<ApiService>();
  Future<ApiResponse<List<DepartmentModel>>> getAllDepartments() async {
    try {
      final response = await _api.get(
        url:'${ApiEndpoints.getAllDepartment}',
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        List<dynamic> departmentData = response.data['data'];
        List<DepartmentModel> departments = departmentData
            .map((json) => DepartmentModel.fromJson(json))
            .toList();
        return ApiResponse<List<DepartmentModel>>(
          data: departments,
          message: response.data['message']
          , success: true, statusCode: 200,
        );
      } else {
        return ApiResponse<List<DepartmentModel>>(
         success: false, statusCode: 500,
          message: response.data['message'] ?? 'Failed to get departments',
        );
      }
    } catch (e) {
      return ApiResponse<List<DepartmentModel>>(
        success: false, statusCode: 500,
        message: 'An error occurred: $e',
      );
    }
  }

  /// Adds a new department
  Future<ApiResponse> addNewDepartment(String name) async {
    try {
      final response = await _api.post(
        url:'${ApiEndpoints.addDepartment}',
        data: {'name': name},
      );

      return ApiResponse<DepartmentModel>(
        data:DepartmentModel.fromJson(response.data['data']) ,
        message: response.data['message'], success: true, statusCode: 200,
      );

    } catch (e) {
      return ApiResponse(
        success: false, statusCode: 500,
        message: 'An error occurred: $e',
      );
    }
  }
  Future<ApiResponse<List<HierarchyNode>>> getEmployeeHierarchy(String departmentId) async {
    try {
      final response = await _api.get(
        url: '${ApiEndpoints.getEmployeeHierarchy}/$departmentId',
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        List<dynamic> hierarchyData = response.data['data'];
        List<HierarchyNode> hierarchy = hierarchyData
            .map((json) => HierarchyNode.fromJson(json))
            .toList();

        return ApiResponse<List<HierarchyNode>>(
          data: hierarchy,
          message: response.data['message'],
          success: true,
          statusCode: 200,
        );
      } else {
        return ApiResponse<List<HierarchyNode>>(
          success: false,
          statusCode: response.statusCode ?? 500,
          message: response.data['message'] ?? 'Failed to get hierarchy',
        );
      }
    } catch (e) {
      return ApiResponse<List<HierarchyNode>>(
        success: false,
        statusCode: 500,
        message: 'An error occurred: $e',
      );
    }
  }
}