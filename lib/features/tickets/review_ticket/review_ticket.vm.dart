import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/core/models/review_ticket_model.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/features/tickets/tickets_list/tickets_list.vm.dart';
import 'package:manager/core/models/pending_ticket_data.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import '../../../routes/routes.dart';
import '../../../services/stage.service.dart';
import '../../stage/stage.view.dart';

class ReviewTicketViewModel extends ReactiveViewModel {
  final TextEditingController couponController = TextEditingController();
  String? appliedCoupon;
  final _navigationService = locator<NavigationService>();

  final TicketService _ticketService = locator<TicketService>();
  final ApiService _apiService = locator<ApiService>();
  final _stageService = locator<StageService>();

  ReviewTicketModel? _ticketData;
  String? _ticketId;
  PendingTicketData? _pendingTicketData;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  ReviewTicketModel? get ticketData => _ticketData;

  bool get isLoading => _isLoading;

  bool get isSubmitting => _isSubmitting;

  bool get isPendingTicket => _pendingTicketData != null;

  String? get errorMessage => _errorMessage;

  String get displayProblemDescription {
    final problem = _ticketData?.ticketDetails?.problem?.trim();
    if (problem != null && problem.isNotEmpty) {
      return problem;
    }

    if (_pendingTicketData?.isFromSiteVisit == true) {
      final pendingMaintenanceType =
          _pendingTicketData?.maintenanceType?.trim();
      if (pendingMaintenanceType != null && pendingMaintenanceType.isNotEmpty) {
        return pendingMaintenanceType;
      }
    }

    final isOfflineTicket =
        _ticketData?.ticketDetails?.type?.toLowerCase() == 'offline';
    if (isOfflineTicket) {
      final ticketType = _ticketData?.ticketDetails?.ticketType?.trim();
      if (ticketType != null && ticketType.isNotEmpty) {
        return ticketType;
      }
    }

    return LanguageService.get('no_problem_description_available');
  }

