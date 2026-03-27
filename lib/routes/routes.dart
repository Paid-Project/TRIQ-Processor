/// **Routes**
///
/// This abstract class defines the named route constants used throughout the manager.
/// These constants help in navigation by providing a centralized location for managing routes.
///
/// ### **Usage Example:**
/// ```dart
/// Navigator.pushNamed(context, Routes.login);
/// ```
///
/// ### **Available Routes:**
/// - **`intro`** → `/intro` (Intro screen)
/// - **`login`** → `/login` (Login screen)
/// - **`register`** → `/register` (Registration screen)
abstract class Routes {
  /// Route for the root/initial screen.
  static const String root = '/';

  /// Route for the login screen.
  static const String login = '/login';
  static const String updateRequired = '/update-required';

  /// Route for the registration screen.
  static const String register = '/register';

  /// Route for the organization registration screen.
  static const String registerOrganization = '/registerOrganization';

  /// Route for the employee registration screen.
  static const String registerEmployee = '/registerEmployee';

  /// Route for the otp verification screen.
  static const String otpVerification = '/otpVerification';

  /// Route for the Organization Home screen.
  static const String organizationHome = '/organizationHome';

  /// Route for the Employee Home screen.
  static const String employeeHome = '/employeeHome';

  /// Route for the Customers List screen.
  static const String customersList = '/customersList';

  /// Route for the My Customers screen.
  static const String myCustomers = '/myCustomers';

  /// Route for the Machine Supplier screen.
  static const String machineSupplier = '/machineSupplier';

  /// Route for the Create New Customer screen.
  static const String createNewCustomer = '/createNewCustomer';

  /// Route for the Customer Details screen.
  static const String customerDetails = '/customerDetails';

  /// Route for the Tickets List screen.
  static const String ticketsList = '/ticketsList';

  /// Route for the Machines List screen.
  static const String machinesList = '/machinesList';

  static const String analytics = '/analyticsDashboard';

  static const String feedback = '/feedbackRatings';

  static const String invoice = '/piInvoiceRecords';

  static const String globalActivity = '/globalActivityFeed';

  static const String warranty = '/warrantyTracker';

  static const String installation = '/installationTracker';

  // **NEW ROUTES FROM DASHBOARD CARDS**

  /// Route for the Factories Overview screen.
  static const String factoriesOverview = '/factoriesOverview';

  /// Route for the Tickets Summary screen.
  static const String ticketsSummary = '/ticketsSummary';

  /// Route for the Finance Summary screen.
  static const String financeSummary = '/financeSummary';

  /// Route for the Factory Performance screen.
  static const String factoryPerformance = '/factoryPerformance';

  /// Route for the Assigned Machines screen.
  static const String assignedMachines = '/assignedMachines';

  /// Route for the Maintenance Status screen.
  static const String maintenanceStatus = '/maintenanceStatus';

  /// Route for the Line Production Log screen.
  static const String lineProductionLog = '/lineProductionLog';

  /// Route for the Inventory Requests screen.
  static const String inventoryRequests = '/inventoryRequests';

  /// Route for the Attendance screen.
  static const String attendance = '/attendance';

  /// Route for the Maintenance Schedule screen.
  static const String maintenanceSchedule = '/maintenanceSchedule';

  /// Route for the Spare Parts Request screen.
  static const String sparePartsRequest = '/sparePartsRequest';

  /// Route for the Machine Downtime Tracker screen.
  static const String machineDowntimeTracker = '/machineDowntimeTracker';

  /// Route for the Search Organization screen.
  static const String searchOrganization = '/searchOrganization';

  /// Route for the Dispatch Tracker screen.
  static const String dispatchTracker = '/dispatchTracker';

  /// Route for the Sales Dashboard screen.
  static const String salesDashboard = '/salesDashboard';

  /// Route for the Production Reports screen.
  static const String productionReports = '/productionReports';

  /// Route for the Engineer Performance screen.
  static const String engineerPerformance = '/engineerPerformance';

  /// Route for the My Schedule screen.
  static const String mySchedule = '/mySchedule';

  /// Route for the Assigned Installations screen.
  static const String assignedInstallations = '/assignedInstallations';

  /// Route for the Customer Checklist screen.
  static const String customerChecklist = '/customerChecklist';

  /// Route for the Site Photos Upload screen.
  static const String sitePhotosUpload = '/sitePhotosUpload';

  /// Route for the Profile screen.
  static const String profile = '/profile';

  /// Route for the QR screen.
  static const String qr = '/qr';

  /// Route for the CreateOrEditOrg screen.
  static const String updateOrg = '/updateOrg';

  static const String updateEmployee = '/updateEmployee';

  /// Route for the CreateOrEditTicket screen.
  static const String addTicket = '/addTicket';

  /// Route for the Tasks screen.
  static const String tasks = '/tasks';
  static const String createTask = '/createTask';

  /// Route for the Admin Managers List screen.
  static const String adminManagersList = '/adminManagersList';

  /// Route for the Stage screen.
  static const String stage = '/stage';

  /// Route for the Approval screen.
  static const String approval = '/approval';

  static const String chat = '/chat';
  static const String chatView = '/chatView';
  static const String chatsList = '/chatsList';
  static const String permissions = '/permissions';
  static const String createGroupChat = '/createGroupChat';
  static const scanQr = '/scanQR';
  static const scanCode = '/scanCode';

  static const addPartner = '/addPartner';

  static const employeesList = '/employeesList';

  static const addEmployee = '/addEmployee';

  static const addMachine = '/addMachine';

  static const String search = '/search';
  static const String archivedChats = '/archivedChats';
  static const String imageViewerView = '/imageViewerView';
  static const String employee = '/employee';
  static const String roleEmployeeList = '/roleEmployeeList';
  static const String departmentHierarchy = '/departmentHierarchy';
  static const String introduction = '/introduction';
  static const String authSelectionView = '/authSelectionView';
  static const String generalSetting = '/generalSetting';
  static const String languageSelection = '/languageSelection';

  static const String myWallet = '/myWallet';

  /// Route for the Machine Records screen.
  static const String machineRecords = '/machineRecords';
  static const String machineOverview = '/machine-overview';
  static const String machineOverviewDetails = '/machine-overview-details';
  static const String machineDetails = '/machineDetails';
  static const String addNewMachineModel = '/addNewMachineModel';
  static const String customerEditDetailsView = '/customerEditDetailsView';
  static const String reviewTicket = '/reviewTicket';
  static const String videoPlayer = '/videoPlayer';
  static const String ticketDetails = '/ticketDetails';
  static const String groupInfoScreen = '/groupInfoScreen';
  static const String teams = '/teams';
  static const String glassFlowSystem = '/glass-flow-system';
  static const String feedbackSurvey = '/survey';
  /// Route for the Notification screen.
  static const String notification = '/notification';
}
