import 'dart:io';

/// Model to hold ticket data before API submission
/// Used to pass data from dialogs to ReviewTicket screen
class PendingTicketData {
  final String? problem;
  final String? errorCode;
  final String? additionalNotes;
  final List<File>? attachments;
  final String? maintenanceType;
  final bool isFromSiteVisit;
  final String machineId;
  final String organizationId;
  final String? machineName;
  final String? modelNumber;
  final String? machineType;

  PendingTicketData({
    this.problem,
    this.errorCode,
    this.additionalNotes,
    this.attachments,
    this.maintenanceType,
    required this.isFromSiteVisit,
    required this.machineId,
    required this.organizationId,
    this.machineName,
    this.modelNumber,
    this.machineType,
  });
}
