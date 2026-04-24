/// **ApiEndpoints**
///
/// This abstract class defines the API endpoint constants used throughout the manager.
/// Centralizing API endpoints in a single class ensures maintainability and avoids hardcoded strings.
///
/// ### **Usage Example:**
/// ```dart
/// final response = await apiClient.get(ApiEndpoints.user);
/// ```
///
/// ### **Available Endpoints:**
/// - **`user`** → `user` (Endpoint for user-related operations)
abstract class ApiEndpoints {

  static const String image_base = 'https://live.triqinnovations.com/';
  static const String register = 'auth/register';
  static const String verifyEmail = 'auth/verify-email';
  static const String loginWithOtp = 'auth/loginWithOtp';
  static const String forgotPassword = 'auth/forgot-password';
  static const String deleteUser = 'auth/delete-user/';
  static const String checkPassword = 'auth/check-password';
  static const String sendOtp = 'auth/send-otp';
  static const String otpLogin = 'auth/otp-login';
  static const String resetPassword = 'auth/reset-password';
  static const String resetNewPassword = 'auth/resetNewPassword';
  static const String googleLogin = 'auth/google-login';
  static const String sendOtpForLogin = 'auth/sendOtpForLogin';
  static const String facebookLogin = 'auth/facebook-login';
  static const String logout = 'auth/logout';
  static const String send_email_varification = 'auth/send-verify-email';

  static const String addPartner = 'org/add-partner';
  static const String addNewPartner = 'org/add-new';
  static const String addManufacturer = 'org/add-manufacturer';
  static const String getPartners = 'org/partnerships';
  static const String getEmployees = 'employee/org';
  static const String employee = 'employee';
  // static const String allEmployee = 'employee/get-all';
  static const String getAttachments = 'groupChatMessage/attachments';
  static const String addNewEmployee = 'employee/add-new';
  static const String login = 'auth/login';
  static const String acceptRequest = 'org/accept-partner';
  static const String declineRequest = 'org/reject-partner';
  static const String machine = 'machines';
  static const String createMachine = 'machines/create';
  static const String assignMachine = 'machine/assign-machine';

  static const String getChatId = 'chat/room-create';
  static const String getGroupChatMessage = 'groupChatMessage/messages';
  static const String sendMessage = 'chat/room';
  static const String sendVChatStatus = 'livekit/create-session';
  static const String archiveChatRoom = 'chat/rooms-archive';
  static const String getAllChats = 'chat/getAllChats';
  static const String getAllChatMessages = 'chat/messages';
  static const String uploadChatFile = 'chat/upload/chat';
  static const String editMessages = 'chat/messages';
  static const String deleteMessages = 'chat/deleteMessages';

  // static const String chatRooms = 'chat/rooms';
  // static const String externalChatRooms = 'auth/rooms-external';
  static const String createIndividualChatRoom = 'chat/room-create-individual';

  static const String getMyMachines = 'machine/my-machines';
  static const String getMyCustomerMachines = 'customers/getMyMachines';
  static const String org = 'org/partner-by-id';
  static const String dashboard = 'dashboard';
  static const String tickets = 'ticket';
  static const String pingTicket = 'ticket/ping';
  static const String holdTicket = 'ticket/status';
  static const String uploadImages = 'upload/images';
  // static const String profile = 'auth/profile';
  ////leave Group
  static const String leaveGroup = 'groupChat/leave/';
  static const String addMembers = 'groupChat/add-members/';
  // static const String updateFcmToken = 'auth/update-fcm-token';
  static const String resolveTicket = 'ticket/resolve';
  static const String requestResolveTicket = 'ticket/resolve-request';
  static const String rejectResolveTicket = 'ticket/forbid-resolve-request';
  static const String removeProcessor = 'org/remove';

