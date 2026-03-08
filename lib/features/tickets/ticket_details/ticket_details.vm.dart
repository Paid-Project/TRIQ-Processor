import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/ticket_details_model.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../api_endpoints.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/api.service.dart';

class TicketDetailsViewModel extends BaseViewModel {
  final TicketService _ticketService = locator<TicketService>();
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();

  TicketDetailsModel? _ticketDetails;
  String? _errorMessage;
  String? _ticketId;

  // Getters
  TicketDetailsModel? get ticketDetails => _ticketDetails;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isLoading => isBusy;

  String rescheduleTime = '';
  final formKey = GlobalKey<FormState>();

  // Initialize the view model with ticket ID
  void init({String? ticketId}) {
    _ticketId = ticketId;
    if (ticketId != null) {
      fetchTicketDetails();
    }
  }

  // Fetch ticket details from API
  Future<void> fetchTicketDetails() async {
    print("-------hellohellooo1111--------------${_ticketId}");

    if (_ticketId == null) return;
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    final result = await _ticketService.getTicketDetails(ticketId: _ticketId!);

print("-------hellohellooo--------------${result}");
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        setBusy(false);
        notifyListeners();
      },
      (ticketDetails) {
        _ticketDetails = ticketDetails;
        _errorMessage = null;
        setBusy(false);
        notifyListeners();
      },
    );
  }

  // Refresh ticket details
  Future<void> refreshTicketDetails() async {
    await fetchTicketDetails();
  }

  // Start chat functionality
  void startChat(BuildContext context) async {
    if (_ticketDetails == null) return;

    final ticketNumber = _ticketDetails!.ticketDetails?.ticketNumber ?? 'Unknown';
    final chatWithName = _ticketDetails!.processorDetails?.fullName?.toString().capitalizeWords  ?? 'Customer';
    final contactInitials = chatWithName.isNotEmpty ? chatWithName.substring(0, 1).toUpperCase() : 'U';
    final roomId = _ticketDetails!.chatRoom?.id ?? '';
    final ticketStatus = _ticketDetails!.ticketDetails?.status ?? '';
    final userRole = _ticketDetails?.role;
print("object1111111:- ${ ticketDetails?.ticketDetails?.status?.toLowerCase() }");
    // Navigate to chat screen and wait for result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatView(
              contactName: chatWithName,
              contactNumber: ticketNumber,
              updatedAt:  ticketDetails?.ticketDetails?.status?.toLowerCase() == "resolved" ?_ticketDetails!.ticketDetails!.createdAt?.formatReadableDate():_ticketDetails!.ticketDetails!.resolvedAt?.formatReadableDate(),
              contactInitials: contactInitials,
              roomId: roomId,
              ticketId: _ticketId,

              ticketStatus: ticketStatus,
              userRole: userRole,
            ),
      ),
    );

    // If ticket was resolved, refresh the ticket details
    if (result == true) {
      await refreshTicketDetails();
    }
  }

  // Reschedule functionality
  Future<void> rescheduleTicket(BuildContext context) async {
    final body = {'reschedule_time': rescheduleTime};

    final response = await _apiService.put(url: "${ApiEndpoints.updateTicket}/${_ticketId ?? ""}", data: body);

    if (response.statusCode == 200) {
      fetchTicketDetails();
      AppLogger.info('Site visit ticket created successfully: ${response.data['ticket']['_id']}');
      Fluttertoast.showToast(msg: response.data["message"] ?? 'Reschedule successfully!', backgroundColor: Colors.green);
    } else {
      AppLogger.error('Failed to Reschedule');
      Fluttertoast.showToast(msg: 'Failed to Reschedule', backgroundColor: Colors.green);
    }
  }

  // Get formatted date string
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;

    return '$month $day, $year';
  }

  // Get formatted currency string
  String formatCurrency(int? amount, String? currency) {
    if (amount == null) return 'N/A';
    final currencySymbol = currency == 'USD' ? '\$' : '₹';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  // Get status color
  String getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'resolved':
        return 'Resolved';
      case 'onhold':
        return 'On Hold';
      default:
        return status ?? 'Unknown';
    }
  }

  // Get warranty status color
  String getWarrantyStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in warranty':
        return 'In warranty';
      case 'out of warranty':
        return 'Out Of Warranty';
      case 'expired':
        return 'Expired';
      default:
        return status ?? 'Unknown';
    }
  }

  // Submit problem report
  Future<void> submitProblemReport(String title, String description) async {
    if (_ticketId == null) {
      Fluttertoast.showToast(
        msg: 'Invalid ticket ID',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          final apiResponse = await _apiService.post(url: 'ticket/report/$_ticketId', data: {'reportTitle': title, 'reportDescription': description});
          return apiResponse;
        },
      ),
    );

    if (response?.confirmed == true) {
      Fluttertoast.showToast(
        msg: 'Report submitted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      AppLogger.error('Error submitting report: ${response?.data}');
      Fluttertoast.showToast(
        msg: 'Failed to submit report. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Submit problem report
  Future<void> submitRating(int rating, String feedback) async {
    if (_ticketId == null) {
      Fluttertoast.showToast(
        msg: 'Invalid ticket ID',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          final apiResponse = await _apiService.post(url: 'ticket/rateFeedback/$_ticketId', data: {'rating': rating, 'feedback': feedback});
          return apiResponse;
        },
      ),
    );

    if (response?.confirmed == true) {
      Fluttertoast.showToast(
        msg: 'Feedback and Rating submitted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      AppLogger.error('Error submitting report: ${response?.data}');
      Fluttertoast.showToast(
        msg: 'Failed to submit report. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
