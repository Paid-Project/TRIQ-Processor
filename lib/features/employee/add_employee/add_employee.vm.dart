import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:manager/core/models/designation.model.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/features/employee/add_employee/add_employee.view.dart';
import 'package:manager/features/employee/widgets/add_custom_role_dialog.dart';
import 'package:manager/features/employee/widgets/create_new_deparment.dart';
import 'package:manager/services/employee.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/machine.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/locator.dart';
import '../../../core/models/department.model.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/models/machine.dart';
import '../../../core/models/machine_model.dart';
import '../../../core/models/relationships.dart' hide Permissions;
import '../../../core/storage/storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/team.service.dart';
import '../../../widgets/common/custom_date_picker.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

enum ScreenMode { create, view, edit, partialAdd }

enum PermissionType {
  serviceDepartment,
  accessLevel,
  machineOperation,
  ticketManagement,
  approvalAuthority,
  reportAccess,
}

enum PermissionAccess { view, edit }

class AddEmployeeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _employeeService = locator<EmployeeService>();
  final _machineService = locator<MachineService>();
  final _filePickerService = locator<FilePickerService>();
  final _teamService = locator<TeamService>();
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController address_line_1Controller =
      TextEditingController();
  final TextEditingController address_line_2Controller =
      TextEditingController();
  final TextEditingController pr_cityController = TextEditingController();
  final TextEditingController pr_stateController = TextEditingController();
  final TextEditingController pr_countryController = TextEditingController();
  final TextEditingController pr_pincodeController = TextEditingController();
  final TextEditingController departmentNameController =
      TextEditingController();

  final TextEditingController emergency_nameController =
      TextEditingController();
  final TextEditingController emergency_mobileController =
      TextEditingController();
  final TextEditingController emergency_emailController =
      TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController designationNameController =
      TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController teamController = TextEditingController();
  final TextEditingController shiftTimingController = TextEditingController();
  final TextEditingController startDateTimeController = TextEditingController();
  final TextEditingController customFactoryLocationController =
      TextEditingController();
  final ReactiveValue<String> _employeeId = ReactiveValue('');
  final ReactiveValue<List<DepartmentModel>> _myDepartment = ReactiveValue([]);
  final ReactiveValue<DepartmentModel?> _selectedFactoryLocation =
      ReactiveValue(null);
  final ReactiveValue<bool> _isLoadingmyDepartment = ReactiveValue(false);
  final ReactiveValue<String?> _selectedEmploymentType = ReactiveValue(null);
  final ReactiveValue<String?> _selectedReportTo = ReactiveValue(null);
  final ReactiveValue<String> _shiftTiming = ReactiveValue('Morning');
  final ReactiveValue<List<Relationship>> _manufacturers = ReactiveValue([]);
  final ReactiveValue<List<Machine>> _machines = ReactiveValue([]);
  final ReactiveValue<List<DesignationModel>> _designations = ReactiveValue([]);
  final ReactiveValue<Relationship?> _selectedManufacturer = ReactiveValue(
    null,
  );
  final ReactiveValue<Machine?> _selectedMachine = ReactiveValue(null);
  final ReactiveValue<bool> _isLoadingManufacturers = ReactiveValue(false);
  final ReactiveValue<bool> _isLoadingReportTo = ReactiveValue(false);
  final ReactiveValue<Employee?> _selectedReportToEmployee = ReactiveValue(
    null,
  );
  final ReactiveValue<Permissions> _permissions = ReactiveValue<Permissions>(
    Permissions.initial(),
  );
  final ReactiveValue<List<Employee>> _reportToList = ReactiveValue([]);
  final ReactiveValue<ScreenMode> _screenMode = ReactiveValue<ScreenMode>(
    ScreenMode.create,
  );


  // Getter for the UI to access permissions
  Permissions get permissions => _permissions.value;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  String _countryCode = '';
  Country? _selectedCountry;
  Country? _selectedPersonalCountry;
  DesignationModel? _selectedDesignation;
  String? _selectedBloodGroup;

  // State management
  final ReactiveValue<String?> _selectedState = ReactiveValue<String?>(null);
  String? get selectedState => _selectedState.value;

  final ReactiveValue<String?> _selectedFactoryState = ReactiveValue<String?>(null);
  String? get selectedFactoryState => _selectedFactoryState.value;
  String _countrySearchQuery = '';
  bool _isPartialEdit = false;
  DateTime? startDateTime;
  late AddEmployeeViewAttributes _attributes;
  Employee? _employee;

  List<File> _pickedFiles = [];
  List<File> get pickedFiles => _pickedFiles;
  String get employeeId => _employeeId.value;
  String get shiftTiming => _shiftTiming.value;
  String? get selectedEmploymentType => _selectedEmploymentType.value;
  String? get selectedReportTo => _selectedReportTo.value;
  List<DepartmentModel> get myDepartment => _myDepartment.value;
  DepartmentModel? get selectedDepartment => _selectedFactoryLocation.value;
  bool get isLoadingmyDepartment => _isLoadingmyDepartment.value;
  Employee? get employee => _employee;
  Country? get selectedCountry => _selectedCountry;
  Country? get selectedPersonalCountry => _selectedPersonalCountry;
  DesignationModel? get selectedDesignation => _selectedDesignation;
  String? get selectedBloodGroup => _selectedBloodGroup;
  List<Relationship> get manufacturers => _manufacturers.value;
  List<Machine> get machines => _machines.value;
  List<DesignationModel> get designations => _designations.value;
  Relationship? get selectedManufacturer => _selectedManufacturer.value;
  Machine? get selectedMachine => _selectedMachine.value;
  bool get isLoadingManufacturers => _isLoadingManufacturers.value;
  bool get isLoadingReportTo => _isLoadingReportTo.value;
  Employee? get selectedReportToEmployee => _selectedReportToEmployee.value;

  ScreenMode get screenMode => _screenMode.value;
  String? _profilePhotoUrl;
  String? get profilePhotoUrl => _profilePhotoUrl;
  bool get isViewMode => _screenMode.value == ScreenMode.view;
  bool get isEditMode => _screenMode.value == ScreenMode.edit;
  bool get isCreateMode => _screenMode.value == ScreenMode.create;
  bool get isPartialyAdd => _screenMode.value == ScreenMode.partialAdd;
  bool get isPartialEdit => _isPartialEdit;
  List<Employee> get reportToList => _reportToList.value;
  List<String> selectedReportToIds = [];

  // Available states based on country
  List<String> _availableStates = _getStatesForCountry('India');
  List<String> get availableStates => _availableStates;

  List<String> _availableFactoryStates = _getStatesForCountry('India');
  List<String> get availableFactoryStates => _availableFactoryStates;

  final List<String> bloodGroups = [
    'O+',
    'A+',
    'B+',
    'AB+',
    'O-',
    'A-',
    'B-',
    'AB-',
  ];
  final List<String> shiftOptions = ['Morning', 'Evening', 'Night'];

  final List<String> employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Intern',
    'Consultant',
  ];
  // List of countries for dropdown (from country_state_city package)
  List<String> _countriesList = [];
  List<String> get countries {
    if (_countriesList.isEmpty) {
      _loadCountries();
      // Return a default list while loading
      return ['Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Argentina', 'Armenia', 'Australia',
        'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium',
        'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei',
        'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon', 'Canada', 'Chad', 'Chile', 'China',
        'Colombia', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic', 'Denmark', 'Djibouti',
        'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 'Estonia', 'Ethiopia', 'Fiji', 'Finland',
        'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Guatemala', 'Guinea',
        'Guyana', 'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland',
        'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kuwait', 'Kyrgyzstan',
        'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Lithuania', 'Luxembourg', 'Madagascar',
        'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Mauritania', 'Mauritius', 'Mexico', 'Moldova',
        'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nepal',
        'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia',
        'Norway', 'Oman', 'Pakistan', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines',
        'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saudi Arabia', 'Senegal', 'Serbia',
        'Singapore', 'Slovakia', 'Slovenia', 'Somalia', 'South Africa', 'South Korea', 'South Sudan', 'Spain',
        'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan',
        'Tanzania', 'Thailand', 'Togo', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Uganda',
        'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan',
        'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe'];
    }
    return _countriesList;
  }
  static List<String> _getStatesForCountry(String country) {
    // This is a synchronous fallback for initialization
    return [];
  }

  Future<void> _loadCountries() async {
    try {
      final countriesList = await csc.getAllCountries();
      _countriesList = countriesList.map((country) => country.name).toList()..sort();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error getting countries: $e');
    }
  }
  // Country dropdown
  final ReactiveValue<String> _country = ReactiveValue<String>('India');
  String get country => _country.value;
  void updateCountry(String? value) {
    if (value != null) {
      _country.value = value;
      countryController.text = value;
      notifyListeners();
    }
  }
  void init(AddEmployeeViewAttributes attributes) async {
    Get.put(this);
    _attributes = attributes;
    if (attributes.id?.isNotEmpty != true) {
      _screenMode.value = ScreenMode.create;

      await Future.wait([
        loadMyDepartment(),
        fetchCustomDesignation(),
        loadMachine(),
      ]);

      return;
    }

    if (attributes.id?.isNotEmpty == true) {
      if (attributes.isPartialAdd) {
        _screenMode.value = ScreenMode.view;
        _isPartialEdit = true;
      } else {
        _screenMode.value = ScreenMode.view;
      }

      setBusy(true);

      try {
        await Future.wait([loadMyDepartment(), fetchCustomDesignation()]);

        await loadEmployeeForEdit(attributes.id!);
      } catch (e) {
        AppLogger.error("Error in init: $e");
      } finally {
        setBusy(false);
      }
    } else {
      _screenMode.value = ScreenMode.create;
    }
  }

  void toggleReportTo(String id) {
    if (selectedReportToIds.contains(id)) {
      selectedReportToIds.remove(id);
    } else {
      selectedReportToIds.add(id);
    }
    notifyListeners();
  }
  void onCountryChanged(String country) async {
    // Clear current state
    _selectedState.value = null;
    stateController.clear();
    _availableStates = [];
    notifyListeners();

    // First, try to load from package asynchronously
    try {
      final packageStates = await _getStatesForCountryAsync(country);
      if (packageStates.isNotEmpty) {
        _availableStates = packageStates;
        notifyListeners();
        //  AppLogger.info('Loaded ${packageStates.length} states from package for $country');
      }
    } catch (e) {
      //  AppLogger.error('Error fetching states from package: $e');
    }
  }
  Future<void> loadEmployeeForEdit(String employeeId) async {
    try {
      final result = await _employeeService.getEmployeeById(employeeId);

      result.fold(
        (failure) {
          Fluttertoast.showToast(msg: failure.message.toString());
          _navigationService.back();
        },
        (employee) async {
          _employee = employee;

          AppLogger.info("=== LOADING EMPLOYEE DATA ===");

          // ============ BASIC EMPLOYEE DETAILS ============
          nameController.text = employee.name?.trim() ?? '';
          emailController.text = employee.email?.trim() ?? '';
          phoneController.text = employee.phone?.trim() ?? '';
          employeeIdController.text = employee.employeeId?.trim() ?? '';
          customFactoryLocationController.text = employee.area?.trim() ?? '';

          if (employee.bloodGroup != null && employee.bloodGroup!.isNotEmpty) {
            _selectedBloodGroup = employee.bloodGroup!.trim();
            AppLogger.info("Blood group set to: $_selectedBloodGroup");
          }

          if (employee.profilePhoto != null &&
              employee.profilePhoto!.isNotEmpty) {
            _profilePhotoUrl = employee.profilePhoto;
            AppLogger.info("Profile photo URL: $_profilePhotoUrl");
          }

          if (employee.employeeType != null &&
              employee.employeeType!.isNotEmpty) {
            final normalizedType = employee.employeeType!.trim();
            if (employmentTypes.contains(normalizedType)) {
              _selectedEmploymentType.value = normalizedType;
            } else {
              try {
                _selectedEmploymentType.value = employmentTypes.firstWhere(
                  (type) => type.toLowerCase() == normalizedType.toLowerCase(),
                );
              } catch (e) {
                employmentTypes.add(normalizedType);
                _selectedEmploymentType.value = normalizedType;
              }
            }
            AppLogger.info(
              "Employment type set to: ${_selectedEmploymentType.value}",
            );
          }

          if (employee.shiftTiming != null &&
              employee.shiftTiming!.isNotEmpty) {
            _shiftTiming.value = employee.shiftTiming!.trim();
            shiftTimingController.text = employee.shiftTiming!.trim();
            AppLogger.info("Shift timing set to: ${_shiftTiming.value}");
          }

          // Joining Date
          if (employee.joiningDate != null) {
            try {
              startDateTime = DateTime.parse(employee.joiningDate!);
              startDateTimeController.text = startDateTime!
                  .toLocal()
                  .toIso8601String()
                  .substring(0, 10);
              AppLogger.info(
                "Joining date set to: ${startDateTimeController.text}",
              );
            } catch (e) {
              AppLogger.error("Error parsing joining date: $e");
              startDateTime = null;
              startDateTimeController.text = '';
            }
          }



          // ============ DEPARTMENT ============
          if (employee.department != null && _myDepartment.value.isNotEmpty) {
            try {
              final dept = _myDepartment.value.firstWhere(
                (d) => d.id == employee.department!.id,
                orElse: () {
                  AppLogger.error(
                    "Department not found: ${employee.department!.id}",
                  );
                  return _myDepartment.value.first;
                },
              );
              _selectedFactoryLocation.value = dept;
              AppLogger.info("Department set to: ${dept.name}");
            } catch (e) {
              AppLogger.error("Error setting department: $e");
            }
          }

          // ============ DESIGNATION ============
          if (employee.designation != null && _designations.value.isNotEmpty) {
            try {
              final desig = _designations.value.firstWhere(
                (d) => d.id == employee.designation!.id,
                orElse: () {
                  AppLogger.error(
                    "Designation not found: ${employee.designation!.id}",
                  );
                  return _designations.value.first;
                },
              );
              _selectedDesignation = desig;
              AppLogger.info("Designation set to: ${desig.name}");
            } catch (e) {
              AppLogger.error("Error setting designation: $e");
            }
          }

          // ============ PERSONAL ADDRESS ============
          if (employee.personalAddress != null) {
            final address = employee.personalAddress!;

            address_line_1Controller.text = address.addressLine1?.trim() ?? '';
            address_line_2Controller.text = address.addressLine2?.trim() ?? '';
            pr_cityController.text = address.city?.trim() ?? '';
            pr_stateController.text = address.state?.trim() ?? '';
            pr_pincodeController.text = address.pincode?.trim() ?? '';


          }

          // ============ EMERGENCY CONTACT ============
          if (employee.emergencyContact != null) {
            final emergency = employee.emergencyContact!;

            emergency_nameController.text =
                emergency.emergencyContactName?.trim() ?? '';
            emergency_mobileController.text =
                emergency.emergencyContactPhone?.trim() ?? '';
            emergency_emailController.text =
                emergency.emergencyContactEmail?.trim() ?? '';
          } else {
            AppLogger.warning("No emergency contact data found");
          }

          if (employee.permissions != null) {
            // Create permissions with explicit null checks
            final loadedPermissions = Permissions(
              serviceDepartment: PermissionDetail(
                view: employee.permissions!.serviceDepartment?.view ?? false,
                edit: employee.permissions!.serviceDepartment?.edit ?? false,
              ),
              accessLevel: PermissionDetail(
                view: employee.permissions!.accessLevel?.view ?? false,
                edit: employee.permissions!.accessLevel?.edit ?? false,
              ),
              machineOperation: PermissionDetail(
                view: employee.permissions!.machineOperation?.view ?? false,
                edit: employee.permissions!.machineOperation?.edit ?? false,
              ),
              ticketManagement: PermissionDetail(
                view: employee.permissions!.ticketManagement?.view ?? false,
                edit: employee.permissions!.ticketManagement?.edit ?? false,
              ),
              approvalAuthority: PermissionDetail(
                view: employee.permissions!.approvalAuthority?.view ?? false,
                edit: employee.permissions!.approvalAuthority?.edit ?? false,
              ),
              reportAccess: PermissionDetail(
                view: employee.permissions!.reportAccess?.view ?? false,
                edit: employee.permissions!.reportAccess?.edit ?? false,
              ),
            );

            _permissions.value = loadedPermissions;
          } else {
            AppLogger.warning(
              "No permissions in employee response, using defaults",
            );
            _permissions.value = Permissions.initial();
          }

          if (_selectedDesignation != null &&
              _selectedFactoryLocation.value != null) {
            // Load the report to list
            await loadReportToList();

            // Small delay to ensure list is loaded
            await Future.delayed(Duration(milliseconds: 200));

            // Set selected report to
            if (employee.reportTo != null &&
                employee.reportTo!.isNotEmpty &&
                _reportToList.value.isNotEmpty) {
              try {
                // Find the employee in the list by ID
                final reportToIndex = _reportToList.value.indexWhere(
                  (e) => e.id == employee.reportTo,
                );

                if (reportToIndex != -1) {
                  // Use the exact object from the list
                  _selectedReportToEmployee.value =
                      _reportToList.value[reportToIndex];
                  _selectedReportTo.value =
                      _reportToList.value[reportToIndex].name;
                } else {
                  _selectedReportToEmployee.value = null;
                }
              } catch (e) {
                _selectedReportToEmployee.value = null;
              }
            } else {
              if (employee.reportTo == null || employee.reportTo!.isEmpty) {
              } else if (_reportToList.value.isEmpty) {
                AppLogger.warning("Report to list is empty");
              }
            }
          } else {
            AppLogger.warning(
              "Cannot load report to - designation: ${_selectedDesignation?.name}, department: ${_selectedFactoryLocation.value?.name}",
            );
          }

          // Force UI update
          notifyListeners();

          AppLogger.info("=== EMPLOYEE DATA LOADING COMPLETE ===");
        },
      );
    } catch (e) {
      AppLogger.error("Error loading employee: $e");
      Fluttertoast.showToast(msg: "Failed to load employee details");
      _navigationService.back();
    }
  }

  // Update loadReportToList to be more robust:
  Future<void> loadReportToList() async {
    AppLogger.info("loadReportToList called");

    if (_selectedDesignation == null ||
        _selectedFactoryLocation.value == null) {
      AppLogger.warning(
        "Cannot load report to list - missing designation or department",
      );
      _reportToList.value = [];
      notifyListeners();
      return;
    }

    _isLoadingReportTo.value = true;
    notifyListeners();

    try {
      AppLogger.info(
        "Fetching report to list for designation: ${_selectedDesignation!.id}, department: ${_selectedFactoryLocation.value!.id}",
      );

      final result = await _employeeService.getEligibleReportToList(
        designationId: _selectedDesignation!.id,
        departmentId: _selectedFactoryLocation.value!.id!,
      );

      result.fold(
        (failure) {
          AppLogger.error(
            "API Error loading report to list: ${failure.message}",
          );
          _reportToList.value = [];
        },
        (employees) {
          AppLogger.info(
            "Successfully loaded ${employees.length} employees for report to",
          );
          _reportToList.value = employees;

          // Log employee details for debugging
          for (var emp in employees) {
            AppLogger.info("Report to option: ${emp.name} (ID: ${emp.id})");
          }
        },
      );
    } catch (e) {
      AppLogger.error("Exception loading report to list: $e");
      _reportToList.value = [];
    } finally {
      _isLoadingReportTo.value = false;
      notifyListeners();
    }
  }

  void updatePermissions(Permissions newPermissions) {
    _permissions.value = newPermissions;
    notifyListeners();
  }

  void switchToEditMode() {
    if (isViewMode) {
      _screenMode.value = ScreenMode.edit;
      notifyListeners();
    }
  }

  void updatePermission(
    PermissionType type,
    PermissionAccess access,
    bool? value,
  ) {
    if (value == null) return;

    // current state ko copy karke naya object banayein
    var currentPerms = _permissions.value;

    // Kaunsa permission update karna hai, use 'switch' se decide karein
    switch (type) {
      case PermissionType.serviceDepartment:
        currentPerms = currentPerms.copyWith(
          serviceDepartment: (currentPerms.serviceDepartment ??
                  PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.serviceDepartment?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.serviceDepartment?.edit,
              ),
        );
        break;
      case PermissionType.accessLevel:
        currentPerms = currentPerms.copyWith(
          accessLevel: (currentPerms.accessLevel ?? PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.accessLevel?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.accessLevel?.edit,
              ),
        );
        break;
      case PermissionType.machineOperation:
        currentPerms = currentPerms.copyWith(
          machineOperation: (currentPerms.machineOperation ??
                  PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.machineOperation?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.machineOperation?.edit,
              ),
        );
        break;
      case PermissionType.ticketManagement:
        currentPerms = currentPerms.copyWith(
          ticketManagement: (currentPerms.ticketManagement ??
                  PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.ticketManagement?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.ticketManagement?.edit,
              ),
        );
        break;
      case PermissionType.approvalAuthority:
        currentPerms = currentPerms.copyWith(
          approvalAuthority: (currentPerms.approvalAuthority ??
                  PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.approvalAuthority?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.approvalAuthority?.edit,
              ),
        );
        break;
      case PermissionType.reportAccess:
        currentPerms = currentPerms.copyWith(
          reportAccess: (currentPerms.reportAccess ??
                  PermissionDetail.initial())
              .copyWith(
                view:
                    access == PermissionAccess.view
                        ? value
                        : currentPerms.reportAccess?.view,
                edit:
                    access == PermissionAccess.edit
                        ? value
                        : currentPerms.reportAccess?.edit,
              ),
        );
        break;
    }

    _permissions.value = currentPerms;
    notifyListeners();
  }

  List<String> getRelationshipTypesForRole(UserRole? role) {
    List<String> relationshipTypes = [];
    if (role == UserRole.plantHead) {
      relationshipTypes = ["Director / Factory Owner"];
    } else if (role == UserRole.lineInCharge) {
      relationshipTypes = ["Director / Factory Owner", "Plant Head"];
    } else if (role == UserRole.maintenanceHead) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
      ];
    } else if (role == UserRole.maintenanceEngineer) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
      ];
    } else if (role == UserRole.machineOperator) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
        "Maintenance Engineer",
      ];
    } else if (role == UserRole.labour) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Plant Head",
        "Line InCharge",
        "Maintenance Head",
        "Maintenance Engineer",
        "Machine Operator",
      ];
    } else if (role == UserRole.headOfGlobalService) {
      relationshipTypes = ["Director / Factory Owner"];
    } else if (role == UserRole.countryServiceManager) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
      ];
    } else if (role == UserRole.localServiceEngineers) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
        "Country Service Manager",
      ];
    } else if (role == UserRole.installationEngineers) {
      relationshipTypes = [
        "Director / Factory Owner",
        "Head of Global Service",
        "Country Service Manager",
        "Local Service Engineers",
      ];
    }

    return relationshipTypes;
  }

  void updateCountrySearchQuery(String query) {
    _countrySearchQuery = query;
    notifyListeners();
  }

  void updateSelectedEmploymentType(String? type) {
    _selectedEmploymentType.value = type;
    notifyListeners();
  }

  void updateSelectedReportTo(Employee employee, String? type) {
    _selectedReportTo.value = type;
    _selectedReportToEmployee.value = employee;
    notifyListeners();
  }

  void updateSelectedCountry(Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void updateSelectedPersonalCountry(Country? country) {
    _selectedPersonalCountry = country;
    notifyListeners();
  }

  void updateSelectedDesignation(DesignationModel? designation) {
    _selectedDesignation = designation;
    if (_selectedDesignation != null &&
        _selectedFactoryLocation.value != null) {
      loadReportToList();
    }
    notifyListeners();
  }

  void updateSelectedBloodGroup(String? val) {
    _selectedBloodGroup = val ?? '';
    notifyListeners();
  }

  void updateSelectedShift(String? shift) {
    _shiftTiming.value = shift ?? '';
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _countryCode = phoneNumber.countryCode;
  }

  void onSave(GlobalKey<FormState> formKey) async {
    formKey.currentState?.validate();

    if (formKey.currentState?.validate() ?? false) {
      await submitDetails(formKey);
    } else {
      Fluttertoast.showToast(msg: 'Please fill in all required fields');
    }
  }

  Future<void> selectStartDateTime(BuildContext context) async {
    final DateTime? date = await CustomDatePicker.show(
      context: context,
      initialDate: startDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // future date disable
    );

    if (date != null) {
      startDateTimeController.text = date.toLocal().toIso8601String().substring(
        0,
        10,
      );
      startDateTime = date;
      notifyListeners();
    }
  }

  //
  // void updateSelectedRole(UserRole? role) {
  //   selectedRole = role;
  //
  //   if (role == UserRole.plantHead || role == UserRole.maintenanceHead) {
  //     canViewCalendar = true;
  //     canAssignTasks = true;
  //     canViewPerformance = true;
  //     canApproveExpenses = role == UserRole.plantHead;
  //     canApproveTimeOff = role == UserRole.plantHead;
  //   } else if (role == UserRole.maintenanceEngineer) {
  //     canViewCalendar = true;
  //     canAssignTasks = false;
  //     canViewPerformance = false;
  //     canApproveExpenses = false;
  //     canApproveTimeOff = false;
  //   } else {
  //     canViewCalendar = false;
  //     canAssignTasks = false;
  //     canViewPerformance = false;
  //     canApproveExpenses = false;
  //     canApproveTimeOff = false;
  //   }
  //
  //   notifyListeners();
  //   _updateFormValidity();
  // }
  static Future<List<String>> _getStatesForCountryAsync(String country) async {
    try {
      // Get all countries first
      final allCountries = await csc.getAllCountries();

      // Find the matching country
      final matchedCountry = allCountries.firstWhere(
            (c) => c.name.toLowerCase() == country.toLowerCase(),
        orElse: () => allCountries.firstWhere(
              (c) => c.name.toLowerCase().contains(country.toLowerCase()),
          orElse: () => csc.Country(
              name: '',
              isoCode: '',
              phoneCode: '',
              currency: '',
              latitude: '',
              longitude: '',
              flag: ''
          ),
        ),
      );

      if (matchedCountry.isoCode.isNotEmpty) {
        // Get states for the country using ISO code
        final states = await csc.getStatesOfCountry(matchedCountry.isoCode);
        if (states.isNotEmpty) {
          return states.map((state) => state.name).toList()..sort();
        }
      }

      // Fallback to empty list if no states found
      return [];
    } catch (e) {
      //  AppLogger.error('Error getting states from country_state_city: $e');
      return [];
    }
  }
  Future<void> loadMyDepartment() async {
    _isLoadingmyDepartment.value = true;
    notifyListeners();
    _isLoadingReportTo.value = true;
    reportToList.clear();
    _selectedReportToEmployee.value = null;
    _isLoadingReportTo.value = false;

    try {
      final result = await _teamService.getAllDepartments();
      final response = await _teamService.getAllDepartments();
      if (response.success && response.data != null) {
        _myDepartment.value = response.data!;
      } else {}
    } catch (e) {
      AppLogger.error("Error loading getAllDepartments: $e");
      Fluttertoast.showToast(
        msg: "Error loading getAllDepartments",
        backgroundColor: Colors.red,
      );
    }

    _isLoadingmyDepartment.value = false;
    notifyListeners();
    notifyListeners();
  }

  Future<void> loadMachine() async {
    dynamic result;
    try {
      result = await _machineService.getMyCustomerMachines();
      result.fold(
        (exception) {
          Fluttertoast.showToast(msg: exception.message.toString());
          _machines.value = [];
        },
        (List<Machine>? machinesListInfo) {
          _machines.value = machinesListInfo ?? [];
        },
      );
    } catch (e) {
      AppLogger.error("Error loading getAllDepartments: $e");
    }

    notifyListeners();
  }

  void updateSelectedDepartment(DepartmentModel? location) {
    selectedReportToIds = [];
    if (location?.id == 'new') {
      // showCreateDepartmentDialog(context, viewModel)
    } else if (location != null) {
      _selectedFactoryLocation.value = location;
      _selectedDesignation = null;
      fetchCustomDesignation();
    }
    if (_selectedDesignation != null &&
        _selectedFactoryLocation.value != null) {
      loadReportToList();
    }
    notifyListeners();
  }

  void updateSelectedMachine(Machine? machine) {
    if (machine?.id == 'new') {
      // showCreateDepartmentDialog(context, viewModel)
    } else if (machine != null) {
      _selectedMachine.value = machine;
    }

    notifyListeners();
  }

  void updateCustomFactoryLocation(String value) {
    customFactoryLocationController.text = value;
    notifyListeners();
  }

  void resetSelections() {
    _selectedManufacturer.value = null;
    _selectedMachine.value = null;
    _machines.value = [];
    notifyListeners();
  }

  bool get isSelectionValid => _selectedMachine.value != null;

  Future<void> pickMedia() async {
    final result = await _filePickerService.pickImageFromGallery();
    List<File> files = [];
    result.fold((failure) {}, (response) {
      files = [response];
    });
    if (files.isNotEmpty) {
      _pickedFiles.addAll(files);
      notifyListeners();
    }
  }

  void removeFile(int index) {
    _pickedFiles.removeAt(index);
    notifyListeners();
  }

  void showAddCustomRoleDialog(BuildContext context) {
    showCreateCustomRoleDialog(context, this);
  }

  Future<void> fetchCustomDesignation() async {

// 1. Pehle check karein ki data hai ya nahi
    if (_designations.value.isNotEmpty) {
      _designations.value.clear();

      // Agar aap GetX use kar rahe hain, toh UI update ke liye refresh zaruri ho sakta hai
      // _designations.refresh();
    }
    try {
      final response = await _employeeService.getCustomDesignation(_selectedFactoryLocation.value?.id??"6993060ed2804aa2bf435afb");
      if (response.success && response.data != null) {
        _designations.value = response.data!;
      } else {}
    } catch (e) {}
  }

  /// Creates a new department
  Future<void> createNewDesignation() async {
    if (designationNameController.text.trim().isEmpty) {
      AppLogger.error('Department name cannot be empty.');
      return;
    }

    // Use a specific busy key for the dialog loader
    setBusyForObject('dialog', true);

    try {
      final response = await _employeeService.addCustomDesignation(
        designationNameController.text.trim(),
      );

      if (response.success) {
        Get.back();
        designationNameController.clear();
        await fetchCustomDesignation(); // Refresh the list
        Fluttertoast.showToast(
          msg: response.message ?? 'Department created successfully.',
          backgroundColor: AppColors.success,
        );
      } else {
        AppLogger.error(response.message ?? 'Failed to create department.');
      }
    } catch (e) {
      AppLogger.error('An unexpected error occurred: $e');
    }

    // Turn off dialog loader
    setBusyForObject('dialog', false);
  }

  showCreateDepartmentDialog(BuildContext context) {
    showAddDepartmentDialog(context, this);
  }

  Future<void> createNewDepartment() async {
    if (departmentNameController.text.trim().isEmpty) {
      AppLogger.error('Department name cannot be empty.');
      return;
    }

    // Use a specific busy key for the dialog loader
    setBusyForObject('dialog', true);

    try {
      final response = await _teamService.addNewDepartment(
        departmentNameController.text.trim(),
      );

      if (response.success) {
        Get.back();
        departmentNameController.clear();
        loadMyDepartment();

        Fluttertoast.showToast(
          msg: response.message ?? 'Department created successfully.',
          backgroundColor: AppColors.success,
        );
      } else {
        AppLogger.error(response.message ?? 'Failed to create department.');
      }
    } catch (e) {
      AppLogger.error('An unexpected error occurred: $e');
    }

    // Turn off dialog loader
    setBusyForObject('dialog', false);
  }
  void updateState(String? value) {
    _selectedState.value = value;
    stateController.text = value ?? '';
    notifyListeners();
  }
  Future<void> submitDetails(GlobalKey<FormState> formKey) async {
    // 1. ========= VALIDATE THE FORM ==================
    if (!(formKey.currentState?.validate() ?? false)) {
      Fluttertoast.showToast(
        msg: 'Please fill all the required fields correctly.',
      );
      return;
    }
    // Check other required selections
    if (_selectedDesignation == null) {
      Fluttertoast.showToast(msg: 'Please select a designation.');
      return;
    }
    if (_selectedFactoryLocation.value == null) {
      Fluttertoast.showToast(msg: 'Please select a department.');
      return;
    }
    if (startDateTime == null) {
      Fluttertoast.showToast(msg: 'Please select a joining date.');
      Fluttertoast.showToast(msg: 'Please select a joining date.');
      return;
    }

    // 2. ========= DEFINE THE BACKGROUND TASK ==================
    // This async function will be executed by the loader dialog.
    // Its only job is to perform the API call and return true or false.
    Future<bool> createEmployeeTask() async {
      try {
        AppLogger.info(
          'address_line_2Controller.text= ${address_line_2Controller.text}',
        );

        // Prepare data
        final personalAddress = PersonalAddress(
          addressLine1: address_line_1Controller.text.trim(),
          addressLine2: address_line_2Controller.text.trim(),
          city:  cityController.text.trim(),
          state: stateController.text.trim(),
          country: _country.value ?? 'IN',
          pincode:  pinCodeController.text.trim(),
        );

        final emergencyContact = EmergencyContact(
          emergencyContactName: emergency_nameController.text.trim(),
          emergencyContactPhone: emergency_mobileController.text.trim(),
          emergencyContactEmail: emergency_emailController.text.trim(),
        );

        // API call
        bool success = await _employeeService.createEmployee(
          isUpdate: !isCreateMode,
          id: _employee?.id,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          employeeId: employeeIdController.text.trim(),
          departmentId: _selectedFactoryLocation.value!.id!,
          designationId: _selectedDesignation!.id,
          joiningDate: startDateTimeController.text,
          bloodGroup: _selectedBloodGroup,
          country: _selectedCountry?.code,
          area: customFactoryLocationController.text.trim(),
          reportTo:selectedReportToIds,
          employeeType: _selectedEmploymentType.value,
          shiftTiming: _shiftTiming.value,
          personalAddress: personalAddress,
          emergencyContact: emergencyContact,
          permissions: _permissions.value,
          profilePhoto: _pickedFiles.isNotEmpty ? _pickedFiles.first : null,
          machineId: _selectedMachine.value?.id ?? '',
        );

        // Just return the result
        return success;
      } catch (e, s) {
        AppLogger.error('Error during employee creation task: $e\n$s');
        // If any error happens during the task, return false.
        return false;
      }
    }

    // 3. ========= SHOW LOADER AND AWAIT RESULT ==================
    // Show the loader dialog and wait for it to close.
    // It will return a DialogResponse object.
    final dialogResponse = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: createEmployeeTask, // Pass the function to be executed.
      ),
      barrierDismissible: false,
    );

    // 4. ========= HANDLE THE RESULT AFTER THE LOADER IS GONE ==================
    // Check if the dialog was completed and returned a boolean.
    if (dialogResponse?.confirmed == true && dialogResponse?.data is bool) {
      bool wasSuccessful = dialogResponse!.data;

      if (wasSuccessful) {
        // SUCCESS CASE: Show the success dialog, then navigate back.
        await _dialogService.showCustomDialog(
          variant: DialogType.success,
          title:
              isEditMode
                  ? 'Employee Updated!'
                  : 'Employee Created Successfully!',
          description:
              isEditMode
                  ? ''
                  : 'Please ask your employee to log in using their registered mobile number.',
          barrierDismissible: false,
        );

        _navigationService.back(result: true);
      } else {
        // FAILURE CASE: Show a failure message. The user stays on the page.
        Fluttertoast.showToast(
          msg: 'Failed to save details. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } else {
      // UNEXPECTED CASE: This happens if the dialog was cancelled or something went wrong.
      Fluttertoast.showToast(
        msg: 'Operation cancelled or an unexpected error occurred.',
        backgroundColor: Colors.red,
      );
    }
  }
}
