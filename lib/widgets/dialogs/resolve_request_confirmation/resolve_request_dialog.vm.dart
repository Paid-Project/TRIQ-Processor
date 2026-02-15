import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'resolve_request_dialog.view.dart';

class ResolveRequestDialogViewModel extends BaseViewModel {
  late String _title;
  late String _description;
  late String _cancelText;
  late String _confirmText;
  late Function(ResolveRequestResponse)? _onCancelPressed;
  late Function(ResolveRequestResponse)? _onConfirmPressed;
  late bool _isRequired;

  final TextEditingController remarksController = TextEditingController();
  bool _hasError = false;

  bool get isSubmitDisabled => remarksController.text.isEmpty;

  String get title => _title;
  String get description => _description;
  String get cancelText => _cancelText;
  String get confirmText => _confirmText;
  bool get isRequired => _isRequired;
  bool get hasError => _hasError;

  void init(ResolveRequestDialogAttributes attributes) {
    _title = attributes.title;
    _description = attributes.description;
    _cancelText = attributes.cancelText;
    _confirmText = attributes.confirmText;
    _onCancelPressed = attributes.onCancelPressed;
    _onConfirmPressed = attributes.onConfirmPressed;
    _isRequired = attributes.isRequired;

    if (attributes.initialRemarks != null && attributes.initialRemarks!.isNotEmpty) {
      remarksController.text = attributes.initialRemarks!;
    }
  }

  void updateRemarks(String value) {
    if (_hasError && value.trim().isNotEmpty) {
      _hasError = false;
    }
    notifyListeners();
  }

  void onCancel(ResolveRequestResponse response) {
    if (_onCancelPressed != null) {
      _onCancelPressed!(response);
    }
  }

  void onConfirm(ResolveRequestResponse response) {
    if (_onConfirmPressed != null) {
      _onConfirmPressed!(response);
    }
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }
}