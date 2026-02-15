import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:stacked/stacked.dart';
import 'package:intl_phone_field/countries.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import 'employee_role_cards.vm.dart';
import 'department_hierarchy.vm.dart';

class DepartmentHierarchyView extends StatelessWidget {
  const DepartmentHierarchyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments from RouteSettings
    final args = ModalRoute.of(context)?.settings.arguments as DepartmentHierarchyArguments?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text(LanguageService.get("no_department_data"),),
        ),
      );
    }

    final department = args.department;
    final departmentInfo = args.departmentInfo;

    return ViewModelBuilder<DepartmentHierarchyViewModel>.reactive(
      viewModelBuilder: () => DepartmentHierarchyViewModel(),
      onViewModelReady: (model) => model.init(department),
      disposeViewModel: false,
      builder: (context, model, child) {
        return
          Scaffold(
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.white),
            title: Text(
              departmentInfo.displayName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: model.showScanQrOptions,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, color: AppColors.white),
          ),
          body:
            model.isBusy
              ?
            Container(
                color: AppColors.white,
                child: _buildLoadingState(departmentInfo)
            )
              :
            Container(
              color: AppColors.white,
              child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.w20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, departmentInfo),
                  SizedBox(height: AppSizes.h24),
                  _buildHierarchy(context, model, departmentInfo),
                ],
              ),
                        ),
            ),
        );
      },
    );
  }

  Widget _buildLoadingState(DepartmentInfo departmentInfo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: departmentInfo.primaryColor),
          SizedBox(height: AppSizes.h16),
          Text(
            LanguageService.get("loading_hierarchy"),
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DepartmentInfo departmentInfo) {
    return Container(
      padding: EdgeInsets.all(AppSizes.w20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            departmentInfo.primaryColor.withValues(alpha: 0.1),
            departmentInfo.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.v16),
        border: Border.all(
          color: departmentInfo.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.w8),
            decoration: BoxDecoration(
              color: departmentInfo.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.v12),
            ),
            child: Icon(
              departmentInfo.icon,
              color: departmentInfo.primaryColor,
              size: 25,
            ),
          ),
          SizedBox(width: AppSizes.w16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.get("department_hierarchy"),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.h4),
                Text(
                  departmentInfo.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildHierarchy(BuildContext context, DepartmentHierarchyViewModel model, DepartmentInfo departmentInfo) {
    final hierarchyData = model.getHierarchyData();

    if (hierarchyData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hierarchyData.map((level) => _buildHierarchyLevel(context, model, level, departmentInfo)).toList(),
    );
  }

  Widget _buildHierarchyLevel(BuildContext context, DepartmentHierarchyViewModel model, HierarchyLevel level, DepartmentInfo departmentInfo) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            margin: EdgeInsets.only(left: level.indentLevel * 16.0),
            child: Row(
              children: [
                // Hierarchy connection indicators
                if (level.indentLevel > 0) ...[
                  // Vertical line
                  Container(
                    width: 2,
                    height: 20,
                    color: departmentInfo.primaryColor.withValues(alpha: 0.4),
                    margin: EdgeInsets.only(right: 8),
                  ),
                  // Horizontal connection
                  Container(
                    width: 12,
                    height: 2,
                    color: departmentInfo.primaryColor.withValues(alpha: 0.4),
                    margin: EdgeInsets.only(right: 8),
                  ),
                  // Arrow or tree symbol
                  Icon(
                    level.indentLevel == 1 ? Icons.subdirectory_arrow_right : Icons.more_horiz,
                    size: 16,
                    color: departmentInfo.primaryColor,
                  ),
                  SizedBox(width: AppSizes.w8),
                ],

                // Country flag (if available)
                if (level.countryCode != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppSizes.w4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v6),
                      border: Border.all(
                        color: departmentInfo.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getCountryFlag(level.countryCode!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: AppSizes.w8),
                ],

                // Role icon based on priority
                Container(
                  padding: EdgeInsets.all(AppSizes.w8),
                  decoration: BoxDecoration(
                    color: departmentInfo.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.v8),
                  ),
                  child: Icon(
                    _getRoleIcon(level.roleTitle, level.priority),
                    size: 16,
                    color: departmentInfo.primaryColor,
                  ),
                ),

                SizedBox(width: AppSizes.w12),

                // Role title
                Expanded(
                  child: Text(
                    level.roleTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: departmentInfo.primaryColor,
                    ),
                  ),
                ),

                // Employee count badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w8,
                    vertical: AppSizes.h4,
                  ),
                  decoration: BoxDecoration(
                    color: departmentInfo.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                    border: Border.all(
                      color: departmentInfo.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${level.employees.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: departmentInfo.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.h12),

          // Employees in this role
          if (level.employees.isNotEmpty) ...[
            ...level.employees.map((employee) => _buildEmployeeCard(
                context,
                model,
                employee,
                level.indentLevel + 1,
                departmentInfo
            )).toList(),
          ] else ...[
            Container(
              margin: EdgeInsets.only(left: (level.indentLevel + 1) * 16.0),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.w16,
                vertical: AppSizes.h12,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSizes.v8),
                border: Border.all(
                  color: AppColors.lightGrey.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add_disabled,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSizes.w8),
                  Text(
                    LanguageService.get("no_employees_assigned_role"),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCountryFlag(String countryCode) {
    try {
      final country = countries.firstWhere(
            (c) => c.code.toLowerCase() == countryCode.toLowerCase(),
      );
      return country.flag;
    } catch (e) {
      return '🌍'; // Default flag if country not found
    }
  }

  IconData _getRoleIcon(String roleTitle, int priority) {
    if (roleTitle.contains('Head') || roleTitle.contains('Manager')) {
      return Icons.person_pin;
    } else if (roleTitle.contains('Engineer')) {
      return Icons.engineering;
    } else if (roleTitle.contains('Operator') || roleTitle.contains('Labour')) {
      return Icons.construction;
    } else if (roleTitle.contains('Maintenance')) {
      return Icons.build;
    } else if (roleTitle.contains('Installation')) {
      return Icons.install_desktop;
    } else if (roleTitle.contains('Line')) {
      return Icons.timeline;
    }
    return Icons.work;
  }

  Widget _buildEmployeeCard(BuildContext context, DepartmentHierarchyViewModel model, Employee employee, int indentLevel, DepartmentInfo departmentInfo) {
    return Container(
      margin: EdgeInsets.only(
        left: indentLevel * 16.0,
        bottom: AppSizes.h8,
      ),
      child: Card(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          side: BorderSide(
            color: departmentInfo.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => model.navigateToEmployeeDetail(employee),
          borderRadius: BorderRadius.circular(AppSizes.v12),
          child: Container(
            padding: EdgeInsets.all(AppSizes.w12),
            child: Row(
              children: [
                // Hierarchy connection line
                if (indentLevel > 0) ...[
                  Container(
                    width: 2,
                    height: 40,
                    color: departmentInfo.primaryColor.withValues(alpha: 0.3),
                    margin: EdgeInsets.only(right: AppSizes.w8),
                  ),
                  Container(
                    width: 12,
                    height: 2,
                    color: departmentInfo.primaryColor.withValues(alpha: 0.3),
                    margin: EdgeInsets.only(right: AppSizes.w8),
                  ),
                ],

                // Country flag for employee
                if (employee.currentCountry != null || employee.country != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppSizes.w4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v6),
                      border: Border.all(
                        color: departmentInfo.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getEmployeeCountryFlag(employee.currentCountry ?? employee.country!),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(width: AppSizes.w8),
                ],

                // Employee avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: departmentInfo.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    employee.name?.isNotEmpty == true ? employee.name![0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: departmentInfo.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(width: AppSizes.w12),

                // Employee info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name ?? 'Unknown Employee',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (employee.email != null) ...[
                        SizedBox(height: AppSizes.h2),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppSizes.w4),
                            Expanded(
                              child: Text(
                                employee.email!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (employee.currentCountry != null || employee.country != null) ...[
                        SizedBox(height: AppSizes.h2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppSizes.w4),
                            Expanded(
                              child: Text(
                                employee.currentCountry ?? employee.country!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (employee.employeeId != null) ...[
                        SizedBox(height: AppSizes.h2),
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: AppSizes.w4),
                            Text(
                              'ID: ${employee.employeeId}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status and role indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w8,
                        vertical: AppSizes.h4,
                      ),
                      decoration: BoxDecoration(
                        color: employee.employmentStatus == 'Full time'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.v12),
                      ),
                      child: Text(
                        employee.employmentStatus ?? 'No Details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: employee.employmentStatus == 'Full time'
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.h4),
                    Icon(
                      Icons.chevron_right,
                      color: departmentInfo.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEmployeeCountryFlag(String countryName) {
    try {
      final country = countries.firstWhere(
            (c) => c.name.toLowerCase() == countryName.toLowerCase(),
      );
      return country.flag;
    } catch (e) {
      return '🌍'; // Default flag if country not found
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: AppSizes.h40),
          Container(
            padding: EdgeInsets.all(AppSizes.w24),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.h16),
          Text(
           LanguageService.get("no_employees_found"),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            LanguageService.get("department_no_employees"),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Arguments class for passing data through RouteSettings
class DepartmentHierarchyArguments {
  final Department department;
  final DepartmentInfo departmentInfo;

  DepartmentHierarchyArguments({
    required this.department,
    required this.departmentInfo,
  });
}