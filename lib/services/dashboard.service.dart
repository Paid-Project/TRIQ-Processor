import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/dashboard.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

class DashboardService {
  final apiService = locator<ApiService>();

  ResultFuture<Dashboard> getDashboardData() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.dashboard);

      if (response.data['success'] == true && response.data['data'] != null) {
        // The actual data is nested under the 'data' key
        return Right(Dashboard.fromJson(response.data['data']));
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Invalid response format'),
        );
      }
    } catch (e) {
      AppLogger.error("Error getting dashboard data: $e");
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get dashboard data: ${e.toString()}'));
    }
  }
}