  static const String getCustomers = 'customers/get-customers';
  static const String getCustomerById = 'customers/getCustomerById';
  static const String createCustomer = 'customers/create-customer';
  static const String updateCustomer = 'customers/update-customer';
  static const String deleteCustomer = 'customers/delete-customer';
  static const String searchCustomers = 'customers/search-customers';
  static const String removeMachine = 'customers/remove-machine';
  static const String getAllMachines = 'machines/getAll';
  static const String deleteMachine = 'machines/delete';
  static const String getMachineSupplier = 'machinesupplier/getMachineSupplier';
  static const String getMachineOverview = 'machinesupplier/getMachineOverview';
  static const String getMachineById = 'machines/getById';
  static const String createTicket = 'ticket/create';
  static const String updateTicket = 'ticket/update';
  static const String getAllTickets = 'ticket/getAll';
  static const String getTicketsByStatus = 'ticket/getticket';
  static const String getTicketSummary = 'ticket/getTicketSummary';
    static const String getUnreadNotificationCount = 'notification/unreadnotificationcount';
    static const String getMarkNotificationAsRead = 'notification/markNotificationAsRead';

  // Service Pricing endpoints
  static const String createServicePricing = 'servicePricing/create';
  static const String getAllServicePricing = 'servicePricing/getAll';
  static const String getViewers = 'groupChatMessage/viewers/';
  static const String getIndicator = 'dashboard/indicator';
  static const String mark_seen = 'dashboard/mark-seen';
  // Report endpoints
  static const String reportProblem = 'report/report-problem';
  static const String sendFeedback = 'report/send-feedback';

  // Profile endpoints
  static const String getProfile = 'profile/get-profile';
  static const String getProfileDetails = 'profile/get-profiledetails';
  static const String updateProfile = 'profile/update-profile';
  static const String links = 'links';
  // Notification endpoints
  static const String sendOrganizationRequest = 'notification/sendorganizationrequest';
  static const String getNotifications = 'notification/getnotification';
  static const String deleteNotification = 'notification/deleteNotification';
  static const String updateNotification = 'notification/updateticketnotification';
  static const String sendCreateNotification = 'ticket/sendCreatedTicketNotification';


  // Task Endpoints
  static const String getAllTasks = 'task/getAllTask';
  static const String createTask = 'task/create-task';
  static const String soundSettingsUpdate = 'notificationsound/updateSound';
  static const String soundSettingsGet = 'notificationsound/getSound';


  // Employee
  static const String getAllEmployee = 'employee/getAllEmployee';
  static const String addEmployee = 'employee/add';
  static const String searchEmployee = 'employee/searchEmployee';
  static const String getEmployeeById = 'employee/getEmployeeById';
  static const String updateEmployeeById = 'employee/update/';
  static const String getCustomDesignation = 'designation/getAllDepartment';
  static const String addCustomDesignation = 'designation/add';
  static const String getEligibleReportToList = 'employee/getEligibleReportToList';
  static const String getEmployeeHierarchy = 'employee/getEmployeeHierarchy';

  // Team Module
  static const String addDepartment = 'department/add';
  static const String getAllDepartment = 'department/getAllDepartment';

  // Contact
  static const String getAllContact = 'contact/getAllContact/';
  static const String addContact = 'contact/add';
  static const String searchContact = 'contact/searchContacts';
  static const String sendExternalChatRequest = 'contact/sendExternalEmployeeRequest';
  static const String getAllContactChatMessages = 'contactChat/getContactChatMessages';
  static const String uploadChatContactFile = 'chat/upload/contactChat';

  //Video Audio chat
  static const String livekit_endpoint = 'wss://livekit.triqinnovations.com';

  // Location endpoints (NEW - for address management)
  static const String getStatesByCountry = 'location/states-by-country';
  static const String getCitiesByState = 'location/cities-by-state';

  // Notification Action endpoints (NEW - for organization requests)
  static const String acceptOrganizationRequest = 'notification/accept-organization-request';
  static const String rejectOrganizationRequest = 'notification/reject-organization-request';
  
  // Machine Assignment Response endpoint (NEW - for machine request notifications)
  static const String respondMachineAssignment = 'customers/respond-machine-assignment';
  static const String ipAddressCheckGet = 'https://checkip.amazonaws.com/';
}
