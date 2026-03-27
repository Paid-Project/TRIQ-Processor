import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';

import 'package:manager/features/chat/chat_list.view.dart';
import 'package:manager/features/chat/chat_view.dart';
import 'package:manager/features/auth/login/login.view.dart';
import 'package:manager/features/auth/otp_verification/otp_verification.view.dart';
import 'package:manager/features/auth/register/register.view.dart';
import 'package:manager/features/employee/detail_employee/employee_details.dart';
import 'package:manager/features/home/analytics/analytics_view.dart';
import 'package:manager/features/home/feedback/feedback_view.dart';
import 'package:manager/features/home/globalActivity/globalActivity.dart';
import 'package:manager/features/home/installations/installation.dart';
import 'package:manager/features/home/notification/notification_view.dart';
import 'package:manager/features/home/pi/pi_invoice_record_view.dart';
import 'package:manager/features/home/warrenty/warrenty_tracker.dart';
import 'package:manager/features/image/image_full_screen.view.dart';
import 'package:manager/features/profile/scan_code/scan_code.view.dart';
import 'package:manager/screens/update_required/update_required_screen.dart';
import 'package:manager/features/video/video_player.view.dart';
import 'package:manager/features/tickets/ticket_details/ticket_details.view.dart';
import 'package:manager/features/organization/add_partner/add_partner.view.dart';
import 'package:manager/features/permissions/permissions.view.dart';
import 'package:manager/features/profile/qr/qr.view.dart';
import 'package:manager/features/qr/scan_qr/scan_qr.view.dart';
import 'package:manager/features/requests/approvals/approval.view.dart';
import 'package:manager/features/search/search_view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/features/language/language_selection_view.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/notification.service.dart';
import 'package:manager/services/secure_api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/teams/department/team_list.view.dart';
import 'package:manager/core/models/pending_ticket_data.dart';
import '../app/app.vm.dart';

import '../features/chat/archive_chat/archived_chat_list.view.dart';
import '../features/Messages/create_group/create_group.view.dart';
import '../features/auth/auth_selection/auth_selection.view.dart';
import '../features/chat/group_info/group_info.view.dart';
import '../features/employee/add_employee/add_employee.view.dart';
import '../features/home/machine_supplier/machine_supplier.view.dart';
import '../features/home/organization_home/organization_home.view.dart';
import '../features/introduction/introduction_view.dart';
import '../features/machines/add_machine/add_machine.view.dart';
import '../features/machines/machines_list/machines_list.view.dart';
import '../features/organization/admin_managers_list/admin_managers_list.view.dart';
import '../features/organization/employees_list/department_hierarchy.view.dart';
import '../features/organization/employees_list/employees_list.view.dart';
import '../features/profile/create_or_edit_org/create_or_edit_org.view.dart';
import '../features/profile/home/profile.view.dart';
import '../features/profile/general/general.view.dart';
import '../features/tasks/create_task/create_task.view.dart';
import '../features/tasks/task_list/task_list.view.dart';
import '../features/tickets/review_ticket/review_ticket.view.dart';
import '../features/tickets/tickets_list/tickets_list.view.dart';
import '../features/organization/employees_list/employee_role_cards.view.dart';
import '../features/home/machine_overview/machine_overview.view.dart';
import '../features/home/machine_overview/machine_overview_details/machine_overview_details.view.dart';
import '../core/models/machine_overview_model.dart';

// TODO: Add imports for the new views when they are created
// import '../features/home/factories_overview/factories_overview.view.dart';
// import '../features/tickets/tickets_summary/tickets_summary.view.dart';
// import '../features/finance/finance_summary/finance_summary.view.dart';
// import '../features/performance/factory_performance/factory_performance.view.dart';
// import '../features/machines/assigned_machines/assigned_machines.view.dart';
// import '../features/maintenance/maintenance_status/maintenance_status.view.dart';
// import '../features/production/line_production_log/line_production_log.view.dart';
// import '../features/inventory/inventory_requests/inventory_requests.view.dart';
// import '../features/employee/attendance/attendance.view.dart';
// import '../features/maintenance/maintenance_schedule/maintenance_schedule.view.dart';
// import '../features/inventory/spare_parts_request/spare_parts_request.view.dart';
// import '../features/machines/machine_downtime_tracker/machine_downtime_tracker.view.dart';
// import '../features/dispatch/dispatch_tracker/dispatch_tracker.view.dart';
// import '../features/sales/sales_dashboard/sales_dashboard.view.dart';
// import '../features/production/production_reports/production_reports.view.dart';
// import '../features/performance/engineer_performance/engineer_performance.view.dart';
// import '../features/schedule/my_schedule/my_schedule.view.dart';
// import '../features/installations/assigned_installations/assigned_installations.view.dart';
// import '../features/checklist/customer_checklist/customer_checklist.view.dart';
// import '../features/photos/site_photos_upload/site_photos_upload.view.dart';

