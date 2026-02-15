import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/core/models/contact_chat.model.dart';

import '../api_endpoints.dart';
import '../core/locator.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/failures.dart';
import '../core/utils/type_def.dart';
import 'api.service.dart';

class ContactService {
  final _apiService = locator<ApiService>();

  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  // Stream controller for external refresh triggers
  final _refreshController = StreamController<bool>.broadcast();

  Stream<bool> get refreshStream => _refreshController.stream;

  void triggerRefresh() {
    if (!_isRefreshing) {
      _refreshController.add(true);
      AppLogger.highlight("Refresh triggered from external source");
    } else {
      AppLogger.warning("Refresh already in progress, ignoring trigger");
    }
  }

  // Reset refresh flag manually if needed
  void resetRefreshFlag() {
    _isRefreshing = false;
  }

  ResultFuture<bool> sendExternalContactRequest({required String id}) async {
    try {
      final response = await _apiService.post(
        url: '${ApiEndpoints.sendExternalChatRequest}',
        data: {"receiverId": id},
      );

      if (response.data['status'] == 1) {
        return Right(true);
      } else {
        return Left(Failure(response.data['msg']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to send message'));
  }

  ResultFuture<Map<String, dynamic>> getAllContact({
    required int page,
    required int limit,
    required String tab,
    String screen = 'contact',
  }) async {
    try {
      final response = await _apiService.get(
        url: ApiEndpoints.getAllContact + "${tab}",
        queryParameters: {
          'page': page,
          'limit': limit,
          "screenType": screen == 'chat' ? 'chat' : '',
        },
      );

      if (response.statusCode == 200) {
        // Pura paginated response object return karein (e.g., { "page": 1, "data": [...] })
        return Right(response.data);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get all chats'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get all chats: $e'));
    }
  }

  ResultFuture<List<ContactChat>> searchContact(String query) async {
    try {
      AppLogger.info("Searching employee with query: $query");

      final response = await _apiService.get(
        url: ApiEndpoints.searchContact,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List<dynamic> employeeData = data['data']['externals'];
          final employee =
              employeeData.map((json) => ContactChat.fromJson(json)).toList();
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
}
