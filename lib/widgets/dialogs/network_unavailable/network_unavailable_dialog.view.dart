import 'package:flutter/material.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:stacked/stacked.dart';

import 'network_unavailable_dialog.vm.dart';

class NetworkUnavailableDialog extends AppDialog {
  const NetworkUnavailableDialog({
    super.key,
    required super.request,
    required super.completer,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NetworkUnavailableDialogViewModel>.reactive(
      viewModelBuilder: () => NetworkUnavailableDialogViewModel(),
      onViewModelReady:
          (NetworkUnavailableDialogViewModel model) => model.init(),
      onDispose: (NetworkUnavailableDialogViewModel model) => model.dispose(),
      builder: (
        BuildContext context,
        NetworkUnavailableDialogViewModel viewModel,
        Widget? child,
      ) {
        return Placeholder();
      },
    );
  }
}