/// **AppRouter**
///
/// This class defines the application's navigation routes using Stacked's `RouterBase`.
///
/// ### **Features:**
/// - Maps **views** (`IntroView`, `LoginView`, `RegisterView`, etc) to their respective routes.
/// - Uses `StackedRouteFactory` to manage page transitions.
/// - Implements a **list of routes** using `RouteDef` to define paths.
///
/// **Example Usage:**
/// ```dart
/// Navigator.pushNamed(context, Routes.login);
/// ```
class AppRouter extends RouterBase {
  /// Defines the mapping between view types and their corresponding route factories.
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;

  /// Internal mapping of views to their respective page routes.
  final Map<Type, StackedRouteFactory> _pagesMap = <Type, StackedRouteFactory>{
    RootWrapper: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => RootWrapper(arguments: data.arguments),
        settings: data,
      );
    },
    UpdateRequiredScreen: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => const UpdateRequiredScreen(),
        settings: data,
      );
    },
    LoginView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => LoginView(),
        settings: data,
      );
    },
    RegisterView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => RegisterView(),
        settings: data,
      );
    },
    OtpVerificationView: (data) {
      final OtpVerificationViewAttributes attributes =
          data.arguments as OtpVerificationViewAttributes;
      return MaterialPageRoute(
        builder:
            (BuildContext _) => OtpVerificationView(attributes: attributes),
        settings: data,
      );
    },
    ScanQRView: (data) {
      final attributes = data.arguments as ScanQRViewAttributes;
      return MaterialPageRoute(
        builder: (BuildContext _) => ScanQRView(attributes: attributes),
        settings: data,
      );
    },
    OrganizationHomeView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => OrganizationHomeView(),
        settings: data,
      );
    },

    MachineSupplierView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => MachineSupplierView(),
        settings: data,
      );
    },
    TicketsListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => TicketsListView(),
        settings: data,
      );
    },
    AnalyticsView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => AnalyticsView(),
        settings: data,
      );
    },

    FeedbackView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => FeedbackView(),
        settings: data,
      );
    },

    Globalactivity: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => Globalactivity(),
        settings: data,
      );
    },

    WarrentyTrackerView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => WarrentyTrackerView(),
        settings: data,
      );
    },

    InstallationTrackerView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => InstallationTrackerView(),
        settings: data,
      );
    },

    PiInvoiceRecordView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => PiInvoiceRecordView(),
        settings: data,
      );
    },

    MachinesListView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => MachinesListView(
              attributes: MachinesListViewAttributes.fromJson(
                data.queryParams.rawMap as Map<String, String>,
              ),
            ),
        settings: data,
      );
    },
    GroupInfoScreen: (data) {
      final args = data.arguments as Map?;
      return MaterialPageRoute(
        builder:
            (BuildContext _) => GroupInfoScreen(
          contactNumber: args?['contactNumber'] ?? '',
          contactName: args?['contactName'] ?? '',
          roomId: args?['roomId'],
        ),
        settings: data,
      );
    },
    ProfileView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => ProfileView(),
        settings: data,
      );
    },
    QRView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => QRView(),
        settings: data,
      );
    },
    UpdateOrganizationView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => UpdateOrganizationView(
              attributes:
                  data.arguments != null
                      ? data.arguments as UpdateOrganizationViewAttributes
                      : null,
            ),
        settings: data,
      );
    },

    AdminManagersListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => AdminManagersListView(),
        settings: data,
      );
    },
    StageView: (data) {
      final attributes = data.arguments is StageViewAttributes
          ? data.arguments as StageViewAttributes
          : StageViewAttributes(selectedBottomNavIndex: 0);
      return MaterialPageRoute(
        builder: (BuildContext _) => StageView(attributes: attributes),
        settings: data,
      );
    },

    ApprovalView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => ApprovalView(),
        settings: data,
      );
    },
    AddPartnerView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => AddPartnerView(
              attributes: data.arguments as AddPartnerViewAttributes,
            ),
        settings: data,
      );
    },
    EmployeesListView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => EmployeesListView(
              attributes: EmployeeListViewAttributes.fromJson(
                data.queryParams.rawMap as Map<String, String>,
              ),
            ),
        settings: data,
      );
    },
    TeamListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => TeamListView(),
        settings: data,
      );
    },
    AddEmployeeView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => AddEmployeeView(
              attributes: data.arguments as AddEmployeeViewAttributes,
            ),
        settings: data,
      );
    },
    AddMachineView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => AddMachineView(
              attributes: AddMachineViewAttributes.fromMap(
                data.queryParams.rawMap as Map<String, String>,
              ),
            ),
        settings: data,
      );
    },
    SearchView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) =>
                SearchView(attributes: data.arguments as SearchViewAttributes),
        settings: data,
      );
    },
    ChatListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => ChatListView(),
        settings: data,
      );
    },
    ChatView: (data) {
      final args = data.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder:
            (BuildContext _) => ChatView(
              contactName: args?['contactName'] ?? 'Unknown Contact',
              contactNumber: args?['contactNumber'] ?? '',
              contactInitials: args?['contactInitials'] ?? 'U',
              roomId: args?['roomId'],
              flag: args?['flag'],
            ),
        settings: data,
      );
    },
    PermissionsView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => PermissionsView(),
        settings: data,
      );
    },
    CreateGroupChat: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => CreateGroupChat(),
        settings: data,
      );
    },
    ArchivedChatList: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => ArchivedChatList(),
        settings: data,
      );
    },
    ImageViewerView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) =>
                ImageViewerView(imageUrl: data.arguments as String),
        settings: data,
      );
    },
    VideoPlayerView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) =>
                VideoPlayerView(videoUrl: data.arguments as String),
        settings: data,
      );
    },
    TicketDetailsView: (data) {
      final ticketId = data.arguments as String?;
      return MaterialPageRoute(
        builder: (BuildContext _) => TicketDetailsView(ticketId: ticketId),
        settings: data,
      );
    },
    EmployeeDetailsView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => EmployeeDetailsView(
              attributes: EmployeeDetailsViewAttributes.fromJson(
                data.queryParams.rawMap as Map<String, String>,
              ),
            ),
        settings: data,
      );
    },

    RoleEmployeeListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => RoleEmployeeListView(),
        settings: data,
      );
    },

    DepartmentHierarchyView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => DepartmentHierarchyView(),
        settings: data,
      );
    },

    IntroductionView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => IntroductionView(),
        settings: data,
      );
    },

    AuthSelectionView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => AuthSelectionView(),
        settings: data,
      );
    },

    GeneralSettingView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => GeneralSettingView(),
        settings: data,
      );
    },
    LanguageSelectionView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => LanguageSelectionView(),
        settings: data,
      );
    },

    // TODO: Add the following page mappings when the corresponding views are created:

    // FactoriesOverviewView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => FactoriesOverviewView(),
    //     settings: data,
    //   );
    // },

    // TicketsSummaryView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => TicketsSummaryView(),
    //     settings: data,
    //   );
    // },

    // FinanceSummaryView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => FinanceSummaryView(),
    //     settings: data,
    //   );
    // },

    // FactoryPerformanceView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => FactoryPerformanceView(),
    //     settings: data,
    //   );
    // },

    // AssignedMachinesView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => AssignedMachinesView(),
    //     settings: data,
    //   );
    // },

    // MaintenanceStatusView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => MaintenanceStatusView(),
    //     settings: data,
    //   );
    // },

    // LineProductionLogView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => LineProductionLogView(),
    //     settings: data,
    //   );
    // },

    // InventoryRequestsView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => InventoryRequestsView(),
    //     settings: data,
    //   );
    // },

    // AttendanceView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => AttendanceView(),
    //     settings: data,
    //   );
    // },

    // MaintenanceScheduleView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => MaintenanceScheduleView(),
    //     settings: data,
    //   );
    // },

    // SparePartsRequestView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => SparePartsRequestView(),
    //     settings: data,
    //   );
    // },

    // MachineDowntimeTrackerView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => MachineDowntimeTrackerView(),
    //     settings: data,
    //   );
    // },

    // DispatchTrackerView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => DispatchTrackerView(),
    //     settings: data,
    //   );
    // },

    // SalesDashboardView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => SalesDashboardView(),
    //     settings: data,
    //   );
    // },

    // ProductionReportsView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => ProductionReportsView(),
    //     settings: data,
    //   );
    // },

    // EngineerPerformanceView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => EngineerPerformanceView(),
    //     settings: data,
    //   );
    // },

    // MyScheduleView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => MyScheduleView(),
    //     settings: data,
    //   );
    // },

    // AssignedInstallationsView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => AssignedInstallationsView(),
    //     settings: data,
    //   );
    // },

    // CustomerChecklistView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => CustomerChecklistView(),
    //     settings: data,
    //   );
    // },

    // SitePhotosUploadView: (data) {
    //   return MaterialPageRoute(
    //     builder: (BuildContext _) => SitePhotosUploadView(),
    //     settings: data,
    //   );
    // },
    TaskListView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => TaskListView(),
        settings: data,
      );
    },
    AssignTaskScreen: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => AssignTaskScreen(),
        settings: data,
      );
    },
    ScanCodeView: (data) {
      final attributes = data.arguments as ScanCodeViewAttributes?;
      return MaterialPageRoute(
        builder: (BuildContext _) => ScanCodeView(attributes: attributes),
        settings: data,
      );
    },
    MachineOverviewView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => MachineOverviewView(),
      );
    },
    MachineOverviewDetailsView: (data) {
      return MaterialPageRoute(
        builder:
            (BuildContext _) => MachineOverviewDetailsView(
              machine: data.arguments as MachineOverviewList?,
            ),
        settings: data,
      );
    },
    NotificationView: (data) {
      return MaterialPageRoute(
        builder: (BuildContext _) => NotificationView(),
        settings: data,
      );
    },
    ReviewTicketView: (data) {
      final args = data.arguments;
      String? ticketId;
      PendingTicketData? pendingTicketData;
      
      if (args is String) {
        ticketId = args;
      } else if (args is PendingTicketData) {
        pendingTicketData = args;
      }
      
      return MaterialPageRoute(
        builder: (BuildContext _) => ReviewTicketView(
          ticketId: ticketId,
          pendingTicketData: pendingTicketData,
        ),
        settings: data,
      );
    },
  };

  /// Defines the list of routes available in the manager.
  @override
  List<RouteDef> get routes => _routes;

  /// Internal list of route definitions.
  final _routes = <RouteDef>[
    RouteDef(Routes.root, page: RootWrapper),
    RouteDef(Routes.updateRequired, page: UpdateRequiredScreen),
    RouteDef(Routes.login, page: LoginView),

    RouteDef(Routes.register, page: RegisterView),
    RouteDef(Routes.otpVerification, page: OtpVerificationView),
    RouteDef(Routes.organizationHome, page: OrganizationHomeView),
    RouteDef(Routes.tasks, page: TaskListView),
    RouteDef(Routes.teams, page: TeamListView),
    RouteDef(Routes.createTask, page: AssignTaskScreen),
    RouteDef(Routes.machineSupplier, page: MachineSupplierView),
    RouteDef(Routes.ticketsList, page: TicketsListView),
    RouteDef(Routes.machinesList, page: MachinesListView),
    RouteDef(Routes.profile, page: ProfileView),
    RouteDef(Routes.qr, page: QRView),
    RouteDef(Routes.updateOrg, page: UpdateOrganizationView),
    RouteDef(Routes.adminManagersList, page: AdminManagersListView),
    RouteDef(Routes.stage, page: StageView),
    RouteDef(Routes.approval, page: ApprovalView),
    RouteDef(Routes.scanQr, page: ScanQRView),
    RouteDef(Routes.scanCode, page: ScanCodeView),
    RouteDef(Routes.addPartner, page: AddPartnerView),
    RouteDef(Routes.employeesList, page: RoleEmployeeListView),
    RouteDef(Routes.addEmployee, page: AddEmployeeView),
    RouteDef(Routes.addMachine, page: AddMachineView),
    RouteDef(Routes.search, page: SearchView),
    RouteDef(Routes.chatsList, page: ChatListView),
    RouteDef(Routes.chatView, page: ChatView),
    RouteDef(Routes.permissions, page: PermissionsView),
    RouteDef(Routes.createGroupChat, page: CreateGroupChat),
    RouteDef(Routes.archivedChats, page: ArchivedChatList),
    RouteDef(Routes.imageViewerView, page: ImageViewerView),
    RouteDef(Routes.videoPlayer, page: VideoPlayerView),
    RouteDef(Routes.ticketDetails, page: TicketDetailsView),
    RouteDef(Routes.employee, page: EmployeeDetailsView),
    RouteDef(Routes.groupInfoScreen, page: GroupInfoScreen),
    // Analytics and existing dashboard routes
    RouteDef(Routes.analytics, page: AnalyticsView),
    RouteDef(Routes.feedback, page: FeedbackView),
    RouteDef(Routes.invoice, page: PiInvoiceRecordView),
    RouteDef(Routes.globalActivity, page: Globalactivity),
    RouteDef(Routes.warranty, page: WarrentyTrackerView),
    RouteDef(Routes.installation, page: InstallationTrackerView),
    RouteDef(Routes.roleEmployeeList, page: EmployeesListView),
    RouteDef(Routes.departmentHierarchy, page: DepartmentHierarchyView),
    RouteDef(Routes.introduction, page: IntroductionView),
    RouteDef(Routes.authSelectionView, page: AuthSelectionView),
    RouteDef(Routes.generalSetting, page: GeneralSettingView),
    RouteDef(Routes.languageSelection, page: LanguageSelectionView),
    RouteDef(Routes.machineOverview, page: MachineOverviewView),
    RouteDef(Routes.machineOverviewDetails, page: MachineOverviewDetailsView),
    RouteDef(Routes.reviewTicket, page: ReviewTicketView),
    RouteDef(Routes.notification, page: NotificationView),
    // TODO: Add the following route definitions when the corresponding views are created:

    // Processor Dashboard Routes
    // RouteDef(Routes.factoriesOverview, page: FactoriesOverviewView),
    // RouteDef(Routes.ticketsSummary, page: TicketsSummaryView),
    // RouteDef(Routes.financeSummary, page: FinanceSummaryView),
    // RouteDef(Routes.factoryPerformance, page: FactoryPerformanceView),
    // RouteDef(Routes.assignedMachines, page: AssignedMachinesView),
    // RouteDef(Routes.maintenanceStatus, page: MaintenanceStatusView),
    // RouteDef(Routes.lineProductionLog, page: LineProductionLogView),
    // RouteDef(Routes.inventoryRequests, page: InventoryRequestsView),
    // RouteDef(Routes.attendance, page: AttendanceView),
    // RouteDef(Routes.maintenanceSchedule, page: MaintenanceScheduleView),
    // RouteDef(Routes.sparePartsRequest, page: SparePartsRequestView),
    // RouteDef(Routes.machineDowntimeTracker, page: MachineDowntimeTrackerView),
    // RouteDef(Routes.dispatchTracker, page: DispatchTrackerView),
    // RouteDef(Routes.salesDashboard, page: SalesDashboardView),
    // RouteDef(Routes.productionReports, page: ProductionReportsView),

    // Manufacturer Dashboard Routes
    // RouteDef(Routes.engineerPerformance, page: EngineerPerformanceView),
    // RouteDef(Routes.mySchedule, page: MyScheduleView),
    // RouteDef(Routes.assignedInstallations, page: AssignedInstallationsView),
    // RouteDef(Routes.customerChecklist, page: CustomerChecklistView),
    // RouteDef(Routes.sitePhotosUpload, page: SitePhotosUploadView),
  ];
}

