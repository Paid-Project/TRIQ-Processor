import 'package:stacked/stacked.dart';

import 'confirmation_dialog.view.dart';


class ConfirmationDialogViewModel extends BaseViewModel {
  late String _title;
  late String _description;
  late String _cancelText;
  late String _confirmText;
  late Function()? _onCancelPressed;
  late Function()? _onConfirmPressed;
  String get title => _title;
  String get description => _description;
  String get cancelText => _cancelText;
  String get confirmText => _confirmText;

  void init(ConfirmationDialogAttributes attributes) {
    _title = attributes.title;
    _description = attributes.description;
    _cancelText = attributes.cancelText;
    _confirmText = attributes.confirmText;
    _onCancelPressed = attributes.onCancelPressed;
    _onConfirmPressed = attributes.onConfirmPressed;
  }

  void onCancel() {
    if (_onCancelPressed != null) {
      _onCancelPressed!();
    }
  }

  void onConfirm() {
    if (_onConfirmPressed != null) {
      _onConfirmPressed!();
    }
  }
}