import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/ticket.dart';
import 'package:manager/services/ticket.service.dart';

class TicketResolveDialogViewModel extends ChangeNotifier {
  final _ticketService = locator<TicketService>();

  Ticket? _ticket;
  Ticket? get ticket => _ticket;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void init(String ticketId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _ticketService.getTicketById(id: ticketId);

      response.fold(
            (exception) {
          _errorMessage = exception.message.toString();
          _isLoading = false;
          notifyListeners();
        },
            (ticketData) {
          _ticket = ticketData;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to load ticket: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}