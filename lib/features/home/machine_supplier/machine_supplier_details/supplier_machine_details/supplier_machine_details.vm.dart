import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/pending_ticket_data.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:stacked_services/stacked_services.dart';

class SupplierMachineDetailsViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();

  String? _machineId;
  String? _organizationId;

  void init(String machineId, String organizationId) {
    _machineId = machineId;
    _organizationId = organizationId;
  }

  Future<void> createTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
  }) async {
    if (_machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(msg: 'Machine ID not found', backgroundColor: Colors.red);
      return;
    }

    if (_organizationId == null) {
      AppLogger.error('Organization ID is null');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    // Create pending ticket data and navigate to ReviewTicket
    final pendingTicketData = PendingTicketData(
      problem: problem,
      errorCode: errorCode,
      additionalNotes: additionalNotes,
      attachments: attachments,
      maintenanceType: maintenanceType,
      isFromSiteVisit: isFromSiteVisit,
      machineId: _machineId!,
      organizationId: _organizationId!,
    );

    await _navigationService.navigateTo(
      Routes.reviewTicket,
      arguments: pendingTicketData,
    );
  }
}
