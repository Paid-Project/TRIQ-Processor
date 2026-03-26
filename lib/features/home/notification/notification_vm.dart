import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../api_endpoints.dart';
import '../../../core/locator.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/api.service.dart';
import '../../../services/customer.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/notification.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../tickets/ticket_details/ticket_details.view.dart';

class NotificationViewModel extends ReactiveViewModel {
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();
  final _customerService = locator<CustomerService>();

  // Reactive values
  final ReactiveValue<List<NotificationModel>> _notifications = ReactiveValue<List<NotificationModel>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  final ReactiveValue<String?> _errorMessage = ReactiveValue<String?>(null);

  // Getters
  List<NotificationModel> get notifications => _notifications.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  @override
  bool get hasError => _errorMessage.value != null;

  /// Initialize the view model
  void init() {
    loadNotifications();
  }

  /// Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading.value = true;
    _errorMessage.value = null;
    notifyListeners();

    try {
      AppLogger.info('Loading notifications...');

      final response = await _apiService.get(
        url: ApiEndpoints.getNotifications,
      );

      if (response.statusCode == 200) {
        if (response.data!=null) {
          final List<dynamic> notificationList = response.data['notifications']??[];
          _notifications.value =
              notificationList
                  .map((json) => NotificationModel.fromJson(json))
                  .toList();

          AppLogger.info('Loaded ${_notifications.value.length} notifications');
        } else {
          _notifications.value = [];
          AppLogger.warning('Notifications response is not a list');
        }
        _errorMessage.value = null;
      } else {
        _errorMessage.value =
            response.data['message'] ?? 'Failed to load notifications';
        AppLogger.error('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage.value = 'Error loading notifications: ${e.toString()}';
      AppLogger.error('Exception loading notifications: $e');
    }

    _isLoading.value = false;
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Find the notification and update its read status
      final notificationIndex = _notifications.value.indexWhere(
        (notification) => notification.id == notificationId,
      );

      if (notificationIndex != -1) {
        _notifications.value[notificationIndex].isRead = true;
        notifyListeners();

        AppLogger.info('Marked notification $notificationId as read');
      }
    } catch (e) {
      AppLogger.error('Error marking notification as read: $e');
    }
  }

  /// Get unread notifications count
  int get unreadCount {
    return _notifications.value
        .where((notification) => notification.isRead == false)
        .length;
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.value
        .where((notification) => notification.type == type)
        .toList();
  }

  /// Clear all notifications
  void clearNotifications() {
    _notifications.value = [];
    notifyListeners();
  }

  /// Respond to machine assignment request
  Future<bool> respondToMachineAssignment({
    required String notificationId,
    required String customerId,
    required String action, // 'accept' or 'reject'
  }) async {
    try {
      AppLogger.info('Responding to machine assignment: $action');

      final result = await _customerService.respondToMachineAssignment(
        customerId: customerId,
        action: action,
        notificationId: notificationId,
      );

      return result.fold(
        (failure) {
          AppLogger.error('Failed to respond to machine assignment: ${failure.message}');
          return false;
        },
        (success) {
          AppLogger.info('Machine assignment response successful: $action');
          
          // Remove the notification from the list after successful response
          _notifications.value.removeWhere((notification) => notification.id == notificationId);
          notifyListeners();
          
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Error responding to machine assignment: $e');
      return false;
    }
  }

  /// Handle notification tap
  Future<void> onNotificationTap(BuildContext context, NotificationModel notification) async {
    // Mark as read when tapped
    markAsRead(notification.id ?? '');
    final _navigationService = locator<NavigationService>();
    final payload = <String, dynamic>{
      ...?notification.data?.toJson(),
      'title': notification.title,
      'body': notification.body,
      'type': notification.type,
    };

    final hasRoutePayload =
        (payload['screenName']?.toString().trim().isNotEmpty ?? false) ||
        (payload['roomId']?.toString().trim().isNotEmpty ?? false);

    if (hasRoutePayload) {
      await FirebaseNotificationService.notificationNavigation(data: payload);
      return;
    }

    // Handle different notification types
    switch (notification.type) {
      case 'organizationRequest':
        _handleOrganizationRequest(context, notification);
        break;
      case "ticketRequest":
        _navigationService.navigateToView(
          TicketDetailsView(ticketId: notification.data?.ticketId),
        );
        return;

      default:
        AppLogger.info('Unknown notification type: ${notification.type}');
    }
  }


  /// Handle organization request notification
  void _handleOrganizationRequest(
    BuildContext context,
    NotificationModel notification,
  ) {
    AppLogger.info(
      'Handling organization request: ${notification.data?.processorId}',
    );
  }

  /// Fetch customer by ID from API
  Future<Customer?> fetchCustomerById(String customerId) async {
    try {
      AppLogger.info('Fetching customer with ID: $customerId');

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.get(
                url: '${ApiEndpoints.getCustomerById}/$customerId',
              );

              AppLogger.info("API Response: ${apiResponse.data}");

              if (apiResponse.statusCode == 200) {
                final customer = Customer.fromJson(apiResponse.data);
                AppLogger.info(
                  'Successfully fetched customer: ${customer.customerName}',
                );
                return customer;
              } else {
                AppLogger.error(
                  'Failed to fetch customer: ${apiResponse.statusCode}',
                );
                throw Exception(
                  apiResponse.data?['message'] ?? 'Failed to fetch customer',
                );
              }
            } catch (e) {
              AppLogger.error("Error fetching customer: $e");
              rethrow;
            }
          },
          message: 'Fetching customer data...',
        ),
      );

