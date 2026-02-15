import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 'Get.find()' ke liye zaroori
import 'package:manager/features/employee/add_employee/add_employee.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart'; // 'ViewModelBuilder' ke liye zaroori

import '../../../core/models/employee.dart'; // 'Permissions' model ke liye

// Yeh widget poori tarah se reusable hai (Ise neeche move kar diya hai)
class PermissionMatrixWidget extends StatelessWidget {

  final Permissions permissions;
  final Function(PermissionType, PermissionAccess, bool?)? onPermissionChanged;
  final bool isReadOnly;

  const PermissionMatrixWidget({
    Key? key,
    required this.permissions,
    this.onPermissionChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Yeh important hai
        children: [
          const Text(
            'System Access & Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          const SizedBox(height: 16),
          // Header Row
          Row(
            children: const [
              Expanded(child: SizedBox()),
              SizedBox(width: 70, child: Center(child: Text('View', style: TextStyle(fontWeight: FontWeight.w600)))),
              SizedBox(width: 70, child: Center(child: Text('Read & Edit', style: TextStyle(fontWeight: FontWeight.w600)))),
            ],
          ),
          const Divider(),
          // Permission Rows
          _PermissionRow(
            label: 'Service Department',
            viewValue: permissions.serviceDepartment?.view ?? false,
            editValue: permissions.serviceDepartment?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.serviceDepartment, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.serviceDepartment, PermissionAccess.edit, value),
          ),
          _PermissionRow(
            label: 'Access Level',
            viewValue: permissions.accessLevel?.view ?? false,
            editValue: permissions.accessLevel?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.accessLevel, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.accessLevel, PermissionAccess.edit, value),
          ),
          _PermissionRow(
            label: 'Machine Operation Permissions',
            viewValue: permissions.machineOperation?.view ?? false,
            editValue: permissions.machineOperation?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.machineOperation, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.machineOperation, PermissionAccess.edit, value),
          ),
          _PermissionRow(
            label: 'Ticket Management Rights',
            viewValue: permissions.ticketManagement?.view ?? false,
            editValue: permissions.ticketManagement?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.ticketManagement, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.ticketManagement, PermissionAccess.edit, value),
          ),
          _PermissionRow(
            label: 'Approval Authority',
            viewValue: permissions.approvalAuthority?.view ?? false,
            editValue: permissions.approvalAuthority?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.approvalAuthority, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.approvalAuthority, PermissionAccess.edit, value),
          ),
          _PermissionRow(
            label: 'Report Access',
            viewValue: permissions.reportAccess?.view ?? false,
            editValue: permissions.reportAccess?.edit ?? false,
            isReadOnly: isReadOnly,
            onViewChanged: (value) => onPermissionChanged?.call(PermissionType.reportAccess, PermissionAccess.view, value),
            onEditChanged: (value) => onPermissionChanged?.call(PermissionType.reportAccess, PermissionAccess.edit, value),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {

  final String label;
  final bool viewValue;
  final bool editValue;
  final bool isReadOnly;
  final ValueChanged<bool?> onViewChanged;
  final ValueChanged<bool?> onEditChanged;

  const _PermissionRow({
    Key? key,
    required this.label,
    required this.viewValue,
    required this.editValue,
    required this.isReadOnly,
    required this.onViewChanged,
    required this.onEditChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),),
          SizedBox(
            width: 70,
            child: Center(
              child: Checkbox(
                value: viewValue,
                onChanged: isReadOnly ? (_) {}  : onViewChanged,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                activeColor: context.theme.primaryColor,
                checkColor: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Center(
              child: Checkbox(
                value: editValue,
                onChanged: isReadOnly ? (_) {}   : onEditChanged,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                activeColor: context.theme.primaryColor,
                checkColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemAccessPermissionsView extends StatefulWidget {
  final bool isReadOnly;
  final Permissions initialPermissions;

  const SystemAccessPermissionsView({
    Key? key,
    required this.isReadOnly,
    required this.initialPermissions,
  }) : super(key: key);

  @override
  State<SystemAccessPermissionsView> createState() => _SystemAccessPermissionsViewState();
}

class _SystemAccessPermissionsViewState extends State<SystemAccessPermissionsView> {
  late Permissions _currentPermissions;

  @override
  void initState() {
    super.initState();

    // Deep copy the initial permissions
    _currentPermissions = widget.initialPermissions;
    print("=== PERMISSION SCREEN INIT ===");
    print("Initial permissions received:");
    print("Raw JSON: ${widget.initialPermissions.toJson()}");
    print("Service Dept: view=${widget.initialPermissions.serviceDepartment?.view}, edit=${widget.initialPermissions.serviceDepartment?.edit}");
    print("Access Level: view=${widget.initialPermissions.accessLevel?.view}, edit=${widget.initialPermissions.accessLevel?.edit}");
    print("Machine Op: view=${widget.initialPermissions.machineOperation?.view}, edit=${widget.initialPermissions.machineOperation?.edit}");
    print("Ticket Mgmt: view=${widget.initialPermissions.ticketManagement?.view}, edit=${widget.initialPermissions.ticketManagement?.edit}");
    print("Approval Auth: view=${widget.initialPermissions.approvalAuthority?.view}, edit=${widget.initialPermissions.approvalAuthority?.edit}");
    print("Report Access: view=${widget.initialPermissions.reportAccess?.view}, edit=${widget.initialPermissions.reportAccess?.edit}");

    // Deep copy the initial permissions
    _currentPermissions = widget.initialPermissions;

    print("After assignment, _currentPermissions:");
    print("Service Dept: view=${_currentPermissions.serviceDepartment?.view}, edit=${_currentPermissions.serviceDepartment?.edit}");
    // Force a setState after a frame to ensure UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _updatePermission(PermissionType type, PermissionAccess access, bool? value) {
    if (value == null || widget.isReadOnly) return;

    setState(() {
      switch (type) {
        case PermissionType.serviceDepartment:
          final current = _currentPermissions.serviceDepartment ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            serviceDepartment: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
        case PermissionType.accessLevel:
          final current = _currentPermissions.accessLevel ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            accessLevel: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
        case PermissionType.machineOperation:
          final current = _currentPermissions.machineOperation ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            machineOperation: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
        case PermissionType.ticketManagement:
          final current = _currentPermissions.ticketManagement ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            ticketManagement: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
        case PermissionType.approvalAuthority:
          final current = _currentPermissions.approvalAuthority ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            approvalAuthority: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
        case PermissionType.reportAccess:
          final current = _currentPermissions.reportAccess ?? PermissionDetail.initial();
          _currentPermissions = _currentPermissions.copyWith(
            reportAccess: current.copyWith(
              view: access == PermissionAccess.view ? value : current.view,
              edit: access == PermissionAccess.edit ? value : current.edit,
            ),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!widget.isReadOnly) {
          // Return the updated permissions when going back
          Navigator.pop(context, _currentPermissions);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            widget.isReadOnly
                ? LanguageService.get('edit_permission'):
            LanguageService.get('add_permission'),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primaryDark],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                stops: const [0.08, 1],
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (!widget.isReadOnly) {
                Navigator.pop(context, _currentPermissions);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: PermissionMatrixWidget(
            permissions: _currentPermissions,
            onPermissionChanged: widget.isReadOnly ? null : _updatePermission,
            isReadOnly: widget.isReadOnly,
          ),
        ),
      ),
    );
  }
}