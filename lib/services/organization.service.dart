import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/models/hive/user/user.dart';
import '../core/models/organization.dart';
// import '../core/storage/storage.dart';
import '../core/utils/failures.dart';

class OrganizationService {
  final apiService = locator<ApiService>();

  ResultFuture<String> addManufacturer({required String id}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.addManufacturer,
        data: {'manufacturerId': id},
      );

      if (response.data['success'] == true) {
        return Right(response.data['message']);
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
    return Left(Failure('Failed to add partner'));
  }

  ResultFuture<String> addProcessor({
    required String id,
    required List<Map<String, dynamic>> assignedMachines,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.addPartner,
        data: {'processorId': id, 'machinesData': assignedMachines},
      );

      if (response.data['success'] == true) {
        return Right(response.data['message']);
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
    return Left(Failure('Failed to add partner'));
  }

  ResultFuture<String> addMachinesToProcessor({
    required String id,
    required List<Map<String, dynamic>> assignedMachines,
  }) async {
    try {
      final response = await apiService.put(
        url: ApiEndpoints.assignMachine,
        data: {'processorId': id, 'machinesData': assignedMachines},
      );

      if (response.data['success'] == true) {
        return Right(response.data['message']);
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
    return Left(Failure('Failed to add partner'));
  }

  ResultFuture<String> addNewProcessor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String countryCode,
    required List<Map<String, dynamic>> assignedMachines,
    String? contactPerson,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.addNewPartner,
        data: {
          "name": fullName,
          "email": email,
          'phone': phone,
          "password": password,
          "countryCode": countryCode,
          'machinesData': assignedMachines,
          'contactPerson': contactPerson,
        },
      );

      if (response.data['success'] == true) {
        return Right(response.data['message']);
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
    return Left(Failure('Failed to add partner'));
  }

  ResultFuture<bool> updateOrganization(
    Map<String, dynamic> organizationData,
  ) async {
    // try {
    //   final response = await apiService.put(
    //     url: ApiEndpoints.profile,
    //     data: organizationData,
    //   );

    // if (response.data['success'] == true) {
    //   return Right(true);
    // } else {
    //   return Left(Failure(response.data['message']));
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Something went wrong'),
    //     );
    //   }
    // }
    return Left(Failure('Failed to add Details'));
  }

  ResultFuture<List<Relationship>> getPartners({
    required String? status,
  }) async {
    // try {
    final response = await apiService.get(
      url: ApiEndpoints.getPartners,
      queryParameters: {'status': status ?? 'All'},
    );

    if (response.data['success'] == true) {
      return Right(
        (response.data['data'] as List)
            .map((e) => Relationship.fromJson(e))
            .toList(),
      );
    } else {
      return Left(Failure(response.data['message']));
    }
    // }
    // catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Something went wrong'),
    //     );
    //   }
    // }
    return Left(Failure('Failed to add partner'));
  }

  ResultFuture<bool> acceptRequest({required String relationshipId}) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.acceptRequest}/$relationshipId',
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
    return Left(Failure('Failed to accept request'));
  }

  ResultFuture<bool> declineRequest({required String relationshipId}) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.declineRequest}/$relationshipId',
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
    return Left(Failure('Failed to decline request'));
  }

  ResultFuture<bool> removeManufacturer({required String processorId}) async {
    try {
      final response = await apiService.delete(
        url: '${ApiEndpoints.removeProcessor}/$processorId',
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
    return Left(Failure('Failed to remove manufacturer'));
  }

  ResultFuture<User> getPendingProcessorById(String id) async {
    try {
      final response = await apiService.get(url: '${ApiEndpoints.org}/$id');

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['data']));
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

  ResultFuture<Organization> getProfile() async {
    // try {
    //   final response = await apiService.get(url: ApiEndpoints.profile);

    // if (response.data['success'] == true) {
    //   final profileData = response.data['data'];

    //   // Create Organization object from API response
    //   final organization = Organization.fromJson(profileData);

    //   // Now we also update the User object in storage to keep data consistent
    //   final user = User(
    //     id: profileData['_id'],
    //     name: profileData['name'],
    //     email: profileData['email'],
    //     phone: profileData['phone'],
    //     organizationId: profileData['_id'],
    //     organizationName: profileData['name'],
    //     organizationType:
    //         profileData['organizationType'] != null
    //             ? OrganizationType.values.byName(
    //               profileData['organizationType'].toLowerCase(),
    //             )
    //             : null,
    //     userType: getUser().userType,
    //     userRole: getUser().userRole,
    //     // Keep the token from existing user
    //     token: getUser().token,
    //     logoUrl: profileData['logo'],
    //   );

    //   // Save updated user to storage
    //   saveUser(user);

    //   return Right(organization);
    // } else {
    //   return Left(
    //     Failure(response.data['message'] ?? 'Failed to get profile'),
    //   );
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data['message'] ?? 'Failed to get profile'),
    //     );
    //   }
    //   AppLogger.error(e.toString());
    // }
    return Left(Failure('Failed to get profile'));
  }
}
