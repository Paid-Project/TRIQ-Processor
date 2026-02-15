import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/machine_overview_details_model.dart';
import 'package:manager/core/models/pending_ticket_data.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/routes/routes.dart';
import 'dart:io';

class MachineOverviewDetailsViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();

  MachineOverviewDetailsModel? _machineDetails;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _machineId;
  String? _organizationId;
  bool _hasChanges = false;

  MachineOverviewDetailsModel? get machineDetails => _machineDetails;

  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  bool get hasChanges => _hasChanges;

  void init(String machineId, String organizationId) {
    _machineId = machineId;
    _organizationId = organizationId;
    _loadMachineDetails();
  }

  Future<void> _loadMachineDetails() async {
    if (_machineId == null) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await _apiService.get(
        url: '${ApiEndpoints.getMachineById}/$_machineId',
      );

      if (response.statusCode == 200) {
        _machineDetails = MachineOverviewDetailsModel.fromJson(response.data);
      } else {
        _hasError = true;
        _errorMessage = 'Failed to load machine details. Please try again.';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshMachineDetails() async {
    await _loadMachineDetails();
  }

  bool get hasProcessingDimensions =>
      _machineDetails?.processingDimensions != null;

  ProcessingDimensions? get processingDimensions =>
      _machineDetails?.processingDimensions;

  void markAsChanged() {
    _hasChanges = true;
    notifyListeners();
  }

  Future<void> createTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
    Function()? onSucess,
  }) async {
    if (_machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(
        msg: 'Machine ID not found',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_organizationId == null || _organizationId!.isEmpty) {
      AppLogger.error('Organization ID is null or empty');
      Fluttertoast.showToast(
        msg: 'Organization ID not found',
        backgroundColor: Colors.red,
      );
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
      machineName: _machineDetails?.machineName,
      modelNumber: _machineDetails?.modelNumber,
      machineType: _machineDetails?.machineType,
    );

    if (onSucess != null) {
      onSucess();
    }

    await _navigationService.navigateTo(
      Routes.reviewTicket,
      arguments: pendingTicketData,
    );
  }
}
