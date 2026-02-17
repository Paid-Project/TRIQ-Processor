// ... (previous imports)

// Paste this new widget within your create_employee_screen.dart file
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../add_employee/add_employee.vm.dart';

class CustomDepartmentDropdown extends StatefulWidget {
  final AddEmployeeViewModel viewModel;
  final bool isReadOnly;
  const CustomDepartmentDropdown({Key? key, required this.viewModel,  this.isReadOnly=true}) : super(key: key);

  @override
  State<CustomDepartmentDropdown> createState() => _CustomDepartmentDropdownState();
}

class _CustomDepartmentDropdownState extends State<CustomDepartmentDropdown> {
  final GlobalKey _fieldKey = GlobalKey();
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    // Ensure overlay is removed when the widget is disposed
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Optional: Calculate a dynamic max height based on screen space
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - offset.dy - size.height - 20; // 20 for some padding
    final maxDropdownHeight = spaceBelow > 150 ? spaceBelow : 300.0; // Use available space or max 300


    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // This correctly blocks background interaction. No changes needed here.
            ModalBarrier(
              color: Colors.transparent,
              onDismiss: _closeDropdown,
              dismissible: true,
            ),
            if(!widget.isReadOnly)
              Positioned(
                top: offset.dy + size.height,
                left: offset.dx,
                width: size.width,
                child: Material(
                  elevation: 4.0,
                  shadowColor: AppColors.gray.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(AppSizes.h12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.h8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.h12),
                    ),
                    // ✨ CHANGE 1: Add constraints to limit the dropdown's height.
                    constraints: BoxConstraints(
                      maxHeight: maxDropdownHeight, // Use the calculated height
                    ),
                    // ✨ CHANGE 2: Wrap the Column in a SingleChildScrollView to enable scrolling.
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Keep this! It's important for SingleChildScrollView
                        children: [
                          ...widget.viewModel.myDepartment.map((role) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    widget.viewModel.updateSelectedDepartment(role);
                                    _closeDropdown();
                                  },
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: AppSizes.h16, vertical: AppSizes.h12),
                                    child: Text(role.name.toUpperCase(), style: context.textTheme.titleMedium),
                                  ),
                                ),
                                Divider(height: 1, indent: AppSizes.h16, endIndent: AppSizes.h16),
                              ],
                            );
                          }).toList(),
                          // Add Custom Role Button
                          // Padding(
                          //   padding: EdgeInsets.all(AppSizes.h12),
                          //   child: OutlinedButton(
                          //     onPressed: () {
                          //       _closeDropdown();
                          //       widget.viewModel.showCreateDepartmentDialog(context);
                          //     },
                          //     style: OutlinedButton.styleFrom(
                          //       side: BorderSide(color: AppColors.primary),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(AppSizes.h45),
                          //       ),
                          //       padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                          //     ),
                          //     child: const Center(
                          //       child: Text('Add Custom Role'),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _fieldKey,
      onTap: widget.isReadOnly?null:_toggleDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.h12),
          border: Border.all(
            color: _isDropdownOpen ? AppColors.primary : AppColors.lightGrey,
            width: _isDropdownOpen ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
        (widget.viewModel.selectedDepartment?.name ?? 'Department')
            .toUpperCase(),
              style: TextStyle(
                  color: widget.viewModel.selectedDepartment?.name == null ? AppColors.textGrey : AppColors.textPrimary,
                  fontSize: 13
              ),
            ),
            Icon(
              _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}


// In your CreateEmployeeScreen -> builder method -> Employee Role Section Card:
// REPLACE the old "Designation" _FormSection with this one.

