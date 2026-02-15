import 'package:flutter/material.dart';
import 'package:manager/widgets/bottom_sheets/network_unavailable/network_unavailable_sheet.vm.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class NetworkUnavailableSheetAttributes {
  NetworkUnavailableSheetAttributes();
}

class NetworkUnavailableSheet extends StatelessWidget {
  const NetworkUnavailableSheet({
    super.key,
    required this.request,
    required this.completer,
  });

  final SheetRequest<NetworkUnavailableSheetAttributes> request;
  final Function(SheetResponse) completer;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NetworkUnavailableSheetViewModel>.reactive(
      viewModelBuilder: () => NetworkUnavailableSheetViewModel(),
      onViewModelReady:
          (NetworkUnavailableSheetViewModel model) => model.init(),
      onDispose: (NetworkUnavailableSheetViewModel model) => model.dispose(),
      builder: (
        BuildContext context,
        NetworkUnavailableSheetViewModel viewModel,
        Widget? child,
      ) {
        return Placeholder();
      },
    );
  }
}