      if (response?.confirmed == true && response?.data is Customer) {
        return response!.data as Customer;
      } else {
        throw Exception(
          response?.data?.toString() ?? 'Failed to fetch customer',
        );
      }
    } catch (e) {
      AppLogger.error("Error in fetchCustomerById: $e");
      rethrow;
    }
  }

  /// Delete notification by ID
  Future<bool> deleteNotification(String notificationId) async {
    try {
      AppLogger.info('Deleting notification with ID: $notificationId');

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.get(
                url: '${ApiEndpoints.deleteNotification}/$notificationId',
              );

              AppLogger.info("Delete API Response: ${apiResponse.data}");

              if (apiResponse.statusCode == 200) {
                final responseData = apiResponse.data;
                if (responseData is Map<String, dynamic> &&
                    responseData['success'] == true) {
                  AppLogger.info(
                    'Successfully deleted notification: $notificationId',
                  );
                  return true;
                } else {
                  throw Exception(
                    responseData['msg'] ?? 'Failed to delete notification',
                  );
                }
              } else {
                AppLogger.error(
                  'Failed to delete notification: ${apiResponse.statusCode}',
                );
                throw Exception(
                  apiResponse.data?['msg'] ?? 'Failed to delete notification',
                );
              }
            } catch (e) {
              AppLogger.error("Error deleting notification: $e");
              rethrow;
            }
          },
          message: 'Deleting notification...',
        ),
      );

      if (response?.confirmed == true && response?.data == true) {
        return true;
      } else {
        throw Exception(
          response?.data?.toString() ?? 'Failed to delete notification',
        );
      }
    } catch (e) {
      AppLogger.error("Error in deleteNotification: $e");
      rethrow;
    }
  }

  /// update notification action by ID
  Future<bool> updateNotificationAction(String ticketId, String type) async {
    try {
      AppLogger.info('update notification with ID: $ticketId');

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.post(
                url: ApiEndpoints.updateNotification,
                data: {'ticketId': ticketId, 'type': type},
              );

              AppLogger.info("update API Response Action: ${apiResponse.data}");

              if (apiResponse.statusCode == 200) {
                final responseData = apiResponse.data;
                if (responseData is Map<String, dynamic> &&
                    responseData['success'] == true) {
                  AppLogger.info(
                    'Successfully updated notification: $ticketId',
                  );

                  notifications.removeWhere((ticket) => ticket.data?.ticketId == ticketId);

                  return true;
                } else {
                  throw Exception(
                    responseData['msg'] ?? 'Failed to update notification action',
                  );
                }
              } else {
                AppLogger.error(
                  'Failed to update notification action: ${apiResponse.statusCode}',
                );
                throw Exception(
                  apiResponse.data?['msg'] ?? 'Failed to update notification action',
                );
              }
            } catch (e) {
              AppLogger.error("Error updating notification action: $e");
              rethrow;
            }
          },
          message: 'Updating notification...',
        ),
      );

      if (response?.confirmed == true && response?.data == true) {
        _notifications.value.removeWhere((ticket) => ticket.data?.ticketId == ticketId);
        notifyListeners();
        return true;
      } else {
        throw Exception(
          response?.data?.toString() ?? 'Failed to update notification action',
        );
      }
    } catch (e) {
      AppLogger.error("Error in updateNotification: $e");
      rethrow;
    }
  }
}
