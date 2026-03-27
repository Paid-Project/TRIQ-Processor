import 'package:get_it/get_it.dart';
import 'package:manager/configs.dart';
import 'package:manager/services/auth.service.dart';
import 'package:manager/services/contact.service.dart';
import 'package:manager/services/employee.service.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/notification.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:manager/services/sound_settings.service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:manager/services/task.service.dart';
import 'package:manager/services/team.service.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/services/user.service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../features/tickets/tickets_list/tickets_list.vm.dart';
import '../services/account.service.dart';
import '../services/api.service.dart';
import '../services/chat.service.dart';
import '../services/dashboard.service.dart';
import '../services/employee_profile.service.dart';
import '../services/file_picker.service.dart';
import '../services/language.service.dart';
import '../services/machine_storage.service.dart';
import '../services/customer.service.dart';
import '../services/machine_supplier.service.dart';
import '../services/machine_supplier_details.service.dart';
import '../services/customer_storage.service.dart';
import '../services/profile.service.dart';
import '../services/location.service.dart';
import '../services/organization_request.service.dart';
import '../services/secure_api_service.dart';


final GetIt locator = GetIt.instance;


void setUpLocators() {
  locator.registerLazySingleton(() => Configurations());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => OrganizationService());
  locator.registerLazySingleton(() => EmployeeService());
  locator.registerLazySingleton(() => MachineService());
  locator.registerLazySingleton(() => TicketService());
  locator.registerLazySingleton(() => ChatService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DashboardService());
  locator.registerLazySingleton(() => StageService());
  locator.registerLazySingleton(() => EmployeeProfileService());
  locator.registerLazySingleton(() => LanguageService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => AccountManagerService.instance);
  locator.registerLazySingleton(() => MachineStorageService());
  locator.registerLazySingleton(() => CustomerService());
  locator.registerLazySingleton(() => SecureApiService());
  locator.registerLazySingleton(() => FilePickerService());
  locator.registerLazySingleton(() => MachineSupplierService());
  locator.registerLazySingleton(() => MachineSupplierDetailsService());
  locator.registerLazySingleton(() => CustomerStorageService());
  locator.registerLazySingleton(() => ProfileService());
  locator.registerLazySingleton(() => TicketsListViewModel());
  locator.registerLazySingleton<TaskService>(() => TaskService());
  locator.registerLazySingleton(() => SoundSettingsService());
  locator.registerLazySingleton(() => TeamService());
  locator.registerLazySingleton(() => ContactService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => OrganizationRequestService());
}