  void init({String? ticketId, PendingTicketData? pendingTicketData}) {
    _ticketId = ticketId;
    _pendingTicketData = pendingTicketData;

    if (_pendingTicketData != null) {
      // New ticket - submit first and then show API data
      _submitPendingTicketAndLoadData();
    } else if (_ticketId != null && _ticketId!.isNotEmpty) {
      // Existing ticket - load from API
      _loadTicketSummary();
    } else {
      _errorMessage = 'No ticket data provided';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _submitPendingTicketAndLoadData() async {
    // Submit ticket and load API data - wait for API response
    if (_pendingTicketData == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _pendingTicketData!;

      if (data.isFromSiteVisit) {
        // Site Visit ticket
        final formData = dio.FormData();
        formData.fields.addAll([
          MapEntry('ticketType', data.maintenanceType!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('problem', ""),
          MapEntry('errorCode', ""),
          MapEntry('notes', ""),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Offline"),
        ]);

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          _ticketId = ticketId;
          AppLogger.info('Site visit ticket created successfully: $ticketId');

          // Load full ticket summary from API
          await _loadTicketSummary();
        } else {
          _errorMessage = 'Failed to create site visit ticket';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        // Online Support ticket
        final formData = dio.FormData();

        formData.fields.addAll([
          MapEntry('problem', data.problem!),
          MapEntry('errorCode', data.errorCode!),
          MapEntry('notes', data.additionalNotes!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('ticketType', "Full Machine Service"),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Online"),
        ]);

        if (data.attachments != null && data.attachments!.isNotEmpty) {
          for (var i = 0; i < data.attachments!.length; i++) {
            final file = data.attachments![i];
            final extension = file.path.split('.').last.toLowerCase();
            final contentType =
                extension == 'png'
                    ? http_parser.MediaType('image', 'png')
                    : http_parser.MediaType('image', 'jpeg');
            formData.files.add(
              MapEntry(
                'ticketImages',
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: 'ticket_image_$i.$extension',
                  contentType: contentType,
                ),
              ),
            );
          }
        }

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          _ticketId = ticketId;
          AppLogger.info('Ticket created successfully: $ticketId');

          // Load full ticket summary from API
          await _loadTicketSummary();
        } else {
          _errorMessage = 'Failed to create ticket';
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('Error submitting ticket: $e');
      _errorMessage = 'Error creating ticket: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueToPay() async {
    // If this is a pending ticket, submit it first
    if (_pendingTicketData != null) {
      await _submitPendingTicket();
      // After submission, load the ticket summary with the created ticket ID
      if (_ticketId != null && _ticketId!.isNotEmpty) {
        await _loadTicketSummary();
      }
    } else {
      // Navigate back and refresh tickets list
      _navigationService.back();

      // Refresh the tickets list in TicketsListViewModel singleton
      final ticketsListViewModel = locator<TicketsListViewModel>();
      await ticketsListViewModel.loadTickets(forceRefresh: true);
    }
  }

  Future<void> ticketNotification() async {
    if (_isSubmitting) return;

    // Check if ticketId is available
    if (_ticketId == null || _ticketId!.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Ticket ID not available',
        backgroundColor: Colors.red,
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = {"ticketId": _ticketId};

      final response = await _apiService.post(
        url: ApiEndpoints.sendCreateNotification,
        data: data,
      );
      print("Ticket response.statusCod:- ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.info('Ticket notification sent successfully');

        // Refresh the tickets list before going back
        final ticketsListViewModel = locator<TicketsListViewModel>();
        await ticketsListViewModel.loadTickets(forceRefresh: true);
        // Get.off(()=> TicketsListView());
        // _navigationService.back();
        // _navigationService.clearStackAndShow(
        //   Routes.ticketsSummary,
        //   // arguments: ticketId,
        // );
        // _stageService.updateSelectedBottomNavIndex(1);

        Fluttertoast.showToast(
          msg: response.data["message"] ?? "Notification sent",
          backgroundColor: Colors.green,
        );

        // Always land on Tickets Summary after Continue.
        _stageService.updateSelectedBottomNavIndex(1);
        await _navigationService.replaceWith(
          Routes.stage,
          arguments: StageViewAttributes(selectedBottomNavIndex: 1),
        );
      } else {
        AppLogger.error('Failed to send notification: ${response.statusCode}');
        // _navigationService.clearStackAndShow(
        //   Routes.ticketsSummary,
        //   // arguments: ticketId,
        // );
        // Navigate back
        _navigationService.back();
        // Get.off(()=> TicketsListView());
        // Fluttertoast.showToast(
        //   msg: response.data["message"] ?? "Failed to send notification",
        //   backgroundColor: Colors.red,
        // );
      }
    } catch (e) {
      AppLogger.error("Ticket notification error: $e");
      Fluttertoast.showToast(
        msg: "Something went wrong: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // CreateTicketModel? createDatas;
  Future<void> _submitPendingTicket() async {
    if (_pendingTicketData == null) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = _pendingTicketData!;

      if (data.isFromSiteVisit) {
        // Site Visit ticket
        final formData = dio.FormData();
        formData.fields.addAll([
          MapEntry('ticketType', data.maintenanceType!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('problem', ""),
          MapEntry('errorCode', ""),
          MapEntry('notes', ""),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Offline"),
        ]);

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          _ticketId = ticketId;
          AppLogger.info('Site visit ticket created successfully: $ticketId');

          // Update ticket data with response and pending data
          _updateTicketDataFromResponse(response.data, ticketId);
        } else {
          AppLogger.error('Failed to create site visit ticket');
          Fluttertoast.showToast(
            msg: 'Failed to create ticket',
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Online Support ticket
        final formData = dio.FormData();

        formData.fields.addAll([
          MapEntry('problem', data.problem!),
          MapEntry('errorCode', data.errorCode!),
          MapEntry('notes', data.additionalNotes!),
          MapEntry('machineId', data.machineId),
          MapEntry('organisationId', data.organizationId),
          MapEntry('ticketType', "Full Machine Service"),
          MapEntry('paymentStatus', "unpaid"),
          MapEntry('type', "Online"),
        ]);

        for (var i = 0; i < data.attachments!.length; i++) {
          final file = data.attachments![i];
          final extension = file.path.split('.').last.toLowerCase();
          final contentType =
              extension == 'png'
                  ? http_parser.MediaType('image', 'png')
                  : http_parser.MediaType('image', 'jpeg');
          formData.files.add(
            MapEntry(
              'ticketImages',
              await dio.MultipartFile.fromFile(
                file.path,
                filename: 'ticket_image_$i.$extension',
                contentType: contentType,
              ),
            ),
          );
        }

        final response = await _apiService.post(
          url: ApiEndpoints.createTicket,
          data: formData,
        );

        if (response.statusCode == 201 && response.data['ticket'] != null) {
          final ticketId = response.data['ticket']['_id'];
          _ticketId = ticketId;
          AppLogger.info('Ticket created successfully: $ticketId');

          // Update ticket data with response and pending data
          _updateTicketDataFromResponse(response.data, ticketId);
        } else {
          AppLogger.error('Failed to create ticket');
          Fluttertoast.showToast(
            msg: 'Failed to create ticket',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error submitting ticket: $e');
      _errorMessage = 'Error creating ticket: ${e.toString()}';
      Fluttertoast.showToast(
        msg: 'Error creating ticket: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _updateTicketDataFromResponse(
    Map<String, dynamic> responseData,
    String ticketId,
  ) {
    try {
      final ticket = responseData['ticket'];
      if (ticket == null) return;

      // Create ReviewTicketModel from response and pending data
      _ticketData = ReviewTicketModel(
        processorDetails: Details(
          fullName: 'Pending Submission',
          id: _pendingTicketData?.organizationId ?? '',
        ),
        ticketDetails: TicketDetails(
          id: ticketId,
          type: _pendingTicketData!.isFromSiteVisit ? 'Offline' : 'Online',
          status: ticket['status'] ?? 'Pending',
          createdAt:
              ticket['createdAt'] != null
                  ? DateTime.parse(ticket['createdAt'])
                  : DateTime.now(),
          problem: _pendingTicketData!.problem ?? ticket['problem'] ?? '',
          errorCode: _pendingTicketData!.errorCode ?? ticket['errorCode'] ?? '',
          notes: _pendingTicketData!.additionalNotes ?? ticket['notes'] ?? '',
          media:
              ticket['ticketImages'] != null
                  ? (ticket['ticketImages'] as List)
                      .map(
                        (img) => Media(
                          url:
                              img is String
                                  ? img
                                  : img['url'] ?? img['path'] ?? '',
                          type: 'image',
                          id: img is Map ? img['_id'] : null,
                        ),
                      )
                      .toList()
                  : [],
          ticketType:
              _pendingTicketData!.maintenanceType ??
              ticket['ticketType'] ??
              'Full Machine Service',
        ),
        customerMachineDetails: CustomerMachineDetails(
          warrantyStatus: 'Unknown',
          machine: ticket['machineId'] ?? _pendingTicketData!.machineId,
        ),
        machineDetails: MachineDetails(
          machineName: _pendingTicketData!.machineName ?? 'Machine',
          modelNumber: _pendingTicketData!.modelNumber ?? 'N/A',
          id: ticket['machineId'] ?? _pendingTicketData!.machineId,
        ),
        pricingDetails: PricingDetails(cost: 0, currency: 'USD'),
      );

      _isLoading = false;
      _isSubmitting = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error updating ticket data from response: $e');
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _loadTicketSummary() async {
    if (_ticketId == null) return;

    setBusy(true);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ticketService.getTicketSummary(ticketId: _ticketId!);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _ticketData = data;
        _isLoading = false;
        notifyListeners();
      },
    );

    setBusy(false);
  }

  void applyCoupon() {
    final couponCode = couponController.text.trim();
    if (couponCode.isNotEmpty) {
      appliedCoupon = couponCode;
      couponController.clear();
      notifyListeners();

      Fluttertoast.showToast(
        msg: LanguageService.get('coupon_applied_successfully'),
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        msg: LanguageService.get('please_enter_coupon_code'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void removeCoupon() {
    appliedCoupon = null;
    notifyListeners();

    Fluttertoast.showToast(
      msg: LanguageService.get('coupon_removed'),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void refreshTicketsListInBackground() {
    // Refresh tickets list in background
    Future.delayed(Duration(milliseconds: 300), () async {
      try {
        final ticketsListViewModel = locator<TicketsListViewModel>();
        await ticketsListViewModel.loadTickets(forceRefresh: true);
      } catch (e) {
        AppLogger.error('Error refreshing tickets list: $e');
      }
    });
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}
