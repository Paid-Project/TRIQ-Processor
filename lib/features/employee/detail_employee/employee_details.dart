import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../core/models/employee.dart'; // Naya model yahan import hoga
import '../../../services/language.service.dart';
import 'employee_details.vm.dart';

// import '../add_employee/add_employee.view.dart'; // Agar 'model.onEditEmployee' me use ho raha hai to ise uncomment karein

// EmployeeDetailsViewAttributes class me koi change nahi hai

class EmployeeDetailsViewAttributes {
  final String employeeId;

  EmployeeDetailsViewAttributes({required this.employeeId});

  factory EmployeeDetailsViewAttributes.fromJson(Map<String, String> json) {
    return EmployeeDetailsViewAttributes(employeeId: json['employeeId'] ?? '');
  }

  Map<String, String> toJson() {
    return {'employeeId': employeeId};
  }
}

class EmployeeDetailsView extends StatelessWidget {
  const EmployeeDetailsView({super.key, required this.attributes});

  final EmployeeDetailsViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EmployeeDetailsViewModel>.reactive(
      viewModelBuilder: () => EmployeeDetailsViewModel(),
      onViewModelReady: (model) => model.init(attributes),
      builder: (
        BuildContext context,
        EmployeeDetailsViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildCustomAppBar(context, model),
          body: SafeArea(
            child:
                model.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : model.employee == null
                    ? Center(
                      child: Text(LanguageService.get('employee_not_found')),
                    )
                    : _buildEmployeeDetailsContent(context, model),
          ),
          floatingActionButton:
              model.employee != null
                  ? FloatingActionButton(
                    onPressed: () => model.onEditEmployee(context),
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.edit, color: AppColors.white),
                  )
                  : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
    BuildContext context,
    EmployeeDetailsViewModel model,
  ) {
    // Is widget me koi badlaav nahi hai
    return AppBar(
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        "",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (model.employee != null)
          PopupMenuButton<String>(
            onSelected: (value) => model.handleMenuAction(value, context),
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: LanguageService.get('delete'),
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(LanguageService.get('delete')),
                    ),
                  ),
                ],
          ),
      ],
    );
  }

  Widget _buildEmployeeDetailsContent(
    BuildContext context,
    EmployeeDetailsViewModel model,
  ) {
    final employee = model.employee!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.w20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, employee),
          SizedBox(height: AppSizes.h20),
          _buildSectionHeader(context, LanguageService.get('personal_details')),
          SizedBox(height: AppSizes.h10),
          _buildInfoCard(context, [
            _buildInfoItem(
              context,
              LanguageService.get('name'),
              employee.name ?? 'N/A',
            ),
            _buildInfoItem(
              context,
              LanguageService.get('email'),
              employee.email ?? 'N/A',
            ),
            _buildInfoItem(
              context,
              LanguageService.get('phone'),
              employee.phone ?? 'N/A',
            ),

            // UPDATE: Naye model se 'bloodGroup' add kiya gaya hai
            _buildInfoItem(
              context,
              LanguageService.get('blood_group'),
              employee.bloodGroup ?? 'N/A',
            ),

            // COMMENTED: Purana 'account_status' wala item. Iski jagah 'bloodGroup' use kiya. Status ab header me hai.
            // _buildInfoItem(context, LanguageService.get('account_status'), ((employee.isActive??false)?"ACTIVE":"INACTIVE")??'N/A'),

            // UPDATE: 'preferred_language' ki jagah 'country' use kiya ja raha hai
            _buildInfoItem(
              context,
              LanguageService.get('country'),
              employee.country ?? 'N/A',
            ),
            // COMMENTED: Purana 'preferred_language' wala item
            // _buildInfoItem(context, LanguageService.get('preferred_language'), employee.country ?? 'N/A'),
          ]),

          SizedBox(height: AppSizes.h20),
          _buildSectionHeader(context, LanguageService.get('employee_details')),
          SizedBox(height: AppSizes.h10),
          _buildInfoCard(context, [
            // UPDATE: 'role' ab 'designation' object se aa raha hai
            _buildInfoItem(
              context,
              LanguageService.get('role'),
              employee.designation?.name ?? 'N/A',
            ),
            // COMMENTED: Purana 'role' wala item
            // _buildInfoItem(context, LanguageService.get('role'), employee.role ?? 'N/A'),

            // UPDATE: Naye model se 'department' add kiya gaya hai
            _buildInfoItem(
              context,
              LanguageService.get('department'),
              employee.department?.name ?? 'N/A',
            ),

            _buildInfoItem(
              context,
              LanguageService.get('type'),
              employee.employeeType ?? 'N/A',
            ),

            // UPDATE: 'status' ab 'isActive' (boolean) se aa raha hai
            _buildInfoItem(
              context,
              LanguageService.get('status'),
              (employee.isActive ?? false) ? "ACTIVE" : "INACTIVE",
            ),

            // COMMENTED: Purana 'status' wala item
            // _buildInfoItem(context, LanguageService.get('status'), ((employee.isActive??false)?"ACTIVE":"INACTIVE")??'N/A'),
            _buildInfoItem(
              context,
              LanguageService.get('shift_timing'),
              employee.shiftTiming ?? 'N/A',
            ),

            // COMMENTED: 'team' naye model me nahi hai, isliye ise comment kiya gaya hai
            // if (employee.team != null && employee?.team!.isNotEmpty)
            //   _buildInfoItem(context, "Team", employee.team!),

            // UPDATE: 'joiningDate' ab dedicated field se aa raha hai
            if (employee.joiningDate != null)
              _buildInfoItem(
                context,
                "Joined",
                model.formatDate(employee.joiningDate!),
              ),
            // COMMENTED: Purana 'createdAt' se date format karne wala item
            // _buildInfoItem(context, "Joined", model.formatDate(employee.createdAt)),
          ]),

          // COMMENTED: Naye model me 'permissions' ka data nahi hai, isliye poora section comment kar diya gaya hai.
          // SizedBox(height: AppSizes.h20),
          // _buildSectionHeader(context, LanguageService.get('permissions')),
          // SizedBox(height: AppSizes.h10),
          // _buildPermissionsCard(context, employee),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Employee employee) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSizes.h20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            // UPDATE: Agar 'profilePhoto' hai to NetworkImage dikhao, nahi to initials.
            // TODO: "YOUR_BASE_URL" ko apne server ke base URL se replace karein.
            backgroundImage:
                employee.profilePhoto != null &&
                        employee.profilePhoto!.isNotEmpty
                    ? NetworkImage("YOUR_BASE_URL" + employee.profilePhoto!)
                    : null,
            child:
                (employee.profilePhoto == null ||
                        employee.profilePhoto!.isEmpty)
                    ? Text(
                      _getInitials(employee.name ?? ''),
                      style: TextStyle(
                        fontSize: 30,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          SizedBox(height: AppSizes.h10),
          Text(
            employee.name ?? 'N/A',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSizes.h5),
          // UPDATE: 'role' ki jagah 'designation.name' use kiya gaya hai
          Text(
            employee.designation?.name ?? 'N/A',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          // COMMENTED: Purana 'role' wala Text widget
          // Text(
          //   employee.role ?? 'N/A',
          //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //     color: AppColors.textSecondary,
          //   ),
          // ),
          SizedBox(height: AppSizes.h5),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.w10,
              vertical: AppSizes.h5,
            ),
            decoration: BoxDecoration(
              // UPDATE: Color ab 'isActive' par depend karega
              color:
                  (employee.isActive ?? false)
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              // COMMENTED: Purana 'accountStatus' par based color logic
              // color: employee.isActive??false
              //     ? Colors.green.withOpacity(0.1)
              //     : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.v20),
            ),
            child: Text(
              // UPDATE: Status text ab 'isActive' se aa raha hai
              (employee.isActive ?? false) ? 'ACTIVE' : 'INACTIVE',
              style: TextStyle(
                // UPDATE: Text color bhi 'isActive' par depend karega
                color: (employee.isActive ?? false) ? Colors.green : Colors.red,
                // COMMENTED: Purana 'accountStatus' par based color logic
                // color: employee.accountStatus == 'active'
                //     ? Colors.green
                //     : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Niche ke helper widgets me koi badlaav nahi hai
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  // COMMENTED: Niche ke sabhi permissions se related functions ko comment kar diya gaya hai kyunki 'permissions' ab model me nahi hai.
  /*
  Widget _buildPermissionsCard(BuildContext context, Employee employee) {
    // Helper function to extract permissions
    List<Widget> buildPermissionItems(Map<String, dynamic> section, String sectionName) {
      List<Widget> items = [];

      section.forEach((key, value) {
        if (value is bool) {
          items.add(_buildPermissionItem(context, '$sectionName - ${_formatPermissionName(key)}', value));
        } else if (value is String) {
          items.add(_buildInfoItem(context, '$sectionName - ${_formatPermissionName(key)}', value));
        }
      });

      return items;
    }

    List<Widget> permissionWidgets = [];

    // Account Access
    if (employee.permissions?.accountAccess != null) {
      permissionWidgets.add(_buildInfoItem(
          context,
          LanguageService.get('account_access'),
          employee.permissions!.accountAccess!
      ));
    }

    // Add all permission sections
    if (employee.permissions?.ticketManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.ticketManagement!.toJson(), "Ticket Management"));
    }

    if (employee.permissions?.machineManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.machineManagement!.toJson(), "Machine Management"));
    }

    if (employee.permissions?.customerInteraction != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.customerInteraction!.toJson(), "Customer Interaction"));
    }

    if (employee.permissions?.financialAccess != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.financialAccess!.toJson(), "Financial Access"));
    }

    if (employee.permissions?.userManagement != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.userManagement!.toJson(), "User Management"));
    }

    if (employee.permissions?.reportAccess != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.reportAccess!.toJson(), "Report Access"));
    }

    if (employee.permissions?.communicationTools != null) {
      permissionWidgets.addAll(buildPermissionItems(employee.permissions!.communicationTools!.toJson(), "Communication Tools"));
    }

    return _buildInfoCard(context, permissionWidgets);
  }

  Widget _buildPermissionItem(BuildContext context, String label, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.h6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: value
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.cancel, color: Colors.red.withOpacity(0.6)),
          )
        ],
      ),
    );
  }

  String _formatPermissionName(String name) {
    // Convert camelCase to Title Case with Spaces
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (Match match) => ' ${match.group(0)}',
    );

    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
  */
}
