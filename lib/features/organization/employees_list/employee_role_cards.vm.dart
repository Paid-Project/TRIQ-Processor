import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/employee.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import '../../employee/add_employee/add_employee.view.dart';
import '../../search/search_view.dart';
import '../employees_list/employees_list.view.dart';
import 'department_hierarchy.view.dart';
import 'employee_role_cards.view.dart';

// Department enum
enum Department {
  // Manufacturer departments
  serviceDepartment,
  salesDepartment,
  customerRelationshipManager,
  hrDepartment,
  financeDepartment,
  productionDepartmentManufacturer,

  // Processor departments
  productionDepartmentProcessor,
  salesDepartmentProcessor,
  piAndFollowUpDepartment,
  accountsDepartment,
  crmDepartment,
}

class RoleEmployeeListViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final employeeService = locator<EmployeeService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final ReactiveValue<String> _selectedRole = ReactiveValue<String>('all');
  final ReactiveValue<String> _selectedEmployeeType = ReactiveValue<String>('all');

  final ReactiveValue<List<Employee>> _employeesList = ReactiveValue<List<Employee>>([]);
  final ReactiveValue<List<Employee>> _filteredEmployees = ReactiveValue<List<Employee>>([]);

  List<Employee> get employeesList => _employeesList.value;
  final ReactiveValue<String> _searchQuery = ReactiveValue<String>('');

  // Show departments instead of roles
  List<Department> get availableDepartments {
    final user = getUser();

    if (user.organizationType == OrganizationType.manufacturer) {
      return [
        Department.serviceDepartment,
        Department.salesDepartment,
        Department.customerRelationshipManager,
        Department.hrDepartment,
        Department.financeDepartment,
        Department.productionDepartmentManufacturer,
      ];
    } else {
      return [
        Department.productionDepartmentProcessor,
        Department.salesDepartmentProcessor,
        Department.piAndFollowUpDepartment,
        Department.accountsDepartment,
        Department.crmDepartment,
      ];
    }
  }

  // Get roles for specific functional departments
  List<UserRole> getRolesForDepartment(Department department) {
    switch (department) {
      case Department.serviceDepartment:
        return [
          UserRole.headOfGlobalService,
          UserRole.countryServiceManager,
          UserRole.localServiceEngineers,
          UserRole.installationEngineers,
        ];
      case Department.productionDepartmentProcessor:
        return [
          UserRole.plantHead,
          UserRole.lineInCharge,
          UserRole.maintenanceHead,
          UserRole.maintenanceEngineer,
          UserRole.machineOperator,
          UserRole.labour,
        ];
      default:
        return [];
    }
  }

  void init() {
    // Initialize if needed
  }

  DepartmentInfo getDepartmentInfo(Department department) {
    switch (department) {
    // Manufacturer departments
      case Department.serviceDepartment:
        return DepartmentInfo(
          displayName: 'Service Department',
          icon: Icons.support_agent,
          primaryColor: AppColors.pink,
          description: 'Customer service and support operations',
          isFunctional: true,
        );

      case Department.salesDepartment:
        return DepartmentInfo(
          displayName: 'Sales Department',
          icon: Icons.trending_up,
          primaryColor: AppColors.lightGreen,
          description: 'Sales and business development',
          isFunctional: false,
        );

      case Department.customerRelationshipManager:
        return DepartmentInfo(
          displayName: 'Customer Relationship Manager',
          icon: Icons.people,
          primaryColor: AppColors.yellow,
          description: 'Manage customer relationships',
          isFunctional: false,
        );

      case Department.hrDepartment:
        return DepartmentInfo(
          displayName: 'HR Department',
          icon: Icons.groups,
          primaryColor: AppColors.darkGreen,
          description: 'Human resources management',
          isFunctional: false,
        );

      case Department.financeDepartment:
        return DepartmentInfo(
          displayName: 'Finance Department',
          icon: Icons.account_balance,
          primaryColor: AppColors.darkPink,
          description: 'Financial planning and management',
          isFunctional: false,
        );

      case Department.productionDepartmentManufacturer:
        return DepartmentInfo(
          displayName: 'Production Department',
          icon: Icons.factory,
          primaryColor: AppColors.pink,
          description: 'Manufacturing and production operations',
          isFunctional: false,
        );

    // Processor departments
      case Department.productionDepartmentProcessor:
        return DepartmentInfo(
          displayName: 'Production Department',
          icon: Icons.precision_manufacturing,
          primaryColor: AppColors.darkGreen,
          description: 'Production line operations',
          isFunctional: true,
        );

      case Department.salesDepartmentProcessor:
        return DepartmentInfo(
          displayName: 'Sales Department',
          icon: Icons.point_of_sale,
          primaryColor: AppColors.lightGreen,
          description: 'Sales operations and management',
          isFunctional: false,
        );

      case Department.piAndFollowUpDepartment:
        return DepartmentInfo(
          displayName: 'PI and Follow-up Department',
          icon: Icons.track_changes,
          primaryColor: AppColors.darkPink,
          description: 'Process improvement and follow-up',
          isFunctional: false,
        );

      case Department.accountsDepartment:
        return DepartmentInfo(
          displayName: 'Accounts Department',
          icon: Icons.account_balance_wallet,
          primaryColor: AppColors.yellow,
          description: 'Accounting and financial records',
          isFunctional: false,
        );

      case Department.crmDepartment:
        return DepartmentInfo(
          displayName: 'CRM Department',
          icon: Icons.account_balance_wallet,
          primaryColor: AppColors.pink,
          description: 'Customer relationship management',
          isFunctional: false,
        );

      default:
        return DepartmentInfo(
          displayName: 'Unknown Department',
          icon: Icons.business,
          primaryColor: AppColors.lightGreen,
          description: 'Department not defined',
          isFunctional: false,
        );
    }
  }

  RoleInfo getRoleInfo(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return RoleInfo(
          displayName: 'Super Admin',
          icon: Icons.admin_panel_settings,
          primaryColor: const Color(0xFF6B46C1),
          description: 'System administrator with full access',
        );

    // Processor roles
      case UserRole.plantHead:
        return RoleInfo(
          displayName: 'Plant Head',
          icon: Icons.factory,
          primaryColor: const Color(0xFF059669),
          description: 'Oversees plant operations',
        );

      case UserRole.lineInCharge:
        return RoleInfo(
          displayName: 'Line In-Charge',
          icon: Icons.timeline,
          primaryColor: const Color(0xFF0D9488),
          description: 'Manages production line operations',
        );

      case UserRole.maintenanceHead:
        return RoleInfo(
          displayName: 'Maintenance Head',
          icon: Icons.engineering,
          primaryColor: const Color(0xFF7C3AED),
          description: 'Leads maintenance operations',
        );

      case UserRole.maintenanceEngineer:
        return RoleInfo(
          displayName: 'Maintenance Engineer',
          icon: Icons.build,
          primaryColor: const Color(0xFF2563EB),
          description: 'Handles equipment maintenance',
        );

      case UserRole.machineOperator:
        return RoleInfo(
          displayName: 'Machine Operator',
          icon: Icons.precision_manufacturing,
          primaryColor: const Color(0xFFDC2626),
          description: 'Operates production machinery',
        );

      case UserRole.labour:
        return RoleInfo(
          displayName: 'Labour',
          icon: Icons.groups,
          primaryColor: const Color(0xFF9333EA),
          description: 'General workforce',
        );

    // Manufacturer roles
      case UserRole.headOfGlobalService:
        return RoleInfo(
          displayName: 'Head of Global Service',
          icon: Icons.public,
          primaryColor: const Color(0xFF0891B2),
          description: 'Manages global service operations',
        );

      case UserRole.countryServiceManager:
        return RoleInfo(
          displayName: 'Country Service Manager',
          icon: Icons.flag,
          primaryColor: const Color(0xFF0F766E),
          description: 'Manages country-level services',
        );

      case UserRole.localServiceEngineers:
        return RoleInfo(
          displayName: 'Local Service Engineers',
          icon: Icons.location_on,
          primaryColor: const Color(0xFF7C2D12),
          description: 'Provides local technical support',
        );

      case UserRole.installationEngineers:
        return RoleInfo(
          displayName: 'Installation Engineers',
          icon: Icons.construction,
          primaryColor: const Color(0xFF1D4ED8),
          description: 'Handles equipment installation',
        );

      default:
        return RoleInfo(
          displayName: 'Unknown Role',
          icon: Icons.person,
          primaryColor: const Color(0xFF6B7280),
          description: 'Role not defined',
        );
    }
  }

  Future<int> getEmployeeCount(String role) async {
    try {
      final response = await employeeService.getEmployees(
        role: role,
        employeeType: null,
      );

      return response.fold(
            (exception) => 0,
            (employees) => employees.length,
      );
    } catch (e) {
      return 0;
    }
  }

  Future<int> getDepartmentEmployeeCount(Department department) async {
    final departmentInfo = getDepartmentInfo(department);
    if (!departmentInfo.isFunctional) {
      return 0; // Return 0 for non-functional departments
    }

    // For functional departments, sum up all roles in that department
    final roles = getRolesForDepartment(department);
    int totalCount = 0;

    for (final role in roles) {
      final roleInfo = getRoleInfo(role);
      final count = await getEmployeeCount(roleInfo.displayName);
      totalCount += count;
    }

    return totalCount;
  }

  showScanQrOptions() async {
    final response = await _bottomSheetService
        .showCustomSheet<QrScanSheetResponse, QrScanSheetAttributes>(
      variant: BottomSheetType.qrScan,
      data: QrScanSheetAttributes(),
      isScrollControlled: true,
    );
    if (response?.confirmed == true) {
      await Future.delayed(Duration.zero);
      if (response?.data?.qrSource == QrSource.gallery) {
        navigateToScanQRFromGallery(
              (data) => navigateToAddEmployee(
            AddEmployeeViewAttributes(id: data as String),
          ),
        );
      }
      if (response?.data?.qrSource == QrSource.camera) {
        navigateToScanQRFromCamera(
              (data) => navigateToAddEmployee(
            AddEmployeeViewAttributes(id: data as String),
          ),
        );
      }
      if ([
        QrSource.phoneNumber,
        QrSource.email,
      ].contains(response?.data?.qrSource)) {
        navigateToSearch(
          SearchViewAttributes(
            title: 'Employee',
            apiEndPoint: 'employee/search',
            onSelect: (data) {
              _navigationService.back();
              navigateToAddEmployee(
                AddEmployeeViewAttributes(id: data as String),
              );
            },
          ),
        );
      }
      if ([
        QrSource.addNew,
      ].contains(response?.data?.qrSource)) {
        navigateToAddEmployee(
          AddEmployeeViewAttributes(
            id: null,
            hasPasswordField: true,
            hasReadOnly: false,
          ),
        );
      }
    }
  }

  Future<void> getEmployees({
    required String? role,
    required String? employeeType,
  }) async {
    setBusy(true);

    final response = await employeeService.getEmployees(
      role: role == 'all' ? null : role,
      employeeType: employeeType == 'all' ? null : employeeType,
    );

    response.fold(
          (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
        _employeesList.value = [];
        _filteredEmployees.value = [];
      },
          (employees) {
        _employeesList.value = employees;
        _applyFilters();
      },
    );

    setBusy(false);
  }

  void _applyFilters() {
    if (_searchQuery.value.isEmpty) {
      _filteredEmployees.value = [..._employeesList.value];
    } else {
      final query = _searchQuery.value.toLowerCase();
      _filteredEmployees.value = _employeesList.value.where((employee) {
        final nameMatch = employee.name?.toLowerCase().contains(query) ?? false;
        final emailMatch = employee.email?.toLowerCase().contains(query) ?? false;
        final idMatch = employee.id?.toLowerCase().contains(query) ?? false;

        return nameMatch || emailMatch || idMatch;
      }).toList();
    }
    notifyListeners();
  }

  void navigateToAddEmployee(AddEmployeeViewAttributes attributes) async {
    await _navigationService.navigateTo(
      Routes.addEmployee,
      arguments: attributes,
    );
    // Refresh the employee list after returning
    getEmployees(
      role: _selectedRole.value,
      employeeType: _selectedEmployeeType.value,
    );
  }

  // Handle department navigation
  void navigateToDepartment(Department department) {
    final departmentInfo = getDepartmentInfo(department);

    if (!departmentInfo.isFunctional) {
      // Show coming soon message for non-functional departments
      Fluttertoast.showToast(
        msg: "${departmentInfo.displayName} - Coming Soon!",
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // For functional departments, navigate to role selection
    _navigationService.navigateTo(
      Routes.departmentHierarchy, // Make sure this route is defined in your Routes class
      arguments: DepartmentHierarchyArguments(
        department: department,
        departmentInfo: departmentInfo,
      ),
    );
  }

  void navigateToEmployeeList(String role) {
    _navigationService.navigateToView(
      EmployeesListView(
        attributes: EmployeeListViewAttributes(role: role),
      ),
    );
  }
}

// Department Information Data Class
class DepartmentInfo {
  final String displayName;
  final IconData icon;
  final Color primaryColor;
  final String description;
  final bool isFunctional;

  DepartmentInfo({
    required this.displayName,
    required this.icon,
    required this.primaryColor,
    required this.description,
    required this.isFunctional,
  });
}

// Role Information Data Class
class RoleInfo {
  final String displayName;
  final IconData icon;
  final Color primaryColor;
  final String description;

  RoleInfo({
    required this.displayName,
    required this.icon,
    required this.primaryColor,
    required this.description,
  });
}

// Arguments class for passing data to views
class EmployeesListViewArguments {
  final String? role;

  EmployeesListViewArguments({
    this.role,
  });
}

// New view for showing roles within a department
class DepartmentRolesView extends StatelessWidget {
  final Department department;
  final DepartmentInfo departmentInfo;

  const DepartmentRolesView({
    super.key,
    required this.department,
    required this.departmentInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RoleEmployeeListViewModel>.reactive(
      viewModelBuilder: () => RoleEmployeeListViewModel(),
      onViewModelReady: (model) => model.init(),
      disposeViewModel: false,
      builder: (context, model, child) {
        final roles = model.getRolesForDepartment(department);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.primary,
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
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.w20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Role',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.h8),
                Text(
                  'Choose a role to view team members',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.h24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSizes.w16,
                    mainAxisSpacing: AppSizes.h16,
                  ),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final roleInfo = model.getRoleInfo(role);

                    return Card(
                      elevation: 4,
                      shadowColor: AppColors.black.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.v16),
                      ),
                      child: InkWell(
                        onTap: () => model.navigateToEmployeeList(roleInfo.displayName),
                        borderRadius: BorderRadius.circular(AppSizes.v16),
                        child: Container(
                          padding: EdgeInsets.all(AppSizes.w16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSizes.v16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                roleInfo.primaryColor,
                                roleInfo.primaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSizes.w12),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppSizes.v12),
                                ),
                                child: Icon(
                                  roleInfo.icon,
                                  color: AppColors.white,
                                  size: 28,
                                ),
                              ),
                              Spacer(),
                              Text(
                                roleInfo.displayName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSizes.h4),
                              FutureBuilder<int>(
                                future: model.getEmployeeCount(roleInfo.displayName),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data} ${snapshot.data == 1 ? 'employee' : 'employees'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.white.withValues(alpha: 0.9),
                                      ),
                                    );
                                  }
                                  return Text(
                                    'Loading...',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white.withValues(alpha: 0.7),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}