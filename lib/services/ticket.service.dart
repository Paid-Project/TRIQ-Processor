import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/ticket.dart';
import 'package:manager/core/models/ticket_model.dart';
import 'package:manager/core/models/review_ticket_model.dart';
import 'package:manager/core/models/ticket_details_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

class TicketService {
  final apiService = locator<ApiService>();

  // Flag to track if a refresh operation is in progress
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

  ResultFuture<List<Ticket>> getTickets({
    String? status,
    String? priority,
    String? processorId,
    String? manufacturerId,
    String? machineId,
    String? employeeId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // If already refreshing and not forced, return a failure
    if (_isRefreshing && !forceRefresh) {
      return Left(Failure('Refresh already in progress'));
    }

    try {
      _isRefreshing = true;

      final response = await apiService.get(
        url: ApiEndpoints.tickets,
        queryParameters: {
          'status': status,
          'priority': priority,
          'processorId': processorId,
          'manufacturerId': manufacturerId,
          'machineId': machineId,
          'employeeId': employeeId,
          'startDate': startDate,
          'endDate': endDate,
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Ticket.fromJson(e))
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
    } finally {
      _isRefreshing = false;
    }
    return Left(Failure('Failed to get tickets'));
  }

  // Reset refresh flag manually if needed
  void resetRefreshFlag() {
    _isRefreshing = false;
  }

  // Clean up resources
  void dispose() {
    _refreshController.close();
  }

  ResultFuture<String> createTicket({
    required String machineId,
    required String title,
    required String description,
    required String ticketType,
    required List<Map<String, dynamic>>? additionalInfo,
    List<String>? attachments,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.tickets,
        data: {
          "machineId": machineId,
          "title": title,
          "description": description,
          "ticketType": ticketType,
          "additionalInfo": additionalInfo,
          "attachments": attachments ?? [],
        },
      );

      if (response.data['success'] == true) {
        return Right(response.data['data']['chatRoomData']['ticketId']['_id']);
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
    return Left(Failure('Failed to create ticket'));
  }

  ResultFuture<Ticket> getTicketById({required String id}) async {
    try {
      final response = await apiService.get(url: '${ApiEndpoints.tickets}/$id');

      if (response.data['success'] == true) {
        AppLogger.highlight(response.data['data']);
        return Right(Ticket.fromJson(response.data['data']));
      } else {
        AppLogger.error(response.data['message']);
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to create ticket'));
  }

  ResultFuture<Ticket> pingTicket({required String id}) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.pingTicket}/$id',
        data: {"id": id},
      );

      if (response.data['success'] == true) {
        AppLogger.highlight(response.data['data']);
        return Right(Ticket.fromJson(response.data['data']));
      } else {
        AppLogger.error(response.data['message']);
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to create ticket'));
  }

  ResultFuture<Ticket> holdTicket({
    required String id,
    String? nextPingTime,
  }) async {
    try {

      final response = await apiService.put(
        url: '${ApiEndpoints.holdTicket}/$id',
        data: {"status": "OnHold", "reshedule": nextPingTime},
      );

      if (response.data['success'] == true) {
        AppLogger.highlight(response.data['data']);
        return Right(Ticket.fromJson(response.data['data']));
      }
      else {
        AppLogger.error(response.data['message']);
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to create ticket'));
  }

  ResultFuture<bool> resolveTicket({
    required String id,
    String? closingRemark,
  }) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.resolveTicket}/$id',
        data: {'closingRemark': closingRemark},
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to resolve ticket'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to Resolve ticket'));
  }

  ResultFuture<bool> requestResolveTicket({required String id}) async {
    try {

      final response = await apiService.put(
        url: '${ApiEndpoints.requestResolveTicket}/$id',
      );


      if (response.data['success'] == true) {
        return Right(true);
      }
      else {
        return Left(
          Failure(
            response.data['message'] ??
                'Failed to request resolution of ticket',
          ),
        );
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to request resolution of ticket'));
  }

  ResultFuture<bool> rejectResolveTicket({required String id}) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.rejectResolveTicket}/$id',
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(
          Failure(
            response.data['message'] ?? 'Failed to reject resolution of ticket',
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
      }
    }
    return Left(Failure('Failed to reject resolution of ticket'));
  }

  /// Get tickets by status with pagination using the new API
  ResultFuture<TicketModel> getTicketsByStatus({
    required String status, // 'Active' or 'Resolved'
    int page = 1,
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    // If already refreshing and not forced, return a failure
    if (_isRefreshing && !forceRefresh) {
      return Left(Failure('Refresh already in progress'));
    }

    try {
      _isRefreshing = true;

      final response = await apiService.get(
        url: '${ApiEndpoints.getTicketsByStatus}/$status',
        queryParameters: {'page': page, 'limit': limit},
          showToast:false
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final paginatedResponse = TicketModel.fromJson(data);
          AppLogger.info("Tickets fetched successfully: ${paginatedResponse.data?.length ?? 0} tickets (Page: ${paginatedResponse.page}/${paginatedResponse.pages})");
          return Right(paginatedResponse);
        } else {
          AppLogger.error("Empty response data");
          return Left(Failure('Empty response data'));
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch tickets';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } catch (e) {
      AppLogger.error("Exception in getTicketsByStatus: $e");
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
        return Left(Failure('Failed to get tickets: ${e.toString()}'));
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Get all tickets using the new getAll endpoint (kept for backward compatibility)
  ResultFuture<List<TicketList>> getAllTickets({bool forceRefresh = false}) async {
    // If already refreshing and not forced, return a failure
    if (_isRefreshing && !forceRefresh) {
      return Left(Failure('Refresh already in progress'));
    }

    try {
      _isRefreshing = true;

      final response = await apiService.get(url: ApiEndpoints.getAllTickets);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          // Check if data is a list or a single object
          if (data is List) {
            // If it's a list, map each item to Datum
            final tickets = data.map((e) => TicketList.fromJson(e)).toList();
            AppLogger.info(
              "Tickets fetched successfully: ${tickets.length} tickets",
            );
            return Right(tickets);
          } else if (data is Map<String, dynamic>) {
            // If it's a single object, check if it has a 'data' field
            if (data.containsKey('data') && data['data'] is List) {
              final tickets =
                  (data['data'] as List).map((e) => TicketList.fromJson(e)).toList();
              AppLogger.info(
                "Tickets fetched successfully: ${tickets.length} tickets",
              );
              return Right(tickets);
            } else {
              // If it's a single ticket object
              final ticket = TicketList.fromJson(data);
              AppLogger.info(
                "Single ticket fetched successfully: ${ticket.id}",
              );
              return Right([ticket]);
            }
          } else {
            AppLogger.error("Invalid response format: $data");
            return Left(Failure('Invalid response format'));
          }
        } else {
          AppLogger.error("Empty response data");
          return Left(Failure('Empty response data'));
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch tickets';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } catch (e) {
      AppLogger.error("Exception in getAllTickets: $e");
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
        return Left(Failure('Failed to get tickets: ${e.toString()}'));
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Get ticket summary with all related details
  ResultFuture<ReviewTicketModel> getTicketSummary({
    required String ticketId,
  }) async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.getTicketSummary}/$ticketId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final reviewTicketModel = ReviewTicketModel.fromJson(data);
          AppLogger.info(
            "Ticket summary fetched successfully for ticket: $ticketId",
          );
          return Right(reviewTicketModel);
        } else {
          AppLogger.error("Empty response data for ticket summary");
          return Left(Failure('Empty response data'));
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch ticket summary';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } catch (e) {
      AppLogger.error("Exception in getTicketSummary: $e");
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
        return Left(Failure('Failed to get ticket summary: ${e.toString()}'));
      }
    }
  }

  /// Get ticket details with all related information
  ResultFuture<TicketDetailsModel> getTicketDetails({
    required String ticketId,
  }) async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.getTicketSummary}/$ticketId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final ticketDetailsModel = TicketDetailsModel.fromJson(data);
          AppLogger.info(
            "Ticket details fetched successfully for ticket: ${data}",
          );
          return Right(ticketDetailsModel);
        } else {
          AppLogger.error("Empty response data for ticket details");
          return Left(Failure('Empty response data'));
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch ticket details';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } catch (e) {
      AppLogger.error("Exception in getTicketDetails: $e");
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      } else {
        AppLogger.error(e);
        return Left(Failure('Failed to get ticket details: ${e.toString()}'));
      }
    }
  }
}
