import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/features/chat/model/chat_message_model.dart';

import '../api_endpoints.dart';
import '../core/locator.dart';
import '../core/models/chat_list_model.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/failures.dart';
import '../core/utils/type_def.dart';
import 'api.service.dart';

class ChatService {
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
    }
    else {
      AppLogger.warning("Refresh already in progress, ignoring trigger");
    }
  }

  // Reset refresh flag manually if needed
  void resetRefreshFlag() {
    _isRefreshing = false;
  }

  Future<Map<String, dynamic>> sendVChatStatus({
    required String roomName,
    required String status,
    required String callType,
    required String name,
    required String users,
  }) async {
    try {
      final response = await _apiService.post(
        url: '${ApiEndpoints.sendVChatStatus}',
        data: {
          'roomName': roomName,
          'eventType': status,
          'name': name,
          'users': users,
          'identity':name,
          'callType':callType
        },
      );

      if (response.data['status']==1) {
        return {
          'success': true,
          ...response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return {
          'success': false,
          'message': e.response?.data?['message'] ?? 'Something went wrong',
        };
      }}
    return {
      'success': false,
      'message': 'Something went wrong',
    };
  }

  ResultFuture<List<ChatMessageModel>> getAllChatMessages({
    required String roomId,
  }) async {
    try {
      final response = await _apiService.get(
        url: '${ApiEndpoints.getAllChatMessages}/$roomId',
      );

      if (response.statusCode == 200) {
        List<ChatMessageModel> messageList =
        (response.data as List)
            .map((e) => ChatMessageModel.fromJson(e))
            .toList();
        return Right(messageList);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get messages'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get messages: $e'));
    }
  }

  /// Get paginated chat messages
  ResultFuture<Map<String, dynamic>> getPaginatedChatMessages({
    required String roomId,
    required int page,
    required int limit,
    required String screen,
  }) async {
    try {

      String apiUrl='';
      print("screen:-${screen}");
      if(screen=='groupChat'){
        apiUrl='${ApiEndpoints.getGroupChatMessage}/$roomId';
      }else
      if(screen=='contactChat'){
        apiUrl='${ApiEndpoints.getAllContactChatMessages}/$roomId';
      }else{
        apiUrl='${ApiEndpoints.getAllChatMessages}/$roomId';
      }
      final response = await _apiService.get(
        url: apiUrl,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return Right(response.data);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get messages'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get messages: $e'));
    }
  }

  ResultFuture<Map<String, dynamic>> getAllChats({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        url: ApiEndpoints.getAllChats,
        queryParameters: {'page': page, 'limit': limit}, // Pagination parameters
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
  Future<Map<String, dynamic>> editChat({
    required String messageId,
    required String content,
  }) async {
    try {
      print("🎯 editChat called with:qqq ");
      final response = await _apiService.post(
        url: '${ApiEndpoints.editMessages}/$messageId',
        data: {
          "content": content,
        },
      );
      print("🎯 editChat called with: ${response.statusCode == 200}");
      if (response.statusCode == 200) {

      } else {

      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');

      }}
    return {
      'success': false,
      'message': 'Something went wrong',
    };
  }
  Future<Map<String, dynamic>> deleteChat({
    required String messageId,

  }) async {
    try {
      final response = await _apiService.post(
        url: '${ApiEndpoints.deleteMessages}/$messageId',

      );
      print("🎯 deleteChat called with: ${response.statusCode == 200}");
      if (response.statusCode == 200) {

      } else {

      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');

      }}
    return {
      'success': false,
      'message': 'Something went wrong',
    };
  }
  /// Upload files for chat
  ResultFuture<Map<String, dynamic>> uploadChatFiles(
      List<String> filePaths,
      String screen,

      ) async {
    try {
      String apiUrl='';
      if(screen=='contactChat'){
        apiUrl='${ApiEndpoints.uploadChatContactFile}';
      }else{
        apiUrl='${ApiEndpoints.uploadChatFile}';
      }
      final List<MultipartFile> files = [];

      for (String filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }

      final formData = FormData.fromMap({'files': files});

      final response = await _apiService.post(
        url: apiUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 201) {
        return Right(response.data);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to upload files'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to upload files: $e'));
    }
  }
}
