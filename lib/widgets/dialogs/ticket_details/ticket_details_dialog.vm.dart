// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:manager/core/models/hive/user/user.dart';
// import 'package:manager/core/models/ticket.dart';
// import 'package:manager/core/storage/storage.dart';
// import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
//
// import '../../../core/locator.dart';
// import '../../../core/utils/app_logger.dart';
// import '../../../core/utils/type_def.dart';
// import '../../../services/dialogs.service.dart';
// import '../../../services/ticket.service.dart';
// import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
//
// class TicketDetailsViewModel extends ReactiveViewModel {
//   final _navigationService = locator<NavigationService>();
//   final _dialogService = locator<DialogService>();
//   final _ticketService = locator<TicketService>();
//
//   // Reactive values
//   final ReactiveValue<bool> _isBusy = ReactiveValue(false);
//   final ReactiveValue<Ticket?> _ticket = ReactiveValue(null);
//   final ReactiveValue<Duration?> _selectedHoldDuration = ReactiveValue(null);
//   final ReactiveValue<String?> _lastPingTime = ReactiveValue(null);
//   final ReactiveValue<bool> _isLoadingComments = ReactiveValue(false);
//   final ReactiveValue<List<TicketComment>> _comments = ReactiveValue([]);
//
//   // Ticket activity tracking
//   final ReactiveValue<List<TicketActivity>> _activities = ReactiveValue([]);
//   final ReactiveValue<bool> _isLoadingActivities = ReactiveValue(false);
//
//   // Text controllers for adding comments
//   final TextEditingController commentController = TextEditingController();
//
//   // Getters
//   bool get isBusy => _isBusy.value;
//   Ticket? get ticket => _ticket.value;
//   Duration? get selectedHoldDuration => _selectedHoldDuration.value;
//   String? get lastPingTime => _lastPingTime.value;
//   List<TicketComment> get comments => _comments.value;
//   bool get isLoadingComments => _isLoadingComments.value;
//   List<TicketActivity> get activities => _activities.value;
//   bool get isLoadingActivities => _isLoadingActivities.value;
//
//   // Customer and machine info
//   String _customerName = 'Customer';
//   String _countryCode = 'N/A';
//   String _machineName = 'Unknown Machine';
//   String _errorDescription = 'No description provided';
//   String _elapsedTime = 'N/A';
//
//   String get customerName => _customerName;
//   String get countryCode => _countryCode;
//   String get machineName => _machineName;
//   String get errorDescription => _errorDescription;
//   String get elapsedTime => _elapsedTime;
//
//   // Timer for ping countdown and elapsed time
//   Timer? _pingTimer;
//   Timer? _elapsedTimer;
//
//   final ReactiveValue<String> _remainingPingTime = ReactiveValue('0:00');
//   String get remainingPingTime => _remainingPingTime.value;
//
//   // States derived from ticket data
//   bool get canPing {
//     if (lastPingTime == null) return true;
//
//     try {
//       final lastPingDateTime = DateTime.parse(lastPingTime!);
//       final now = DateTime.now();
//       if (lastPingDateTime.isAfter(now)) {
//         return false;
//       }
//       final difference = now.difference(lastPingDateTime);
//       return difference.inMinutes >= 5;
//     } catch (e) {
//       return true;
//     }
//   }
//
//   // Initialize the view model
//   void init(String ticketId) async {
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final response = await _dialogService.showCustomDialog(
//         variant: DialogType.loader,
//         data: LoaderDialogAttributes(
//           task: () => _ticketService.getTicketById(ticketId),
//         ),
//       );
//
//       if (response?.data != null) {
//         ((response?.data) as EitherResult<Ticket>).fold(
//               (exception) {
//             AppLogger.error('Failed to load ticket: ${exception.toString()}');
//             Fluttertoast.showToast(msg: 'Failed to load ticket details');
//           },
//               (ticketData) {
//             _ticket.value = ticketData;
//             _extractTicketInfo(ticketData);
//             _startTimers();
//
//             // Load additional data
//             _loadTicketComments(ticketId);
//             _loadTicketActivities(ticketId);
//           },
//         );
//       }
//     } catch (e) {
//       AppLogger.error('Error loading ticket: $e');
//       Fluttertoast.showToast(msg: 'An error occurred while loading ticket');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Extract additional info from ticket
//   void _extractTicketInfo(Ticket ticket) {
//     // Extract customer name
//     if (ticket.customer != null) {
//       _customerName = ticket.customer!.name ?? 'Customer';
//
//       // Extract country code (this would depend on your data structure)
//       if (ticket.customer!.country != null) {
//         _countryCode = ticket.customer!.country!.code ?? 'N/A';
//       }
//     }
//
//     // Extract machine info
//     if (ticket.machine != null) {
//       _machineName = ticket.machine!.machineName ?? 'Unknown Machine';
//     }
//
//     // Extract error description
//     _errorDescription = ticket.description ?? 'No description provided';
//
//     // Extract last ping time if available
//     _lastPingTime.value = ticket.lastPingTime;
//
//     // Calculate elapsed time
//     _updateElapsedTime(ticket.createdAt);
//   }
//
//   // Update selected hold duration
//   void updateSelectedHoldDuration(Duration? duration) {
//     _selectedHoldDuration.value = duration;
//     notifyListeners();
//   }
//
//   // Load ticket comments
//   Future<void> _loadTicketComments(String ticketId) async {
//     if (_isLoadingComments.value) return;
//
//     _isLoadingComments.value = true;
//     notifyListeners();
//
//     try {
//       final result = await _ticketService.getTicketComments(ticketId);
//
//       result.fold(
//             (exception) {
//           AppLogger.error('Failed to load comments: ${exception.toString()}');
//           // No toast here to avoid UI clutter
//         },
//             (commentsList) {
//           _comments.value = commentsList;
//         },
//       );
//     } catch (e) {
//       AppLogger.error('Error loading comments: $e');
//     } finally {
//       _isLoadingComments.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Load ticket activities
//   Future<void> _loadTicketActivities(String ticketId) async {
//     if (_isLoadingActivities.value) return;
//
//     _isLoadingActivities.value = true;
//     notifyListeners();
//
//     try {
//       final result = await _ticketService.getTicketActivities(ticketId);
//
//       result.fold(
//             (exception) {
//           AppLogger.error('Failed to load activities: ${exception.toString()}');
//           // No toast here to avoid UI clutter
//         },
//             (activitiesList) {
//           _activities.value = activitiesList;
//         },
//       );
//     } catch (e) {
//       AppLogger.error('Error loading activities: $e');
//     } finally {
//       _isLoadingActivities.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Add a new comment
//   Future<void> addComment() async {
//     if (commentController.text.trim().isEmpty) {
//       Fluttertoast.showToast(msg: 'Please enter a comment');
//       return;
//     }
//
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot add comment: Ticket information is missing');
//       return;
//     }
//
//     final commentText = commentController.text.trim();
//     commentController.clear();
//
//     final tempComment = TicketComment(
//       id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
//       ticketId: _ticket.value!.id!,
//       userId: getUser().id ?? '',
//       userName: getUser().fullName ?? 'User',
//       userRole: getUser().role ?? 'User',
//       comment: commentText,
//       createdAt: DateTime.now().toIso8601String(),
//       isTemporary: true,
//     );
//
//     // Add temporary comment to UI
//     _comments.value = [tempComment, ..._comments.value];
//     notifyListeners();
//
//     try {
//       final result = await _ticketService.addComment(_ticket.value!.id!, commentText);
//
//       result.fold(
//             (exception) {
//           AppLogger.error('Failed to add comment: ${exception.toString()}');
//           Fluttertoast.showToast(msg: 'Failed to add comment');
//
//           // Remove temporary comment
//           _comments.value = _comments.value.where((c) => c.id != tempComment.id).toList();
//           notifyListeners();
//         },
//             (success) {
//           // Reload comments to get the real one with server ID
//           _loadTicketComments(_ticket.value!.id!);
//         },
//       );
//     } catch (e) {
//       AppLogger.error('Error adding comment: $e');
//       Fluttertoast.showToast(msg: 'An error occurred');
//
//       // Remove temporary comment
//       _comments.value = _comments.value.where((c) => c.id != tempComment.id).toList();
//       notifyListeners();
//     }
//   }
//
//   // Start timers for ping countdown and elapsed time
//   void _startTimers() {
//     _startPingCountdownTimer();
//     _startElapsedTimeTimer();
//   }
//
//   // Start the countdown timer for ping functionality
//   void _startPingCountdownTimer() {
//     _pingTimer?.cancel();
//
//     if (_lastPingTime.value == null || canPing) return;
//
//     _pingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_ticket.value == null) {
//         timer.cancel();
//         return;
//       }
//
//       try {
//         final lastPingDateTime = DateTime.parse(_lastPingTime.value!);
//         final now = DateTime.now();
//         DateTime nextPingTime = lastPingDateTime.add(Duration(minutes: 5));
//
//         if (lastPingDateTime.isAfter(now)) {
//           nextPingTime = lastPingDateTime;
//         }
//
//         if (now.isAfter(nextPingTime)) {
//           _remainingPingTime.value = '0:00';
//           timer.cancel();
//           notifyListeners();
//           return;
//         }
//
//         final remaining = nextPingTime.difference(now);
//         final minutes = remaining.inMinutes;
//         final seconds = remaining.inSeconds % 60;
//
//         _remainingPingTime.value = '$minutes:${seconds.toString().padLeft(2, '0')}';
//         notifyListeners();
//       } catch (e) {
//         timer.cancel();
//         AppLogger.error('Error in ping timer: $e');
//       }
//     });
//   }
//
//   // Start timer to update elapsed time since ticket creation
//   void _startElapsedTimeTimer() {
//     _elapsedTimer?.cancel();
//
//     if (_ticket.value?.createdAt == null) return;
//
//     // Update immediately
//     _updateElapsedTime(_ticket.value!.createdAt);
//
//     // Then update every minute
//     _elapsedTimer = Timer.periodic(Duration(minutes: 1), (timer) {
//       if (_ticket.value == null || _ticket.value!.createdAt == null) {
//         timer.cancel();
//         return;
//       }
//
//       _updateElapsedTime(_ticket.value!.createdAt!);
//       notifyListeners();
//     });
//   }
//
//   // Calculate and update elapsed time
//   void _updateElapsedTime(String? createdAt) {
//     if (createdAt == null) {
//       _elapsedTime = 'N/A';
//       return;
//     }
//
//     try {
//       final created = DateTime.parse(createdAt);
//       final now = DateTime.now();
//       final difference = now.difference(created);
//
//       if (difference.inDays > 0) {
//         _elapsedTime = '${difference.inDays}d ${difference.inHours % 24}h';
//       } else if (difference.inHours > 0) {
//         _elapsedTime = '${difference.inHours}h ${difference.inMinutes % 60}m';
//       } else if (difference.inMinutes > 0) {
//         _elapsedTime = '${difference.inMinutes}m';
//       } else {
//         _elapsedTime = 'Just now';
//       }
//     } catch (e) {
//       _elapsedTime = 'N/A';
//       AppLogger.error('Error calculating elapsed time: $e');
//     }
//   }
//
//   // Refresh all ticket data
//   Future<void> refreshTicket() async {
//     if (_ticket.value == null || _ticket.value!.id == null) return;
//
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final result = await _ticketService.getTicketById(_ticket.value!.id!);
//
//       result.fold(
//             (exception) {
//           AppLogger.error('Failed to refresh ticket: ${exception.toString()}');
//           Fluttertoast.showToast(msg: 'Failed to refresh ticket data');
//         },
//             (ticketData) {
//           _ticket.value = ticketData;
//           _extractTicketInfo(ticketData);
//           _startTimers();
//
//           // Reload additional data
//           _loadTicketComments(_ticket.value!.id!);
//           _loadTicketActivities(_ticket.value!.id!);
//         },
//       );
//     } catch (e) {
//       AppLogger.error('Error refreshing ticket: $e');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Action handlers
//   void onChatPressed() async {
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot open chat: Ticket information is missing');
//       return;
//     }
//
//     // Navigate to chat screen (adjust this based on your manager's navigation)
//     // _navigationService.navigateTo(
//     //   Routes.ticketChat,
//     //   parameters: {'ticketId': _ticket.value!.id!},
//     // );
//
//     // For now just show a toast
//     Fluttertoast.showToast(msg: 'Opening chat for ticket ${_ticket.value!.id!.substring(0, 8)}');
//   }
//
//   void onHoldPressed() async {
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot put ticket on hold: Information is missing');
//       return;
//     }
//
//     if (_selectedHoldDuration.value == null) {
//       Fluttertoast.showToast(msg: 'Please select a hold duration');
//       return;
//     }
//
//     // Show confirmation dialog
//     final confirmed = await _dialogService.showConfirmationDialog(
//       title: 'Reschedule Ticket',
//       description: 'Are you sure you want to reschedule this ticket for ${_formatDuration(_selectedHoldDuration.value!)}?',
//       confirmationTitle: 'Reschedule',
//       cancelTitle: 'Cancel',
//     );
//
//     if (confirmed?.confirmed != true) return;
//
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final response = await _dialogService.showCustomDialog(
//         variant: DialogType.loader,
//         data: LoaderDialogAttributes(
//           task: () => _ticketService.holdTicket(
//             _ticket.value!.id!,
//             _selectedHoldDuration.value!,
//           ),
//         ),
//       );
//
//       if (response?.data != null) {
//         ((response?.data) as EitherResult<bool>).fold(
//               (exception) {
//             AppLogger.error('Failed to hold ticket: ${exception.toString()}');
//             Fluttertoast.showToast(msg: 'Failed to reschedule ticket');
//           },
//               (success) {
//             Fluttertoast.showToast(msg: 'Ticket rescheduled successfully');
//             refreshTicket();
//           },
//         );
//       }
//     } catch (e) {
//       AppLogger.error('Error putting ticket on hold: $e');
//       Fluttertoast.showToast(msg: 'An error occurred');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   void onPingPressed() async {
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot ping ticket: Information is missing');
//       return;
//     }
//
//     if (!canPing) {
//       Fluttertoast.showToast(msg: 'Please wait before pinging again');
//       return;
//     }
//
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final response = await _dialogService.showCustomDialog(
//         variant: DialogType.loader,
//         data: LoaderDialogAttributes(
//           task: () => _ticketService.pingTicket(_ticket.value!.id!),
//         ),
//       );
//
//       if (response?.data != null) {
//         ((response?.data) as EitherResult<bool>).fold(
//               (exception) {
//             AppLogger.error('Failed to ping ticket: ${exception.toString()}');
//             Fluttertoast.showToast(msg: 'Failed to ping ticket');
//           },
//               (success) {
//             Fluttertoast.showToast(msg: 'Ping sent successfully');
//             // Update last ping time
//             _lastPingTime.value = DateTime.now().toIso8601String();
//             _startPingCountdownTimer();
//             refreshTicket();
//           },
//         );
//       }
//     } catch (e) {
//       AppLogger.error('Error pinging ticket: $e');
//       Fluttertoast.showToast(msg: 'An error occurred');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   void onResolvePressed() async {
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot resolve ticket: Information is missing');
//       return;
//     }
//
//     // Show confirmation dialog
//     final confirmed = await _dialogService.showConfirmationDialog(
//       title: 'Resolve Ticket',
//       description: 'Are you sure you want to mark this ticket as resolved?',
//       confirmationTitle: 'Resolve',
//       cancelTitle: 'Cancel',
//     );
//
//     if (confirmed?.confirmed != true) return;
//
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final response = await _dialogService.showCustomDialog(
//         variant: DialogType.loader,
//         data: LoaderDialogAttributes(
//           task: () => _ticketService.resolveTicket(_ticket.value!.id!),
//         ),
//       );
//
//       if (response?.data != null) {
//         ((response?.data) as EitherResult<bool>).fold(
//               (exception) {
//             AppLogger.error('Failed to resolve ticket: ${exception.toString()}');
//             Fluttertoast.showToast(msg: 'Failed to resolve ticket');
//           },
//               (success) {
//             Fluttertoast.showToast(msg: 'Ticket resolved successfully');
//             refreshTicket();
//           },
//         );
//       }
//     } catch (e) {
//       AppLogger.error('Error resolving ticket: $e');
//       Fluttertoast.showToast(msg: 'An error occurred');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Close ticket (final state after resolved)
//   void onClosePressed() async {
//     if (_ticket.value == null || _ticket.value!.id == null) {
//       Fluttertoast.showToast(msg: 'Cannot close ticket: Information is missing');
//       return;
//     }
//
//     // Show confirmation dialog
//     final confirmed = await _dialogService.showConfirmationDialog(
//       title: 'Close Ticket',
//       description: 'Are you sure you want to close this ticket? This action cannot be undone.',
//       confirmationTitle: 'Close',
//       cancelTitle: 'Cancel',
//     );
//
//     if (confirmed?.confirmed != true) return;
//
//     _isBusy.value = true;
//     notifyListeners();
//
//     try {
//       final response = await _dialogService.showCustomDialog(
//         variant: DialogType.loader,
//         data: LoaderDialogAttributes(
//           task: () => _ticketService.closeTicket(_ticket.value!.id!),
//         ),
//       );
//
//       if (response?.data != null) {
//         ((response?.data) as EitherResult<bool>).fold(
//               (exception) {
//             AppLogger.error('Failed to close ticket: ${exception.toString()}');
//             Fluttertoast.showToast(msg: 'Failed to close ticket');
//           },
//               (success) {
//             Fluttertoast.showToast(msg: 'Ticket closed successfully');
//             _navigationService.back();
//           },
//         );
//       }
//     } catch (e) {
//       AppLogger.error('Error closing ticket: $e');
//       Fluttertoast.showToast(msg: 'An error occurred');
//     } finally {
//       _isBusy.value = false;
//       notifyListeners();
//     }
//   }
//
//   // Helper methods
//   String _formatDuration(Duration duration) {
//     if (duration.inHours >= 24) {
//       return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
//     } else {
//       return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
//     }
//   }
//
//   @override
//   void dispose() {
//     _pingTimer?.cancel();
//     _elapsedTimer?.cancel();
//     commentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   List<ReactiveServiceMixin> get reactiveServices => [];
// }
//
// // Additional model classes to support the ViewModel
//
// class TicketComment {
//   final String id;
//   final String ticketId;
//   final String userId;
//   final String userName;
//   final String userRole;
//   final String comment;
//   final String createdAt;
//   final bool isTemporary; // Used for optimistic UI updates
//
//   TicketComment({
//     required this.id,
//     required this.ticketId,
//     required this.userId,
//     required this.userName,
//     required this.userRole,
//     required this.comment,
//     required this.createdAt,
//     this.isTemporary = false,
//   });
//
//   factory TicketComment.fromJson(Map<String, dynamic> json) {
//     return TicketComment(
//       id: json['id'] ?? '',
//       ticketId: json['ticketId'] ?? '',
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? 'Unknown',
//       userRole: json['userRole'] ?? 'User',
//       comment: json['comment'] ?? '',
//       createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'ticketId': ticketId,
//       'userId': userId,
//       'userName': userName,
//       'userRole': userRole,
//       'comment': comment,
//       'createdAt': createdAt,
//     };
//   }
// }
//
// class TicketActivity {
//   final String id;
//   final String ticketId;
//   final String userId;
//   final String userName;
//   final String userRole;
//   final String activityType; // e.g., 'Created', 'Updated', 'Resolved', 'OnHold', etc.
//   final String? description;
//   final Map<String, dynamic>? metadata;
//   final String createdAt;
//
//   TicketActivity({
//     required this.id,
//     required this.ticketId,
//     required this.userId,
//     required this.userName,
//     required this.userRole,
//     required this.activityType,
//     this.description,
//     this.metadata,
//     required this.createdAt,
//   });
//
//   factory TicketActivity.fromJson(Map<String, dynamic> json) {
//     return TicketActivity(
//       id: json['id'] ?? '',
//       ticketId: json['ticketId'] ?? '',
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? 'Unknown',
//       userRole: json['userRole'] ?? 'User',
//       activityType: json['activityType'] ?? 'Unknown',
//       description: json['description'],
//       metadata: json['metadata'],
//       createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'ticketId': ticketId,
//       'userId': userId,
//       'userName': userName,
//       'userRole': userRole,
//       'activityType': activityType,
//       'description': description,
//       'metadata': metadata,
//       'createdAt': createdAt,
//     };
//   }
// }