import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/services/machine.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MachineDetailsDialogViewModel extends BaseViewModel {
  final _machineService = locator<MachineService>();

  Machine? _machine;
  Machine? get machine => _machine;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void loadMachineDetails({required String machineId,String? processorId}) async {
    setBusy(true);
    final result = await _machineService.getMachineById(machineId:machineId,processorId: processorId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (machineData) {
        _machine = machineData;
        notifyListeners();
      },
    );

    setBusy(false);
  }

  String formatDimensions(Dimensions? dimensions) {
    if (dimensions == null) return 'N/A';

    final width = dimensions.width;
    final height = dimensions.height;
    final depth = dimensions.depth;
    final unit = dimensions.unit ?? 'cm';

    if (width != null && height != null && depth != null) {
      return '$height × $width $unit';
    } else {
      // Return partial dimensions if some are missing
      final parts = <String>[];
      if (height != null) parts.add('H: $height $unit');
      if (width != null) parts.add('W: $width $unit');

      return parts.isEmpty ? 'N/A' : parts.join(', ');
    }
  }

  String formatPowerRequirements(PowerRequirements? power) {
    if (power == null) return 'N/A';

    final powerConsumption = power.powerConsumption;
    if (powerConsumption != null) {
      return '$powerConsumption Kw';
    }

    // Fallback to voltage/amperage if available
    // final voltage = power.voltage;
    // final amperage = power.amperage;

    // if (voltage != null && amperage != null) {
    //   return '$voltage V, $amperage A';
    // } else if (voltage != null) {
    //   return '$voltage V';
    // } else if (amperage != null) {
    //   return '$amperage A';
    // }

    return 'N/A';
  }

  String formatWeight(Weight? weight) {
    if (weight == null) return 'N/A';

    final value = weight.value;
    final unit = weight.unit ?? 'kg';

    if (value != null) {
      return '$value $unit';
    }

    return 'N/A';
  }

  // void showDeleteConfirmation(
  //   BuildContext context, {
  //   required String machineId,
  //   required String machineName,
  //   required Function(BuildContext, {required String machineId})
  //   onRemovePressed,
  //   required Function(DialogResponse) completer,
  // }) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (dialogContext) => AlertDialog(
  //           title: Text('Delete Machine'),
  //           content: Text('Are you sure you want to delete $machineName?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(dialogContext),
  //               child: Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(dialogContext); // Close confirmation dialog
  //                 Navigator.pop(context); // Close machine details dialog
  //                 onRemovePressed(context, machineId: machineId);
  //                 completer(DialogResponse(confirmed: true));
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.red,
  //                 foregroundColor: Colors.white,
  //               ),
  //               child: Text('Delete'),
  //             ),
  //           ],
  //         ),
  //   );
  // }
  void showDeleteConfirmation(
      BuildContext context, {
        required String machineId,
        required String machineName,
        required Function(BuildContext, {required String machineId}) onRemovePressed,
        required Function(DialogResponse) completer,
      }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Machine'),
        content: Text('Are you sure you want to delete $machineName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              onRemovePressed(context, machineId: machineId);
              completer(DialogResponse(confirmed: true));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
