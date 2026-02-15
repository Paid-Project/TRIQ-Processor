import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

/// Organization Request Service
/// Handles organization request accept/reject operations
class OrganizationRequestService {
  final apiService = locator<ApiService>();

  /// Accept organization request
  /// When a manufacturer adds a processor, processor can accept the request
  ResultFuture<OrganizationRequestResponse> acceptOrganizationRequest({
    required String notificationId,
    required String organizationId,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.acceptOrganizationRequest,
        data: {
          'notificationId': notificationId,
          'organizationId': organizationId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Right(OrganizationRequestResponse.fromJson(response.data));
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to accept request'),
        );
      }
    } catch (e) {
      AppLogger.error("Error accepting organization request: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Network error'),
        );
      }
      return Left(
        Failure('Failed to accept request: ${e.toString()}'),
      );
    }
  }

  /// Reject organization request
  /// When a manufacturer adds a processor, processor can reject the request
  ResultFuture<OrganizationRequestResponse> rejectOrganizationRequest({
    required String notificationId,
    required String organizationId,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.rejectOrganizationRequest,
        data: {
          'notificationId': notificationId,
          'organizationId': organizationId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Right(OrganizationRequestResponse.fromJson(response.data));
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to reject request'),
        );
      }
    } catch (e) {
      AppLogger.error("Error rejecting organization request: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Network error'),
        );
      }
      return Left(
        Failure('Failed to reject request: ${e.toString()}'),
      );
    }
  }

  /// DUMMY METHOD - Accept organization request (for testing)
  /// Returns dummy success response
  Future<OrganizationRequestResponse> dummyAcceptOrganizationRequest({
    required String notificationId,
    required String organizationId,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    return OrganizationRequestResponse(
      success: true,
      message: 'Organization request accepted successfully',
      organization: OrganizationData(
        id: organizationId,
        fullName: 'ABC Manufacturing Ltd.',
        email: 'contact@abcmanufacturing.com',
        phone: '+91-9876543210',
      ),
      machines: [
        MachineData(
          id: 'machine_1',
          machineName: 'CNC Machine',
          modelNumber: 'CNC-2024-001',
          serialNumber: 'SN123456',
        ),
        MachineData(
          id: 'machine_2',
          machineName: 'Lathe Machine',
          modelNumber: 'LTH-2024-002',
          serialNumber: 'SN789012',
        ),
      ],
    );
  }

  /// DUMMY METHOD - Reject organization request (for testing)
  /// Returns dummy success response
  Future<OrganizationRequestResponse> dummyRejectOrganizationRequest({
    required String notificationId,
    required String organizationId,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    return OrganizationRequestResponse(
      success: true,
      message: 'Organization request rejected successfully',
      organization: null,
      machines: null,
    );
  }
}

/// Organization Request Response Model
class OrganizationRequestResponse {
  final bool success;
  final String message;
  final OrganizationData? organization;
  final List<MachineData>? machines;

  OrganizationRequestResponse({
    required this.success,
    required this.message,
    this.organization,
    this.machines,
  });

  factory OrganizationRequestResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      organization: json['data']?['organization'] != null
          ? OrganizationData.fromJson(json['data']['organization'])
          : null,
      machines: json['data']?['machines'] != null
          ? (json['data']['machines'] as List)
              .map((m) => MachineData.fromJson(m))
              .toList()
          : null,
    );
  }
}

/// Organization Data Model
class OrganizationData {
  final String id;
  final String fullName;
  final String email;
  final String phone;

  OrganizationData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory OrganizationData.fromJson(Map<String, dynamic> json) {
    return OrganizationData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

/// Machine Data Model
class MachineData {
  final String id;
  final String machineName;
  final String modelNumber;
  final String serialNumber;

  MachineData({
    required this.id,
    required this.machineName,
    required this.modelNumber,
    required this.serialNumber,
  });

  factory MachineData.fromJson(Map<String, dynamic> json) {
    return MachineData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      machineName: json['machineName']?.toString() ?? '',
      modelNumber: json['modelNumber']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
    );
  }
}
