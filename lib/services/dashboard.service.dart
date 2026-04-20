  import 'dart:convert';

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

    ResultFuture<DashboardModel> getDashboardData() async {
      try {
        final response = await apiService.get(url: ApiEndpoints.getIndicator);
        final dynamic rawResponse = response.data;
        final Map<String, dynamic> responseData =
        rawResponse is String
            ? Map<String, dynamic>.from(jsonDecode(rawResponse) as Map)
            : rawResponse is Map
            ? Map<String, dynamic>.from(rawResponse)
            : <String, dynamic>{};

        final dynamic nestedData = responseData['data'];
        final Map<String, dynamic> dashboardData =
        nestedData is Map
            ? Map<String, dynamic>.from(nestedData)
            : responseData;

        final bool hasDashboardKeys =
            dashboardData.containsKey('ticket') ||
                dashboardData.containsKey('task') ||
                dashboardData.containsKey('customer');

        if (!hasDashboardKeys) {
          AppLogger.error('Invalid dashboard response: $responseData');
          return Left(
            Failure(responseData['message'] ?? 'Invalid dashboard response'),
          );
        }

        return Right(DashboardModel.fromJson(dashboardData));
      } catch (e) {
        AppLogger.error("Error getting dashboard data: $e");
        if (e is DioException) {
          final dynamic errorData = e.response?.data;
          final String message =
          errorData is Map
              ? (Map<String, dynamic>.from(errorData)['message'] ??
              'Something went wrong')
              : 'Something went wrong';
          return Left(Failure(message));
        }
        return Left(Failure('Failed to get dashboard data: ${e.toString()}'));
      }
    }

    Future<void> sendMarkSeen(String feature) async {

      try{
        // isEmailVarificationSend.value=true;
        final apiResponse = await apiService.post(
          url: ApiEndpoints.mark_seen,
          data: {'feature': feature},
        );
  print("🎯 sendMarkSeen called with:$apiResponse ");
        if (apiResponse.statusCode == 200) {

          // Fluttertoast.showToast(
          //   msg: LanguageService.get('Email sent successfully'),
          //   backgroundColor: Colors.green,
          //   textColor: Colors.white,
          //   toastLength: Toast.LENGTH_SHORT,
          // );

        } else {
          // isEmailVarificationSend.value=false;
          throw Exception(
            apiResponse.data['message'] ?? 'Failed to send OTP',
          );
        }
      } catch (e) {
        throw Exception(e.toString());
      }

    }
  }
