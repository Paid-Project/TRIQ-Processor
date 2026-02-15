import 'package:flutter/material.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:manager/widgets/dialogs/network_unavailable/network_unavailable_dialog.view.dart';
import 'package:manager/widgets/dialogs/relationship_request/relationship_request_dialog.view.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/locator.dart';
import '../features/employee/widgets/employee_success_dialog.dart';
import '../widgets/dialogs/confirmation/confirmation_dialog.view.dart';
import '../widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';
import '../widgets/dialogs/machine_details/machine_details_dialog.view.dart';
import '../widgets/dialogs/resolve_request_confirmation/resolve_request_dialog.view.dart';
import '../widgets/dialogs/ticket_details/ticket_details_dialog.view.dart';
import '../widgets/dialogs/ticket_resolve/ticket_resolve.view.dart';

enum DialogType {
  networkUnavailable,
  machineDetails,
  relationshipRequest,
  loader,
  ticketDetails,
  confirmation,
  ticketResolve,
  resolveRequest,
  ticketClosed,
  success
}


setUpDialogs() {
  final Map<DialogType, DialogBuilder> bottomSheetsMap = {
    DialogType.networkUnavailable: buildDialogVariant,
    DialogType.machineDetails: buildDialogVariant,
    DialogType.loader: buildDialogVariant,
    DialogType.relationshipRequest: buildDialogVariant,
    DialogType.ticketDetails: buildDialogVariant,
    DialogType.confirmation: buildDialogVariant,
    DialogType.ticketResolve: buildDialogVariant,
    DialogType.ticketClosed: buildDialogVariant,
    DialogType.resolveRequest: buildDialogVariant,
    DialogType.success: buildDialogVariant,
  };

  final dialogService = locator<DialogService>();
  dialogService.registerCustomDialogBuilders(bottomSheetsMap);
}

Widget buildDialogVariant(
  BuildContext context,
  DialogRequest request,
  Function(DialogResponse) completer,
) {
  switch (request.variant) {
    case DialogType.networkUnavailable:
      return NetworkUnavailableDialog(request: request, completer: completer);
    case DialogType.machineDetails:
      return MachineDetailsDialog(
        request: request as DialogRequest<MachineDetailsDialogAttributes>,
        completer: completer,
      );
    case DialogType.loader:
      return LoaderDialog(
        request: request as DialogRequest<LoaderDialogAttributes>,
        completer: completer,
      );
    case DialogType.relationshipRequest:
      return RelationshipRequestDialog(
        request: request as DialogRequest<RelationshipRequestDialogAttributes>,
        completer: completer,
      );
    case DialogType.ticketDetails:
      return TicketDetailsDialog(
        request: request as DialogRequest<TicketDetailsDialogAttributes>,
        completer: completer,
      );
    case DialogType.confirmation:
      return ConfirmationDialog(
        request: request as DialogRequest<ConfirmationDialogAttributes>,
        completer: completer,
      );
    case DialogType.ticketClosed:
      return ConfirmationDialog(
        request: request as DialogRequest<ConfirmationDialogAttributes>,
        completer: completer,
      );
    case DialogType.ticketResolve:
      return TicketResolveDialog(
        request: request as DialogRequest<TicketResolveDialogAttributes>,
        completer: completer,
      );
    case DialogType.resolveRequest:
      return ResolveRequestDialog(
        request: request as DialogRequest<ResolveRequestDialogAttributes>,
        completer: completer,
      );
    case DialogType.success:
      return SuccessDialog(request: request, completer: completer);
  }
  return Dialog();
}

abstract class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.request, required this.completer});
  final DialogRequest request;
  final Function(DialogResponse) completer;
}
