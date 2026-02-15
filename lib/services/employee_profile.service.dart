import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
// import 'package:manager/core/models/relationships.dart';
// import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

// import '../core/models/hive/user/user.dart';
import '../core/models/employee.dart'; // Changed from organization.dart
// import '../core/storage/storage.dart';
import '../core/utils/failures.dart';

class EmployeeProfileService {
  final apiService = locator<ApiService>();

  ResultFuture<bool> updateEmployeeProfile(
    Map<String, dynamic> employeeData,
  ) async {
    // try {
    //   final response = await apiService.put(
    //     url: ApiEndpoints.profile,
    //     data: employeeData,
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
    //   AppLogger.error(e.toString());
    // }
    return Left(Failure('Failed to update employee profile'));
  }

  ResultFuture<Employee> getProfile() async {
    // try {
    //   final response = await apiService.get(
    //     url: ApiEndpoints.profile,
    //   );

    // if (response.data['success'] == true) {
    //   final profileData = response.data['data'];

    //   // Create Employee object from API response
    //   final employee = Employee.fromJson(profileData);

    //   // Update the User object in storage to keep data consistent
    //   final currentUser = getUser();
    //   final updatedUser = User(
    //     id: profileData['_id'],
    //     name: employee.displayName, // Use the helper method from Employee
    //     email: employee.primaryEmail, // Use the helper method from Employee
    //     phone: employee.primaryPhone, // Use the helper method from Employee
    //     organizationId: profileData['organizationId'],
    //     organizationName: profileData['organization']?['name'], // From nested organization object
    //     organizationType: profileData['organization']?['organizationType'] != null
    //         ? OrganizationType.values.byName(
    //       profileData['organization']['organizationType'].toLowerCase(),
    //     )
    //         : currentUser.organizationType, // Keep existing if not provided
    //     userType: currentUser.userType, // Keep existing user type
    //     userRole: currentUser.userRole, // Keep existing user role
    //     token: currentUser.token, // Keep the existing token
    //     logoUrl: currentUser.logoUrl, // Keep existing logo or could be updated if needed
    //   );

    //   // Save updated user to storage
    //   saveUser(updatedUser);

    //   return Right(employee);
    // } else {
    //   return Left(
    //     Failure(response.data['message'] ?? 'Failed to get profile'),
    //   );
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Failed to get profile'),
    //     );
    //   }
    //   AppLogger.error(e.toString());
    // }
    return Left(Failure('Failed to get profile'));
  }
}
