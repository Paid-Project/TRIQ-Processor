import 'package:flutter/material.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<Machine> items;
  final List<Machine> selectedItems;
  final String label;
  final bool canSelectNone;
  final Function(List<Machine>) onSelectionChanged;
  final Widget Function(Machine) itemBuilder;
  final String? Function(List<Machine>?)? validator;

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.label,
    this.canSelectNone = true,
    required this.onSelectionChanged,
    required this.itemBuilder,
    this.validator,
  }) : super(key: key);

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  // Local copy of selected items to manage internal state
  late List<Machine> _localSelectedItems;

  @override
  void initState() {
    super.initState();
    _localSelectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if parent widget selection changes
    if (widget.selectedItems != oldWidget.selectedItems) {
      _localSelectedItems = List.from(widget.selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown button
        InkWell(
          onTap: () => _showMachineSelectionSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray),
              borderRadius: BorderRadius.circular(AppSizes.v12),
              color: AppColors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedItems.isEmpty
                        ? widget.label
                        : "${widget.selectedItems.length} ${LanguageService.get("machine")} ${widget.selectedItems.length > 1 ? 's' : ''} ${LanguageService.get("selected")}",
                    style: TextStyle(
                      color:
                          widget.selectedItems.isEmpty
                              ? AppColors.gray
                              : AppColors.black,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ],
            ),
          ),
        ),

        // Selected machines chips
        if (widget.selectedItems.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.selectedItems
                      .map(
                        (machine) => Chip(
                          label: Text(
                            machine.machineName ?? 'Unknown',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          deleteIconColor: AppColors.white,
                          onDeleted: () {
                            _toggleMachineSelection(machine, false);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }

  void _toggleMachineSelection(Machine machine, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_localSelectedItems.contains(machine)) {
          _localSelectedItems.add(machine);
        }
      } else {
        _localSelectedItems.remove(machine);
      }

      // Update parent widget
      widget.onSelectionChanged(_localSelectedItems);
    });
  }

  void _showMachineSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LanguageService.get("select_machine"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),

                  // Machine list
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.items.length,
                      separatorBuilder:
                          (_, __) =>
                              Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final machine = widget.items[index];
                        final isSelected = _localSelectedItems.contains(
                          machine,
                        );

                        return InkWell(
                          onTap: () {
                            setState(() {
                              // Update both the local bottom sheet state
                              if (isSelected) {
                                _localSelectedItems.remove(machine);
                              } else {
                                _localSelectedItems.add(machine);
                              }

                              // Update the parent widget
                              widget.onSelectionChanged(_localSelectedItems);
                            });
                          },
                          child: _buildMachineItem(
                            machine: machine,
                            isSelected: isSelected,
                            onToggle: (selected) {
                              setState(() {
                                // Update both the local bottom sheet state
                                if (selected) {
                                  if (!_localSelectedItems.contains(machine)) {
                                    _localSelectedItems.add(machine);
                                  }
                                } else {
                                  _localSelectedItems.remove(machine);
                                }

                                // Update the parent widget
                                widget.onSelectionChanged(_localSelectedItems);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: Offset(0, -1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Selected count
                        Text(
                          "${_localSelectedItems.length} ${LanguageService.get("selected")}",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            // Clear button
                            if (widget.canSelectNone)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _localSelectedItems.clear();
                                    widget.onSelectionChanged(
                                      _localSelectedItems,
                                    );
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                                child: Text(LanguageService.get("clear_all")),
                              ),
                            SizedBox(width: 8),
                            // Done button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(LanguageService.get("done")),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMachineItem({
    required Machine machine,
    required bool isSelected,
    required Function(bool) onToggle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onToggle(value ?? false),
              activeColor: AppColors.white,
              side: BorderSide(
                width: 2,
                color: AppColors.primary,
              ), // Make border more visible
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  4.0,
                ), // Slightly rounded corners
              ),
            ),
            //   Checkbox(
            //   value: isSelected,
            //   onChanged: (value) => onToggle(value ?? false),
            // ),
          ),
          SizedBox(width: 12),

          // Machine details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Machine name
                Text(
                  machine.machineName ?? 'Unknown Machine',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),

                // Machine basic info
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.tag,
                      machine.serialNumber ?? machine.modelNumber ?? 'No M/N',
                    ),
                    if (machine.status != null)
                      _buildInfoChip(
                        Icons.info_outline,
                        machine.status!,
                        color: _getStatusColor(machine.status!),
                      ),
                    if (machine.department != null)
                      _buildInfoChip(Icons.business, machine.department!),
                  ],
                ),
                SizedBox(height: 8),

                // Location
                if (machine.location != null) ...[
                  _buildInfoSection(LanguageService.get("location"), [
                    if (machine.location!.building != null)
                      "${LanguageService.get('building')}: ${machine.location!.building}",
                    if (machine.location!.floor != null)
                      "${LanguageService.get('floor')}: ${machine.location!.floor}",
                    if (machine.location!.room != null)
                      "${LanguageService.get('room')}: ${machine.location!.room}",
                  ]),
                  SizedBox(height: 4),
                ],

                // Operating hours
                if (machine.operatingHours != null)
                  Text(
                    "${LanguageService.get('operating_hours')}: ${machine.operatingHours} hrs",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? AppColors.primary),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color ?? AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    if (details.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        ...details.map(
          (detail) => Text(
            detail,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'operational':
      case 'running':
        return Colors.green;
      case 'maintenance':
      case 'servicing':
        return Colors.orange;
      case 'offline':
      case 'down':
      case 'error':
        return Colors.red;
      case 'standby':
      case 'idle':
        return Colors.blue;
      default:
        return AppColors.gray;
    }
  }
}
