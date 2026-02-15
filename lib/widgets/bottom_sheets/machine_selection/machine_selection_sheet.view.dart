import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

// Define the attributes for the machine selection bottom sheet
class MachineSelectionSheetAttributes {
  final List<Machine> availableMachines;
  final List<String> selectedMachineIds;

  MachineSelectionSheetAttributes({
    required this.availableMachines,
    required this.selectedMachineIds,
  });
}

// Create the bottom sheet widget
class MachineSelectionBottomSheet extends StatefulWidget {
  final SheetRequest<MachineSelectionSheetAttributes> request;
  final Function(SheetResponse) completer;

  const MachineSelectionBottomSheet({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  _MachineSelectionBottomSheetState createState() => _MachineSelectionBottomSheetState();
}

class _MachineSelectionBottomSheetState extends State<MachineSelectionBottomSheet> {
  late List<String> _selectedMachineIds;

  @override
  void initState() {
    super.initState();
    // Initialize with the already selected machine IDs
    _selectedMachineIds = List.from(widget.request.data!.selectedMachineIds);
  }

  @override
  Widget build(BuildContext context) {
    final availableMachines = widget.request.data!.availableMachines;

    return Container(
      padding: EdgeInsets.all(AppSizes.w20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.v20),
          topRight: Radius.circular(AppSizes.v20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageService.get("select_machines"),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.gray),
                onPressed: () => widget.completer(SheetResponse(confirmed: false)),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h10),

          // If no machines available, show a message
          if (availableMachines.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.w16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.v12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Text(
                LanguageService.get("all_machines_assigned_unavailable"),
                style: TextStyle(
                  color: AppColors.gray,
                  fontSize: AppSizes.v14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableMachines.length,
                itemBuilder: (context, index) {
                  final machine = availableMachines[index];
                  final isSelected = _selectedMachineIds.contains(machine.id);

                  return CheckboxListTile(
                    title: Text(
                      machine.machineName ?? 'Unknown Machine',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      machine.modelNumber ?? 'No model number',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: AppSizes.v12,
                      ),
                    ),
                    value: isSelected,
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (!_selectedMachineIds.contains(machine.id)) {
                            _selectedMachineIds.add(machine.id!);
                          }
                        } else {
                          _selectedMachineIds.remove(machine.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),

          SizedBox(height: AppSizes.h20),

          // Add confirm button at the bottom
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
              ),
              onPressed: () {
                widget.completer(
                  SheetResponse(
                    confirmed: true,
                    data: _selectedMachineIds,
                  ),
                );
              },
              child: Text(
                LanguageService.get("confirm_selection"),
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}