class RootWrapper extends StatefulWidget {
  final dynamic arguments;
  const RootWrapper({super.key, this.arguments});

  @override
  State<RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends State<RootWrapper> {
  final SecureApiService _secureApiService = locator<SecureApiService>();
  bool _hasRedirectedToUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runStartupAvailabilityCheck();
    });
  }

  Future<void> _runStartupAvailabilityCheck() async {
    bool shouldAllowAppEntry = true;

    try {
      shouldAllowAppEntry = await _secureApiService.isManufacturerEnabled();
    } catch (error) {
      AppLogger.warning(
        'Startup availability check failed. Allowing app entry. Error: $error',
      );
    }

    if (!mounted) return;

    if (!shouldAllowAppEntry) {
      _hasRedirectedToUpdate = true;
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.updateRequired,
        (Route<dynamic> route) => false,
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasRedirectedToUpdate) return;
      FirebaseNotificationService.handlePendingNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppViewModel>.nonReactive(
      viewModelBuilder: () => AppViewModel(),
      builder: (context, model, child) {
        if (model.isFirstTimeUser()) return model.homeNavigation();
        if (getUser().token?.isNotEmpty != true) return model.homeNavigation();

        // If logged in, we can use the arguments to set the tab
        final attributes = widget.arguments is StageViewAttributes
            ? widget.arguments as StageViewAttributes
            : StageViewAttributes(selectedBottomNavIndex: 0);

        return StageView(attributes: attributes);
      },
    );
  }
}
