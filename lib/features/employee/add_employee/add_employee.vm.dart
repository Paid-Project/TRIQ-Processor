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
  final ReactiveValue<String?> _selectedPrState = ReactiveValue<String?>(null);
  String? get selectedPrState => _selectedPrState.value;
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
  void updatePrState(String? value) {
    _selectedPrState.value = value;
    if (value != null) {
      pr_stateController.text = value;
    }
    notifyListeners();
  }
  List<String> _availablePrStates = _getStatesForCountry('India');
  List<String> get availablePrStates => _availablePrStates;
  void onPrCountryChanged(String country) {
    _availablePrStates = _getStatesForCountry(country);
    print("value state 1:${_availablePrStates}");
    _selectedPrState.value = null;
    pr_stateController.clear();
    notifyListeners();
  }
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

  List<String> orgCountries = [
    "Afghanistan", "Albania", "Algeria", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahrain", "Bangladesh", "Belarus", "Belgium", "Brazil", "Brunei", "Bulgaria", "Cambodia", "Canada", "Chile", "China", "Colombia", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Egypt", "Estonia", "Finland", "France", "Georgia", "Germany", "Greece", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Japan", "Jordan", "Kazakhstan", "Kuwait", "Kyrgyzstan", "Latvia", "Lebanon", "Lithuania", "Luxembourg", "Malaysia", "Mexico", "Morocco", "Netherlands", "New Zealand", "Norway", "Oman", "Pakistan", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Saudi Arabia", "Singapore", "Slovakia", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Thailand", "Turkey", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uzbekistan", "Vietnam",
  ];
  static List<String> _getStatesForCountry(String countryName) {
    final Map<String, List<String>> countryStates = {
      'Afghanistan': ['Badakhshan', 'Badghis', 'Baghlan', 'Balkh', 'Bamyan', 'Daykundi', 'Farah', 'Faryab', 'Ghazni', 'Ghōr', 'Helmand', 'Herat', 'Jowzjan', 'Kabul', 'Kandahar', 'Kapisa', 'Khost', 'Kunar', 'Kunduz Province', 'Laghman', 'Logar', 'Nangarhar', 'Nimruz', 'Nuristan', 'Paktia', 'Paktika', 'Panjshir', 'Parwan', 'Samangan', 'Sar-e Pol', 'Takhar', 'Urozgan', 'Wardak', 'Zabul'],
      'Albania': ['Berat', 'Dibër', 'Durrës', 'Elbasan', 'Fier', 'Gjirokastër', 'Korçë', 'Kukës', 'Lezhë', 'Shkodër', 'Tirana', 'Vlorë'],
      'Algeria': ['Adrar', 'Aïn Defla', 'Aïn Témouchent', 'Algiers', 'Annaba', 'Batna', 'Béchar', 'Béjaïa', 'Béni Abbès', 'Biskra', 'Blida', 'Bordj Baji Mokhtar', 'Bordj Bou Arréridj', 'Bouïra', 'Boumerdès', 'Chlef', 'Constantine', 'Djanet', 'Djelfa', 'El Bayadh', 'El M\'ghair', 'El Menia', 'El Oued', 'El Tarf', 'Ghardaïa', 'Guelma', 'Illizi', 'In Guezzam', 'In Salah', 'Jijel', 'Khenchela', 'Laghouat', 'M\'Sila', 'Mascara', 'Médéa', 'Mila', 'Mostaganem', 'Naama', 'Oran', 'Ouargla', 'Ouled Djellal', 'Oum El Bouaghi', 'Relizane', 'Saïda', 'Sétif', 'Sidi Bel Abbès', 'Skikda', 'Souk Ahras', 'Tamanghasset', 'Tébessa', 'Tiaret', 'Timimoun', 'Tindouf', 'Tipasa', 'Tissemsilt', 'Tizi Ouzou', 'Tlemcen', 'Touggourt'],
      'Argentina': ['Autonomous City of Buenos Aires', 'Buenos Aires', 'Catamarca', 'Chaco', 'Chubut', 'Córdoba', 'Corrientes', 'Entre Ríos', 'Formosa', 'Jujuy', 'La Pampa', 'La Rioja', 'Mendoza', 'Misiones', 'Neuquén', 'Río Negro', 'Salta', 'San Juan', 'San Luis', 'Santa Cruz', 'Santa Fe', 'Santiago del Estero', 'Tierra del Fuego', 'Tucumán'],
      'Armenia': ['Aragatsotn', 'Ararat', 'Armavir', 'Gegharkunik', 'Kotayk', 'Lori', 'Shirak', 'Syunik', 'Tavush', 'Vayots Dzor', 'Yerevan'],
      'Australia': ['Australian Capital Territory', 'New South Wales', 'Northern Territory', 'Queensland', 'South Australia', 'Tasmania', 'Victoria', 'Western Australia'],
      'Austria': ['Burgenland', 'Carinthia', 'Lower Austria', 'Salzburg', 'Styria', 'Tyrol', 'Upper Austria', 'Vienna', 'Vorarlberg'],
      'Azerbaijan': ['Absheron', 'Agdam', 'Agdash', 'Aghjabadi', 'Agstafa', 'Agsu', 'Astara', 'Babek', 'Baku', 'Balakan', 'Barda', 'Beylagan', 'Bilasuvar', 'Dashkasan', 'Fizuli', 'Ganja', 'Gədəbəy', 'Gobustan', 'Goranboy', 'Goychay', 'Goygol', 'Hajigabul', 'Imishli', 'Ismailli', 'Jabrayil', 'Jalilabad', 'Julfa', 'Kalbajar', 'Kangarli', 'Khachmaz', 'Khankendi', 'Khizi', 'Khojali', 'Kurdamir', 'Lachin', 'Lankaran', 'Lankaran', 'Lerik', 'Martuni', 'Masally', 'Mingachevir', 'Naftalan', 'Nakhchivan', 'Nakhchivan', 'Neftchala', 'Oghuz', 'Ordubad', 'Qabala', 'Qakh', 'Qazakh', 'Quba', 'Qubadli', 'Qusar', 'Saatly', 'Sabirabad', 'Sadarak', 'Salyan', 'Samukh', 'Shabran', 'Shahbuz', 'Shaki', 'Shaki', 'Shamakhi', 'Shamkir', 'Sharur', 'Shirvan', 'Shusha', 'Siazan', 'Sumqayit', 'Tartar', 'Tovuz', 'Ujar', 'Yardymli', 'Yevlakh', 'Yevlakh', 'Zangilan', 'Zaqatala', 'Zardab'],
      'Bahrain': ['Capital', 'Muharraq', 'Northern', 'Southern'],
      'Bangladesh': ['Bagerhat', 'Bandarban', 'Barguna', 'Barisal ', 'Barishal', 'Bhola', 'Bogura', 'Brahmanbaria', 'Chandpur', 'Chapai Nawabganj', 'Chattogram', 'Chittagong ', 'Chuadanga', 'Cox\'s Bazar', 'Cumilla', 'Dhaka', 'Dhaka ', 'Dinajpur', 'Faridpur', 'Feni', 'Gaibandha', 'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur', 'Jashore', 'Jhalakathi', 'Jhenaidah', 'Joypurhat', 'Khagrachhari', 'Khulna', 'Khulna ', 'Kishoreganj', 'Kurigram', 'Kushtia', 'Lakshmipur', 'Lalmonirhat', 'Madaripur', 'Magura', 'Manikganj', 'Meherpur', 'Moulvibazar', 'Munshiganj', 'Mymensingh', 'Mymensingh ', 'Naogaon', 'Narail', 'Narayanganj', 'Narsingdi', 'Natore', 'Netrakona', 'Nilphamari', 'Noakhali', 'Pabna', 'Panchagarh', 'Patuakhali', 'Pirojpur', 'Rajbari', 'Rajshahi', 'Rajshahi ', 'Rangamati', 'Rangpur ', 'Rangpur', 'Satkhira', 'Shariatpur', 'Sherpur', 'Sirajganj', 'Sunamganj', 'Sylhet ', 'Sylhet', 'Tangail', 'Thakurgaon'],
      'Belarus': ['Brest', 'Gomel', 'Grodno', 'Minsk', 'Minsk', 'Mogilev', 'Vitebsk'],
      'Belgium': ['Antwerp', 'Brussels-Capital ', 'East Flanders', 'Flanders', 'Flemish Brabant', 'Hainaut', 'Liège', 'Limburg', 'Luxembourg', 'Namur', 'Wallonia', 'Walloon Brabant', 'West Flanders'],
      'Brazil': ['Acre', 'Alagoas', 'Amapá', 'Amazonas', 'Bahia', 'Ceará', 'Distrito Federal', 'Espírito Santo', 'Goiás', 'Maranhão', 'Mato Grosso', 'Mato Grosso do Sul', 'Minas Gerais', 'Pará', 'Paraíba', 'Paraná', 'Pernambuco', 'Piauí', 'Rio de Janeiro', 'Rio Grande do Norte', 'Rio Grande do Sul', 'Rondônia', 'Roraima', 'Santa Catarina', 'São Paulo', 'Sergipe', 'Tocantins'],
      'Brunei': ['Belait', 'Brunei-Muara', 'Temburong', 'Tutong'],
      'Bulgaria': ['Blagoevgrad', 'Burgas', 'Dobrich', 'Gabrovo', 'Haskovo', 'Kardzhali', 'Kyustendil', 'Lovech', 'Montana', 'Pazardzhik', 'Pernik', 'Pleven', 'Plovdiv', 'Razgrad', 'Ruse', 'Shumen', 'Silistra', 'Sliven', 'Smolyan', 'Sofia', 'Sofia City', 'Stara Zagora', 'Targovishte', 'Varna', 'Veliko Tarnovo', 'Vidin', 'Vratsa', 'Yambol'],
      'Cambodia': ['Banteay Meanchey', 'Battambang', 'Kampong Cham', 'Kampong Chhnang', 'Kampong Speu', 'Kampong Thom', 'Kampot', 'Kandal', 'Kep', 'Koh Kong', 'Kratie', 'Mondulkiri', 'Oddar Meanchey', 'Pailin', 'Phnom Penh', 'Preah Vihear', 'Prey Veng', 'Pursat', 'Ratanakiri', 'Siem Reap', 'Sihanoukville', 'Stung Treng', 'Svay Rieng', 'Takeo', 'Tboung Khmum'],
      'Canada': ['Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia', 'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan', 'Yukon'],
      'Chile': ['Aisén del General Carlos Ibañez del Campo', 'Antofagasta', 'Arica y Parinacota', 'Atacama', 'Biobío', 'Coquimbo', 'La Araucanía', 'Libertador General Bernardo O\'Higgins', 'Los Lagos', 'Los Ríos', 'Magallanes y de la Antártica Chilena', 'Maule', 'Ñuble', 'Región Metropolitana de Santiago', 'Tarapacá', 'Valparaíso'],
      'China': ['Anhui', 'Beijing', 'Chongqing', 'Fujian', 'Gansu', 'Guangdong', 'Guangxi', 'Guizhou', 'Hainan', 'Hebei', 'Heilongjiang', 'Henan', 'Hong Kong SAR', 'Hubei', 'Hunan', 'Inner Mongolia', 'Jiangsu', 'Jiangxi', 'Jilin', 'Liaoning', 'Macau SAR', 'Ningxia', 'Qinghai', 'Shaanxi', 'Shandong', 'Shanghai', 'Shanxi', 'Sichuan', 'Taiwan', 'Tianjin', 'Tibet', 'Xinjiang', 'Yunnan', 'Zhejiang'],
      'Colombia': ['Amazonas', 'Antioquia', 'Arauca', 'Atlántico', 'Bogotá D.C.', 'Bolívar', 'Boyacá', 'Caldas', 'Caquetá', 'Casanare', 'Cauca', 'Cesar', 'Chocó', 'Córdoba', 'Cundinamarca', 'Guainía', 'Guaviare', 'Huila', 'La Guajira', 'Magdalena', 'Meta', 'Nariño', 'Norte de Santander', 'Putumayo', 'Quindío', 'Risaralda', 'San Andrés, Providencia y Santa Catalina', 'Santander', 'Sucre', 'Tolima', 'Valle del Cauca', 'Vaupés', 'Vichada'],
      'Croatia': ['Bjelovar-Bilogora', 'Brod-Posavina', 'Dubrovnik-Neretva', 'Istria', 'Karlovac', 'Koprivnica-Križevci', 'Krapina-Zagorje', 'Lika-Senj', 'Međimurje', 'Osijek-Baranja', 'Požega-Slavonia', 'Primorje-Gorski Kotar', 'Šibenik-Knin', 'Sisak-Moslavina', 'Split-Dalmatia', 'Varaždin', 'Virovitica-Podravina', 'Vukovar-Syrmia', 'Zadar', 'Zagreb'],
      'Cyprus': ['Famagusta (Mağusa)', 'Kyrenia (Keryneia)', 'Larnaca (Larnaka)', 'Limassol (Leymasun)', 'Nicosia (Lefkoşa)', 'Paphos (Pafos)'],
      'Czech Republic': ['Benešov', 'Beroun', 'Blansko', 'Břeclav', 'Brno-město', 'Brno-venkov', 'Bruntál', 'Česká Lípa', 'České Budějovice', 'Český Krumlov', 'Cheb', 'Chomutov', 'Chrudim', 'Děčín', 'Domažlice', 'Frýdek-Místek', 'Havlíčkův Brod', 'Hodonín', 'Hradec Králové', 'Jablonec nad Nisou', 'Jeseník', 'Jičín', 'Jihlava', 'Jihočeský kraj', 'Jihomoravský kraj', 'Jindřichův Hradec', 'Karlovarský kraj', 'Karlovy Vary', 'Karviná', 'Kladno', 'Klatovy', 'Kolín', 'Kraj Vysočina', 'Královéhradecký kraj', 'Kroměříž', 'Kutná Hora', 'Liberec', 'Liberecký kraj', 'Litoměřice', 'Louny', 'Mělník', 'Mladá Boleslav', 'Moravskoslezský kraj', 'Most', 'Náchod', 'Nový Jičín', 'Nymburk', 'Olomouc', 'Olomoucký kraj', 'Opava', 'Ostrava-město', 'Pardubice', 'Pardubický kraj', 'Pelhřimov', 'Písek', 'Plzeň-jih', 'Plzeň-město', 'Plzeň-sever', 'Plzeňský kraj', 'Prachatice', 'Praha-východ', 'Praha-západ', 'Praha, Hlavní město', 'Přerov', 'Příbram', 'Prostějov', 'Rakovník', 'Rokycany', 'Rychnov nad Kněžnou', 'Semily', 'Sokolov', 'Strakonice', 'Středočeský kraj', 'Šumperk', 'Svitavy', 'Tábor', 'Tachov', 'Teplice', 'Třebíč', 'Trutnov', 'Uherské Hradiště', 'Ústecký kraj', 'Ústí nad Labem', 'Ústí nad Orlicí', 'Vsetín', 'Vyškov', 'Žďár nad Sázavou', 'Zlín', 'Zlínský kraj', 'Znojmo'],
      'Denmark': ['Central Denmark', 'Denmark', 'North Denmark', 'Southern Denmark', 'Zealand'],
      'Egypt': ['Alexandria', 'Aswan', 'Asyut', 'Beheira', 'Beni Suef', 'Cairo', 'Dakahlia', 'Damietta', 'Faiyum', 'Gharbia', 'Giza', 'Ismailia', 'Kafr El-Sheikh', 'Luxor', 'Matrouh', 'Minya', 'Monufia', 'New Valley', 'North Sinai', 'Port Said', 'Qalyubia', 'Qena', 'Red Sea', 'Sharqia', 'Sohag', 'South Sinai', 'Suez'],
      'Estonia': ['Alutaguse', 'Anija', 'Antsla', 'Elva', 'Häädemeeste', 'Haapsalu', 'Haljala', 'Harju', 'Harku', 'Hiiu', 'Hiiumaa', 'Ida-Viru', 'Järva', 'Järva', 'Joelähtme', 'Jõgeva', 'Jõgeva', 'Jõhvi', 'Kadrina', 'Kambja', 'Kanepi', 'Kastre', 'Kehtna', 'Keila', 'Kihnu', 'Kiili', 'Kohila', 'Kohtla-Järve', 'Kose', 'Kuusalu', 'Lääne', 'Lääne-Harju', 'Lääne-Nigula', 'Lääne-Viru', 'Lääneranna', 'Loksa', 'Lüganuse', 'Luunja', 'Maardu', 'Märjamaa', 'Muhu', 'Mulgi', 'Mustvee', 'Narva', 'Narva-Jõesuu', 'Noo', 'Otepää', 'Paide', 'Pärnu', 'Pärnu', 'Peipsiääre', 'Põhja-Pärnu', 'Põhja-Sakala', 'Poltsamaa', 'Põlva', 'Põlva', 'Raasiku', 'Rae', 'Rakvere', 'Rakvere', 'Räpina', 'Rapla', 'Rapla', 'Rõuge', 'Ruhnu', 'Saarde', 'Saare', 'Saaremaa', 'Saku', 'Saue', 'Setomaa', 'Sillamäe', 'Tallinn', 'Tapa', 'Tartu', 'Tartu', 'Tartu', 'Toila', 'Tori', 'Tõrva', 'Türi', 'Väike-Maarja', 'Valga', 'Valga', 'Viimsi', 'Viljandi', 'Viljandi', 'Viljandi', 'Vinni', 'Viru-Nigula', 'Vormsi', 'Võru', 'Võru', 'Võru'],
      'Finland': ['Central Finland', 'Central Ostrobothnia', 'Finland Proper', 'Kainuu', 'Kymenlaakso', 'Lapland', 'North Karelia', 'Northern Ostrobothnia', 'Northern Savonia', 'Ostrobothnia', 'Päijänne Tavastia', 'Pirkanmaa', 'Satakunta', 'South Karelia', 'Southern Ostrobothnia', 'Southern Savonia', 'Tavastia Proper', 'Uusimaa'],
      'France': ['Ain', 'Aisne', 'Allier', 'Alpes-de-Haute-Provence', 'Alpes-Maritimes', 'Alsace', 'Ardèche', 'Ardennes', 'Ariège', 'Aube', 'Aude', 'Auvergne-Rhône-Alpes', 'Aveyron', 'Bas-Rhin', 'Bouches-du-Rhône', 'Bourgogne-Franche-Comté', 'Bretagne', 'Calvados', 'Cantal', 'Centre-Val de Loire', 'Charente', 'Charente-Maritime', 'Cher', 'Clipperton', 'Corrèze', 'Corse', 'Corse-du-Sud', 'Côte-d\'Or', 'Côtes-d\'Armor', 'Creuse', 'Deux-Sèvres', 'Dordogne', 'Doubs', 'Drôme', 'Essonne', 'Eure', 'Eure-et-Loir', 'Finistère', 'French Guiana', 'French Polynesia', 'French Southern and Antarctic Lands', 'Gard', 'Gers', 'Gironde', 'Grand-Est', 'Guadeloupe', 'Haut-Rhin', 'Haute-Corse', 'Haute-Garonne', 'Haute-Loire', 'Haute-Marne', 'Haute-Saône', 'Haute-Savoie', 'Haute-Vienne', 'Hautes-Alpes', 'Hautes-Pyrénées', 'Hauts-de-France', 'Hauts-de-Seine', 'Hérault', 'Île-de-France', 'Ille-et-Vilaine', 'Indre', 'Indre-et-Loire', 'Isère', 'Jura', 'La Réunion', 'Landes', 'Loir-et-Cher', 'Loire', 'Loire-Atlantique', 'Loiret', 'Lot', 'Lot-et-Garonne', 'Lozère', 'Maine-et-Loire', 'Manche', 'Marne', 'Martinique', 'Mayenne', 'Mayotte', 'Métropole de Lyon', 'Meurthe-et-Moselle', 'Meuse', 'Morbihan', 'Moselle', 'Nièvre', 'Nord', 'Normandie', 'Nouvelle-Aquitaine', 'Nouvelle-Calédonie', 'Occitanie', 'Oise', 'Orne', 'Paris', 'Pas-de-Calais', 'Pays-de-la-Loire', 'Provence-Alpes-Côte-d’Azur', 'Puy-de-Dôme', 'Pyrénées-Atlantiques', 'Pyrénées-Orientales', 'Rhône', 'Saint Pierre and Miquelon', 'Saint-Barthélemy', 'Saint-Martin', 'Saône-et-Loire', 'Sarthe', 'Savoie', 'Seine-et-Marne', 'Seine-Maritime', 'Seine-Saint-Denis', 'Somme', 'Tarn', 'Tarn-et-Garonne', 'Territoire de Belfort', 'Val-d\'Oise', 'Val-de-Marne', 'Var', 'Vaucluse', 'Vendée', 'Vienne', 'Vosges', 'Wallis and Futuna', 'Yonne', 'Yvelines'],
      'Georgia': ['Abkhazia', 'Adjara', 'Guria', 'Imereti', 'Kakheti', 'Kvemo Kartli', 'Mtskheta-Mtianeti', 'Racha-Lechkhumi and Kvemo Svaneti', 'Samegrelo-Zemo Svaneti', 'Samtskhe-Javakheti', 'Shida Kartli', 'Tbilisi'],
      'Germany': ['Baden-Württemberg', 'Bavaria', 'Berlin', 'Brandenburg', 'Bremen', 'Hamburg', 'Hessen', 'Lower Saxony', 'Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Rhineland-Palatinate', 'Saarland', 'Saxony', 'Saxony-Anhalt', 'Schleswig-Holstein', 'Thuringia'],
      'Greece': ['Achaea', 'Attica', 'Central Greece', 'Central Macedonia', 'Crete', 'East Attica', 'East Macedonia and Thrace', 'Epirus', 'Ionian Islands', 'North Aegean', 'Peloponnese', 'South Aegean', 'Thessaly', 'West Greece', 'West Macedonia'],
      'Hungary': ['Bács-Kiskun', 'Baranya', 'Békés', 'Békéscsaba', 'Borsod-Abaúj-Zemplén', 'Budapest', 'Csongrád County', 'Debrecen', 'Dunaújváros', 'Eger', 'Érd', 'Fejér County', 'Győr', 'Győr-Moson-Sopron County', 'Hajdú-Bihar County', 'Heves County', 'Hódmezővásárhely', 'Jász-Nagykun-Szolnok County', 'Kaposvár', 'Kecskemét', 'Komárom-Esztergom', 'Miskolc', 'Nagykanizsa', 'Nógrád County', 'Nyíregyháza', 'Pécs', 'Pest County', 'Salgótarján', 'Somogy County', 'Sopron', 'Szabolcs-Szatmár-Bereg County', 'Szeged', 'Székesfehérvár', 'Szekszárd', 'Szolnok', 'Szombathely', 'Tatabánya', 'Tolna County', 'Vas County', 'Veszprém', 'Veszprém County', 'Zala County', 'Zalaegerszeg'],
      'Iceland': ['Akranes', 'Akureyri', 'Árborg', 'Árneshreppur', 'Ásahreppur', 'Bláskógabyggð', 'Bolungarvík', 'Borgarbyggð', 'Capital', 'Dalabyggð', 'Dalvíkurbyggð', 'Eastern', 'Eyja- og Miklaholtshreppur', 'Eyjafjarðarsveit', 'Fjallabyggð', 'Fjarðabyggð', 'Fljótsdalshreppur', 'Flóahreppur', 'Garðabær', 'Grímsnes- og Grafningshreppur', 'Grindavík', 'Grundarfjörður', 'Grýtubakkahreppur', 'Hafnarfjörður', 'Hörðarsveit', 'Hornafjörður', 'Hrunamannahreppur', 'Húnabyggð', 'Húnaþing vestra', 'Hvalfjarðarsveit', 'Hveragerði', 'Ísafjörður', 'Kaldrananeshreppur', 'Kjósarhreppur', 'Kópavogur', 'Langanesbyggð', 'Mosfellsbær', 'Múlaþing', 'Mýrdalshreppur', 'Norðurþing', 'Northeastern', 'Northwestern', 'Ölfus', 'Rangárþing eystra', 'Rangárþing ytra', 'Reykhólahreppur', 'Reykjanesbær', 'Reykjavík', 'Seltjarnarnes', 'Skaftárhreppur', 'Skagabyggð', 'Skagafjörður', 'Skagaströnd', 'Skeiða- og Gnúpverjahreppur', 'Skorradalshreppur', 'Snæfellsbær', 'Southern', 'Southern Peninsula', 'Strandabyggð', 'Stykkishólmur', 'Súðavík', 'Suðurnesjabær', 'Svalbardsstrandarhreppur', 'Tálknafjarðarhreppur', 'Tjörneshreppur', 'Vestmannaeyjar', 'Vesturbyggð', 'Vogar', 'Vopnafjarðarhreppur', 'Western', 'Westfjords', 'Þingeyjarsveit'],
      'India': ['Andaman and Nicobar Islands', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chandigarh', 'Chhattisgarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Ladakh', 'Lakshadweep', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'],
      'Indonesia': ['Aceh', 'Bali', 'Banten', 'Bengkulu', 'DI Yogyakarta', 'DKI Jakarta', 'Gorontalo', 'Jambi', 'Jawa', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'Kalimantan', 'Kalimantan Barat', 'Kalimantan Selatan', 'Kalimantan Tengah', 'Kalimantan Timur', 'Kalimantan Utara', 'Kepulauan Bangka Belitung', 'Kepulauan Riau', 'Lampung', 'Maluku', 'Maluku', 'Maluku Utara', 'Nusa Tenggara', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur', 'Papua', 'Papua', 'Papua Barat', 'Papua Barat Daya', 'Papua Pegunungan', 'Papua Selatan', 'Papua Tengah', 'Riau', 'Sulawesi', 'Sulawesi Barat', 'Sulawesi Selatan', 'Sulawesi Tengah', 'Sulawesi Tenggara', 'Sulawesi Utara', 'Sumatera', 'Sumatera Barat', 'Sumatera Selatan', 'Sumatera Utara'],
      'Iran': ['Alborz', 'Ardabil', 'Bushehr', 'Chaharmahal and Bakhtiari', 'East Azerbaijan', 'Fars', 'Gilan', 'Golestan', 'Hamadan', 'Hormozgan', 'Ilam', 'Isfahan', 'Kerman', 'Kermanshah', 'Khuzestan', 'Kohgiluyeh and Boyer-Ahmad', 'Kurdistan', 'Lorestan', 'Markazi', 'Mazandaran', 'North Khorasan', 'Qazvin', 'Qom', 'Razavi Khorasan', 'Semnan', 'Sistan and Baluchestan', 'South Khorasan', 'Tehran', 'West Azarbaijan', 'Yazd', 'Zanjan'],
      'Iraq': ['Al Anbar', 'Al Muthanna', 'Al-Qādisiyyah', 'Babylon', 'Baghdad', 'Basra', 'Dhi Qar', 'Diyala', 'Dohuk', 'Erbil', 'Iqlim Kurdistan', 'Karbala', 'Kirkuk', 'Maysan', 'Najaf', 'Nineveh', 'Saladin', 'Sulaymaniyah', 'Wasit'],
      'Ireland': ['Carlow', 'Cavan', 'Clare', 'Connacht', 'Cork', 'Donegal', 'Dublin', 'Galway', 'Kerry', 'Kildare', 'Kilkenny', 'Laois', 'Leinster', 'Leitrim', 'Limerick', 'Longford', 'Louth', 'Mayo', 'Meath', 'Monaghan', 'Munster', 'Offaly', 'Roscommon', 'Sligo', 'Tipperary', 'Ulster', 'Waterford', 'Westmeath', 'Wexford', 'Wicklow'],
      'Israel': ['Central', 'Haifa', 'Jerusalem', 'Northern', 'Southern', 'Tel Aviv'],
      'Italy': ['Abruzzo', 'Agrigento', 'Alessandria', 'Ancona', 'Aosta Valley', 'Apulia', 'Arezzo', 'Ascoli Piceno', 'Asti', 'Avellino', 'Bari', 'Barletta-Andria-Trani', 'Basilicata', 'Belluno', 'Benevento', 'Bergamo', 'Biella', 'Bologna', 'Brescia', 'Brindisi', 'Cagliari', 'Calabria', 'Caltanissetta', 'Campania', 'Campobasso', 'Caserta', 'Catania', 'Catanzaro', 'Chieti', 'Como', 'Cosenza', 'Cremona', 'Crotone', 'Cuneo', 'Emilia-Romagna', 'Enna', 'Fermo', 'Ferrara', 'Florence', 'Foggia', 'Forlì-Cesena', 'Friuli–Venezia Giulia', 'Frosinone', 'Genoa', 'Gorizia', 'Grosseto', 'Imperia', 'Isernia', 'L\'Aquila', 'La Spezia', 'Latina', 'Lazio', 'Lecce', 'Lecco', 'Liguria', 'Livorno', 'Lodi', 'Lombardy', 'Lucca', 'Macerata', 'Mantua', 'Marche', 'Massa and Carrara', 'Matera', 'Messina', 'Milan', 'Modena', 'Molise', 'Monza and Brianza', 'Naples', 'Novara', 'Nuoro', 'Oristano', 'Padua', 'Palermo', 'Parma', 'Pavia', 'Perugia', 'Pesaro and Urbino', 'Pescara', 'Piacenza', 'Piedmont', 'Pisa', 'Pistoia', 'Pordenone', 'Potenza', 'Prato', 'Ragusa', 'Ravenna', 'Reggio Calabria', 'Reggio Emilia', 'Rieti', 'Rimini', 'Rome', 'Rovigo', 'Salerno', 'Sardinia', 'Sassari', 'Savona', 'Sicily', 'Siena', 'Siracusa', 'Sondrio', 'South Sardinia', 'South Tyrol', 'Taranto', 'Teramo', 'Terni', 'Trapani', 'Trentino', 'Trentino-South Tyrol', 'Treviso', 'Trieste', 'Turin', 'Tuscany', 'Udine', 'Umbria', 'Varese', 'Veneto', 'Venice', 'Verbano-Cusio-Ossola', 'Vercelli', 'Verona', 'Vibo Valentia', 'Vicenza', 'Viterbo'],
      'Japan': ['Aichi', 'Akita', 'Aomori', 'Chiba', 'Ehime', 'Fukui', 'Fukuoka', 'Fukushima', 'Gifu', 'Gunma', 'Hiroshima', 'Hokkaidō', 'Hyōgo', 'Ibaraki', 'Ishikawa', 'Iwate', 'Kagawa', 'Kagoshima', 'Kanagawa', 'Kōchi', 'Kumamoto', 'Kyōto', 'Mie', 'Miyagi', 'Miyazaki', 'Nagano', 'Nagasaki', 'Nara', 'Niigata', 'Ōita', 'Okayama', 'Okinawa', 'Ōsaka', 'Saga', 'Saitama', 'Shiga', 'Shimane', 'Shizuoka', 'Tochigi', 'Tokushima', 'Tokyo', 'Tottori', 'Toyama', 'Wakayama', 'Yamagata', 'Yamaguchi', 'Yamanashi'],
      'Jordan': ['Ajloun', 'Amman', 'Aqaba', 'Balqa', 'Irbid', 'Jerash', 'Karak', 'Ma\'an', 'Madaba', 'Mafraq', 'Tafilah', 'Zarqa'],
      'Kazakhstan': ['Abai', 'Akmola', 'Aktobe', 'Almaty', 'Almaty', 'Astana', 'Atyrau', 'East Kazakhstan', 'Jambyl', 'Jetisu', 'Karaganda', 'Kostanay', 'Kyzylorda', 'Mangystau', 'North Kazakhstan', 'Pavlodar', 'Shymkent', 'Turkistan', 'Ulytau', 'West Kazakhstan'],
      'Kuwait': ['Al Ahmadi', 'Al Asimah', 'Al Farwaniyah', 'Al Jahra', 'Hawalli', 'Mubarak Al-Kabeer'],
      'Kyrgyzstan': ['Batken', 'Bishkek', 'Chuy', 'Issyk-Kul', 'Jalal-Abad', 'Naryn', 'Osh', 'Osh', 'Talas'],
      'Latvia': ['Ādaži', 'Aizkraukle', 'Alūksne', 'Augšdaugava', 'Balvi', 'Bauska', 'Cēsis', 'Daugavpils', 'Dienvidkurzemes', 'Dobele', 'Gulbene', 'Jēkabpils', 'Jelgava', 'Jelgava', 'Jūrmala', 'Ķekava', 'Krāslava', 'Kuldīga', 'Liepāja', 'Limbaži', 'Līvāni', 'Ludza', 'Madona', 'Mārupe', 'Ogre', 'Olaine', 'Preiļi', 'Rēzekne', 'Rēzekne', 'Riga', 'Ropaži', 'Salaspils', 'Saldus', 'Saulkrasti', 'Sigulda', 'Smiltene', 'Talsi', 'Tukums', 'Valka', 'Valmiera', 'Varakļāni', 'Ventspils', 'Ventspils'],
      'Lebanon': ['Akkar', 'Baalbek-Hermel', 'Beirut', 'Beqaa', 'Mount Lebanon', 'Nabatieh', 'North', 'South'],
      'Lithuania': ['Akmenė', 'Alytus', 'Alytus', 'Alytus', 'Anykščiai', 'Birštonas', 'Biržai', 'Druskininkai', 'Elektrėnai', 'Ignalina', 'Jonava', 'Joniškis', 'Jurbarkas', 'Kaišiadorys', 'Kalvarija', 'Kaunas', 'Kaunas', 'Kaunas', 'Kazlų Rūda', 'Kėdainiai', 'Kelmė', 'Klaipėda', 'Klaipėda', 'Klaipėdos miestas', 'Kretinga', 'Kupiškis', 'Lazdijai', 'Marijampolė', 'Marijampolė', 'Mažeikiai', 'Molėtai', 'Neringa', 'Pagėgiai', 'Pakruojis', 'Palanga', 'Panevėžio miestas', 'Panevėžys', 'Panevėžys', 'Pasvalys', 'Plungė', 'Prienai', 'Radviliškis', 'Raseiniai', 'Rietavas', 'Rokiškis', 'Šakiai', 'Šalčininkai', 'Šiauliai', 'Šiauliai', 'Šiauliai', 'Šilalė ', 'Šilutė', 'Širvintos', 'Skuodas', 'Švenčionys', 'Tauragė', 'Tauragė', 'Telšiai', 'Telšiai', 'Trakai', 'Ukmergė', 'Utena', 'Utena', 'Varėna', 'Vilkaviškis', 'Vilnius', 'Vilnius', 'Vilnius', 'Visaginas', 'Zarasai'],
      'Luxembourg': ['Capellen', 'Clervaux', 'Diekirch', 'Echternach', 'Esch-sur-Alzette', 'Grevenmacher', 'Luxembourg ', 'Mersch', 'Redange', 'Remich', 'Vianden', 'Wiltz'],
      'Malaysia': ['Johor', 'Kedah', 'Kelantan', 'Kuala Lumpur', 'Labuan', 'Malacca', 'Negeri Sembilan', 'Pahang', 'Penang', 'Perak', 'Perlis', 'Putrajaya', 'Sabah', 'Sarawak', 'Selangor', 'Terengganu'],
      'Mexico': ['Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Ciudad de México', 'Coahuila de Zaragoza', 'Colima', 'Durango', 'Estado de México', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Michoacán de Ocampo', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz de Ignacio de la Llave', 'Yucatán', 'Zacatecas'],
      'Morocco': ['Agadir-Ida-Ou-Tanane', 'Al Haouz', 'Al Hoceïma', 'Aousserd (EH)', 'Assa-Zag (EH-partial)', 'Azilal', 'Béni Mellal', 'Béni Mellal-Khénifra', 'Benslimane', 'Berkane', 'Berrechid', 'Boujdour (EH)', 'Boulemane', 'Casablanca', 'Casablanca-Settat', 'Chefchaouen', 'Chichaoua', 'Chtouka-Ait Baha', 'Dakhla-Oued Ed-Dahab (EH)', 'Drâa-Tafilalet', 'Driouch', 'El Hajeb', 'El Jadida', 'El Kelâa des Sraghna', 'Errachidia', 'Es-Semara (EH-partial)', 'Essaouira', 'Fahs-Anjra', 'Fès', 'Fès-Meknès', 'Figuig', 'Fquih Ben Salah', 'Guelmim', 'Guelmim-Oued Noun (EH-partial)', 'Guercif', 'Ifrane', 'Inezgane-Ait Melloul', 'Jerada', 'Kénitra', 'Khémisset', 'Khénifra', 'Khouribga', 'L\'Oriental', 'Laâyoune (EH)', 'Laâyoune-Sakia El Hamra (EH-partial)', 'Larache', 'M’diq-Fnideq', 'Marrakech', 'Marrakesh-Safi', 'Médiouna', 'Meknès', 'Midelt', 'Mohammadia', 'Moulay Yacoub', 'Nador', 'Nouaceur', 'Ouarzazate', 'Oued Ed-Dahab (EH)', 'Ouezzane', 'Oujda-Angad', 'Rabat', 'Rabat-Salé-Kénitra', 'Rehamna', 'Safi', 'Salé', 'Sefrou', 'Settat', 'Sidi Bennour', 'Sidi Ifni', 'Sidi Kacem', 'Sidi Slimane', 'Skhirate-Témara', 'Souss-Massa', 'Tan-Tan (EH-partial)', 'Tanger-Assilah', 'Tanger-Tétouan-Al Hoceïma', 'Taounate', 'Taourirt', 'Tarfaya (EH-partial)', 'Taroudannt', 'Tata', 'Taza', 'Tétouan', 'Tinghir', 'Tiznit', 'Youssoufia', 'Zagora'],
      'Netherlands': ['Drenthe', 'Flevoland', 'Friesland', 'Gelderland', 'Groningen', 'Limburg', 'North Brabant', 'North Holland', 'Overijssel', 'South Holland', 'Utrecht', 'Zeeland'],
      'New Zealand': ['Auckland', 'Bay of Plenty', 'Canterbury', 'Chatham Islands', 'Gisborne', 'Hawke\'s Bay', 'Manawatu-Whanganui', 'Marlborough', 'Nelson', 'Northland', 'Otago', 'Southland', 'Taranaki', 'Tasman', 'Waikato', 'Wellington', 'West Coast'],
      'Norway': ['Agder', 'Akershus', 'Buskerud', 'Finnmark', 'Innlandet', 'Jan Mayen', 'Møre og Romsdal', 'Nordland', 'Oslo', 'Østfold', 'Rogaland', 'Svalbard', 'Telemark', 'Troms', 'Trøndelag', 'Vestfold', 'Vestland'],
      'Oman': ['Ad Dakhiliyah', 'Ad Dhahirah', 'Al Batinah North', 'Al Batinah South', 'Al Buraimi', 'Al Wusta', 'Ash Sharqiyah North', 'Ash Sharqiyah South', 'Dhofar', 'Musandam', 'Muscat'],
      'Pakistan': ['Azad Kashmir', 'Balochistan', 'Gilgit-Baltistan', 'Islamabad', 'Khyber Pakhtunkhwa', 'Punjab', 'Sindh'],
      'Peru': ['Amazonas', 'Áncash', 'Apurímac', 'Arequipa', 'Ayacucho', 'Cajamarca', 'Callao', 'Cusco', 'Huancavelica', 'Huanuco', 'Ica', 'Junín', 'La Libertad', 'Lambayeque', 'Lima', 'Loreto', 'Madre de Dios', 'Moquegua', 'Municipalidad Metropolitana de Lima', 'Pasco', 'Piura', 'Puno', 'San Martín', 'Tacna', 'Tumbes', 'Ucayali'],
      'Philippines': ['Abra', 'Agusan del Norte', 'Agusan del Sur', 'Aklan', 'Albay', 'Antique', 'Apayao', 'Aurora', 'Autonomous Region in Muslim Mindanao', 'Basilan', 'Bataan', 'Batanes', 'Batangas', 'Benguet', 'Bicol', 'Biliran', 'Bohol', 'Bukidnon', 'Bulacan', 'Cagayan', 'Cagayan Valley', 'Calabarzon', 'Camarines Norte', 'Camarines Sur', 'Camiguin', 'Capiz', 'Caraga', 'Catanduanes', 'Cavite', 'Cebu', 'Central Luzon', 'Central Visayas', 'Cordillera Administrative', 'Cotabato', 'Davao', 'Davao de Oro', 'Davao del Norte', 'Davao del Sur', 'Davao Occidental', 'Davao Oriental', 'Dinagat Islands', 'Eastern Samar', 'Eastern Visayas', 'Guimaras', 'Ifugao', 'Ilocos', 'Ilocos Norte', 'Ilocos Sur', 'Iloilo', 'Isabela', 'Kalinga', 'La Union', 'Laguna', 'Lanao del Norte', 'Lanao del Sur', 'Leyte', 'Maguindanao del Norte', 'Maguindanao del Sur', 'Marinduque', 'Masbate', 'Mimaropa', 'Misamis Occidental', 'Misamis Oriental', 'Mountain Province', 'National Capital Region (Metro Manila)', 'Negros Occidental', 'Negros Oriental', 'Northern Mindanao', 'Northern Samar', 'Nueva Ecija', 'Nueva Vizcaya', 'Occidental Mindoro', 'Oriental Mindoro', 'Palawan', 'Pampanga', 'Pangasinan', 'Quezon', 'Quirino', 'Rizal', 'Romblon', 'Sarangani', 'Siquijor', 'Soccsksargen', 'Sorsogon', 'South Cotabato', 'Southern Leyte', 'Sultan Kudarat', 'Sulu', 'Surigao del Norte', 'Surigao del Sur', 'Tarlac', 'Tawi-Tawi', 'Western Samar', 'Western Visayas', 'Zambales', 'Zamboanga del Norte', 'Zamboanga del Sur', 'Zamboanga Peninsula', 'Zamboanga Sibugay'],
      'Poland': ['Greater Poland', 'Holy Cross', 'Kuyavia-Pomerania', 'Lesser Poland', 'Lower Silesia', 'Lublin', 'Lubusz', 'Łódź', 'Mazovia', 'Podlaskie', 'Pomerania', 'Silesia', 'Subcarpathia', 'Upper Silesia', 'Warmia-Masuria', 'West Pomerania'],
      'Portugal': ['Açores', 'Aveiro', 'Beja', 'Braga', 'Bragança', 'Castelo Branco', 'Coimbra', 'Évora', 'Faro', 'Guarda', 'Leiria', 'Lisbon', 'Madeira', 'Portalegre', 'Porto', 'Santarém', 'Setúbal', 'Viana do Castelo', 'Vila Real', 'Viseu'],
      'Qatar': ['Al Daayen', 'Al Khor', 'Al Rayyan', 'Al Wakrah', 'Al-Shahaniya', 'Doha', 'Madinat ash Shamal', 'Umm Salal'],
      'Romania': ['Alba', 'Arad', 'Arges', 'Bacău', 'Bihor', 'Bistrița-Năsăud', 'Botoșani', 'Braila', 'Brașov', 'Bucharest', 'Buzău', 'Călărași', 'Caraș-Severin', 'Cluj', 'Constanța', 'Covasna', 'Dâmbovița', 'Dolj', 'Galați', 'Giurgiu', 'Gorj', 'Harghita', 'Hunedoara', 'Ialomița', 'Iași', 'Ilfov', 'Maramureș', 'Mehedinți', 'Mureș', 'Neamț', 'Olt', 'Prahova', 'Sălaj', 'Satu Mare', 'Sibiu', 'Suceava', 'Teleorman', 'Timiș', 'Tulcea', 'Vâlcea', 'Vaslui', 'Vrancea'],
      'Russia': ['Adygea', 'Altai', 'Altai', 'Amur', 'Arkhangelsk', 'Astrakhan', 'Bashkortostan', 'Belgorod', 'Bryansk', 'Buryatia', 'Chechen', 'Chelyabinsk', 'Chukotka', 'Chuvash', 'Dagestan', 'Ingushetia', 'Irkutsk', 'Ivanovo', 'Jewish', 'Kabardino-Balkar', 'Kaliningrad', 'Kalmykia', 'Kaluga', 'Kamchatka', 'Karachay-Cherkess', 'Karelia', 'Kemerovo', 'Khabarovsk', 'Khakassia', 'Khanty-Mansi', 'Kirov', 'Komi', 'Kostroma', 'Krasnodar', 'Krasnoyarsk', 'Kurgan', 'Kursk', 'Leningrad', 'Lipetsk', 'Magadan', 'Mari El', 'Mordovia', 'Moscow', 'Moscow', 'Murmansk', 'Nenets', 'Nizhny Novgorod', 'North Ossetia-Alania', 'Novgorod', 'Novosibirsk', 'Omsk', 'Orenburg', 'Oryol', 'Penza', 'Perm', 'Primorsky', 'Pskov', 'Rostov', 'Ryazan', 'Saint Petersburg', 'Sakha', 'Sakhalin', 'Samara', 'Saratov', 'Smolensk', 'Stavropol', 'Sverdlovsk', 'Tambov', 'Tatarstan', 'Tomsk', 'Tula', 'Tuva', 'Tver', 'Tyumen', 'Udmurt', 'Ulyanovsk', 'Vladimir', 'Volgograd Oblast', 'Vologda', 'Voronezh', 'Yamalo-Nenets', 'Yaroslavl', 'Zabaykalsky'],
      'Saudi Arabia': ['Al Bahah', 'Al Jawf', 'Al Madinah', 'Al-Qassim', 'Asir', 'Eastern Province', 'Ha\'il', 'Jizan', 'Makkah', 'Najran', 'Northern Borders', 'Riyadh', 'Tabuk'],
      'Singapore': ['Central Singapore', 'North East', 'North West', 'South East', 'South West'],
      'Slovakia': ['Banská Bystrica', 'Bratislava', 'Košice', 'Nitra', 'Prešov', 'Trenčín', 'Trnava', 'Žilina'],
      'Slovenia': ['Ajdovščina', 'Ankaran', 'Apače', 'Beltinci', 'Benedikt', 'Bistrica ob Sotli', 'Bled', 'Bloke', 'Bohinj', 'Borovnica', 'Bovec', 'Braslovče', 'Brda', 'Brežice', 'Brezovica', 'Cankova', 'Celje', 'Cerklje na Gorenjskem', 'Cerknica', 'Cerkno', 'Cerkvenjak', 'Cirkulane', 'Črenšovci', 'Črna na Koroškem', 'Črnomelj', 'Destrnik', 'Divača', 'Dobje', 'Dobrepolje', 'Dobrna', 'Dobrova–Polhov Gradec', 'Dobrovnik', 'Dol pri Ljubljani', 'Dolenjske Toplice', 'Domžale', 'Dornava', 'Dravograd', 'Duplek', 'Gorenja Vas–Poljane', 'Gorišnica', 'Gorje', 'Gornja Radgona', 'Gornji Grad', 'Gornji Petrovci', 'Grad', 'Grosuplje', 'Hajdina', 'Hoče–Slivnica', 'Hodoš', 'Horjul', 'Hrastnik', 'Hrpelje–Kozina', 'Idrija', 'Ig', 'Ilirska Bistrica', 'Ivančna Gorica', 'Izola', 'Jesenice', 'Jezersko', 'Juršinci', 'Kamnik', 'Kanal ob Soči', 'Kidričevo', 'Kobarid', 'Kobilje', 'Kočevje', 'Komen', 'Komenda', 'Koper', 'Kostanjevica na Krki', 'Kostel', 'Kozje', 'Kranj', 'Kranjska Gora', 'Križevci', 'Krško', 'Kungota', 'Kuzma', 'Laško', 'Lenart', 'Lendava', 'Litija', 'Ljubljana', 'Ljubno', 'Ljutomer', 'Log–Dragomer', 'Logatec', 'Loška Dolina', 'Loški Potok', 'Lovrenc na Pohorju', 'Luče', 'Lukovica', 'Majšperk', 'Makole', 'Maribor', 'Markovci', 'Medvode', 'Mengeš', 'Metlika', 'Mežica', 'Miklavž na Dravskem Polju', 'Miren–Kostanjevica', 'Mirna', 'Mirna Peč', 'Mislinja', 'Mokronog–Trebelno', 'Moravče', 'Moravske Toplice', 'Mozirje', 'Murska Sobota', 'Muta', 'Naklo', 'Nazarje', 'Nova Gorica', 'Novo Mesto', 'Odranci', 'Oplotnica', 'Ormož', 'Osilnica', 'Pesnica', 'Piran', 'Pivka', 'Podčetrtek', 'Podlehnik', 'Podvelka', 'Poljčane', 'Polzela', 'Postojna', 'Prebold', 'Preddvor', 'Prevalje', 'Ptuj', 'Puconci', 'Rače–Fram', 'Radeče', 'Radenci', 'Radlje ob Dravi', 'Radovljica', 'Ravne na Koroškem', 'Razkrižje', 'Rečica ob Savinji', 'Renče–Vogrsko', 'Ribnica', 'Ribnica na Pohorju', 'Rogaška Slatina', 'Rogašovci', 'Rogatec', 'Ruše', 'Šalovci', 'Selnica ob Dravi', 'Semič', 'Šempeter–Vrtojba', 'Šenčur', 'Šentilj', 'Šentjernej', 'Šentjur', 'Šentrupert', 'Sevnica', 'Sežana', 'Škocjan', 'Škofja Loka', 'Škofljica', 'Slovenj Gradec', 'Slovenska Bistrica', 'Slovenske Konjice', 'Šmarje pri Jelšah', 'Šmarješke Toplice', 'Šmartno ob Paki', 'Šmartno pri Litiji', 'Sodražica', 'Solčava', 'Šoštanj', 'Središče ob Dravi', 'Starše', 'Štore', 'Straža', 'Sveta Ana', 'Sveta Trojica v Slovenskih Goricah', 'Sveti Andraž v Slovenskih Goricah', 'Sveti Jurij ob Ščavnici', 'Sveti Jurij v Slovenskih Goricah', 'Sveti Tomaž', 'Tabor', 'Tišina', 'Tolmin', 'Trbovlje', 'Trebnje', 'Trnovska Vas', 'Tržič', 'Trzin', 'Turnišče', 'Velenje', 'Velika Polana', 'Velike Lašče', 'Veržej', 'Videm', 'Vipava', 'Vitanje', 'Vodice', 'Vojnik', 'Vransko', 'Vrhnika', 'Vuzenica', 'Zagorje ob Savi', 'Žalec', 'Zavrč', 'Železniki', 'Žetale', 'Žiri', 'Žirovnica', 'Zreče', 'Žužemberk'],
      'South Africa': ['Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal', 'Limpopo', 'Mpumalanga', 'North West', 'Northern Cape', 'Western Cape'],
      'South Korea': ['Busan', 'Daegu', 'Daejeon', 'Gangwon', 'Gwangju', 'Gyeonggi', 'Incheon', 'Jeju', 'North Chungcheong', 'North Gyeongsang', 'North Jeolla', 'Sejong City', 'Seoul', 'South Chungcheong', 'South Gyeongsang', 'South Jeolla', 'Ulsan'],
      'Spain': ['A Coruña', 'Albacete', 'Alicante', 'Almeria', 'Andalusia', 'Araba', 'Aragon', 'Asturias', 'Asturias, Principality of', 'Ávila', 'Badajoz', 'Balearic Islands', 'Barcelona', 'Basque Country', 'Bizkaia', 'Burgos', 'Caceres', 'Cádiz', 'Canary Islands', 'Cantabria', 'Cantabria', 'Castellón', 'Castile and Leon', 'Castilla-La Mancha', 'Catalonia', 'Ceuta', 'Ciudad Real', 'Community of Madrid', 'Córdoba', 'Cuenca', 'Estremadura', 'Galicia', 'Gipuzkoa', 'Girona', 'Granada', 'Guadalajara', 'Huelva', 'Huesca', 'Islas Baleares', 'Jaén', 'La Rioja', 'La Rioja', 'Las Palmas', 'León', 'Lleida', 'Lugo', 'Madrid', 'Málaga', 'Melilla', 'Murcia', 'Navarra', 'Navarre', 'Ourense', 'Palencia', 'Pontevedra', 'Region of Murcia', 'Salamanca', 'Santa Cruz de Tenerife', 'Segovia', 'Sevilla', 'Soria', 'Tarragona', 'Teruel', 'Toledo', 'Valencia', 'Valencian Community', 'Valladolid', 'Zamora', 'Zaragoza'],
      'Sri Lanka': ['Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Central', 'Colombo', 'Eastern', 'Galle', 'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara', 'Kandy', 'Kegalle', 'Kilinochchi', 'Kurunegala', 'Mannar', 'Matale', 'Matara', 'Monaragala', 'Mullaitivu', 'North Central', 'North Western', 'Northern', 'Nuwara Eliya', 'Polonnaruwa', 'Puttalam', 'Ratnapura', 'Sabaragamuwa', 'Southern', 'Trincomalee', 'Uva', 'Vavuniya', 'Western'],
      'Sweden': ['Blekinge', 'Dalarna', 'Gävleborg', 'Gotland', 'Halland', 'Jämtland', 'Jönköping', 'Kalmar', 'Kronoberg', 'Norrbotten', 'Örebro', 'Östergötland', 'Skåne', 'Södermanland', 'Stockholm', 'Uppsala', 'Värmland', 'Västerbotten', 'Västernorrland', 'Västmanland', 'Västra Götaland'],
      'Switzerland': ['Aargau', 'Appenzell Ausserrhoden', 'Appenzell Innerrhoden', 'Basel-Land', 'Basel-Stadt', 'Bern', 'Fribourg', 'Geneva', 'Glarus', 'Graubünden', 'Jura', 'Lucerne', 'Neuchâtel', 'Nidwalden', 'Obwalden', 'Schaffhausen', 'Schwyz', 'Solothurn', 'St. Gallen', 'Thurgau', 'Ticino', 'Uri', 'Valais', 'Vaud', 'Zug', 'Zürich'],
      'Thailand': ['Amnat Charoen', 'Ang Thong', 'Bangkok', 'Bueng Kan', 'Buri Ram', 'Chachoengsao', 'Chai Nat', 'Chaiyaphum', 'Chanthaburi', 'Chiang Mai', 'Chiang Rai', 'Chon Buri', 'Chumphon', 'Kalasin', 'Kamphaeng Phet', 'Kanchanaburi', 'Khon Kaen', 'Krabi', 'Lampang', 'Lamphun', 'Loei', 'Lop Buri', 'Mae Hong Son', 'Maha Sarakham', 'Mukdahan', 'Nakhon Nayok', 'Nakhon Pathom', 'Nakhon Phanom', 'Nakhon Ratchasima', 'Nakhon Sawan', 'Nakhon Si Thammarat', 'Nan', 'Narathiwat', 'Nong Bua Lam Phu', 'Nong Khai', 'Nonthaburi', 'Pathum Thani', 'Pattani', 'Pattaya', 'Phangnga', 'Phatthalung', 'Phayao', 'Phetchabun', 'Phetchaburi', 'Phichit', 'Phitsanulok', 'Phra Nakhon Si Ayutthaya', 'Phrae', 'Phuket', 'Prachin Buri', 'Prachuap Khiri Khan', 'Ranong', 'Ratchaburi', 'Rayong', 'Roi Et', 'Sa Kaeo', 'Sakon Nakhon', 'Samut Prakan', 'Samut Sakhon', 'Samut Songkhram', 'Saraburi', 'Satun', 'Si Sa Ket', 'Sing Buri', 'Songkhla', 'Sukhothai', 'Suphan Buri', 'Surat Thani', 'Surin', 'Tak', 'Trang', 'Trat', 'Ubon Ratchathani', 'Udon Thani', 'Uthai Thani', 'Uttaradit', 'Yala', 'Yasothon'],
      'Turkey': ['Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya', 'Ankara', 'Antalya', 'Ardahan', 'Artvin', 'Aydın', 'Balıkesir', 'Bartın', 'Batman', 'Bayburt', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Düzce', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkâri', 'Hatay', 'Iğdır', 'Isparta', 'İstanbul', 'İzmir', 'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu', 'Kayseri', 'Kilis', 'Kırıkkale', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Mardin', 'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye', 'Rize', 'Sakarya', 'Samsun', 'Şanlıurfa', 'Siirt', 'Sinop', 'Sivas', 'Şırnak', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak'],
      'Ukraine': ['Autonomous Republic of Crimea', 'Cherkaska', 'Chernihivska', 'Chernivetska', 'Dnipropetrovska', 'Donetska', 'Ivano-Frankivska', 'Kharkivska', 'Khersonska', 'Khmelnytska', 'Kirovohradska', 'Kyiv', 'Kyivska', 'Luhanska', 'Lvivska', 'Mykolaivska', 'Odeska', 'Poltavska', 'Rivnenska', 'Sevastopol', 'Sumska', 'Ternopilska', 'Vinnytska', 'Volynska', 'Zakarpatska', 'Zaporizka', 'Zhytomyrska'],
      'United Arab Emirates': ['Abu Dhabi', 'Ajman', 'Dubai', 'Fujairah', 'Ras Al Khaimah', 'Sharjah', 'Umm Al Quwain'],
      'United Kingdom': ['Aberdeen', 'Aberdeenshire', 'Angus', 'Antrim and Newtownabbey', 'Ards and North Down', 'Argyll and Bute', 'Armagh, Banbridge and Craigavon', 'Barking and Dagenham', 'Barnet', 'Barnsley', 'Bath and North East Somerset', 'Bedford', 'Belfast', 'Bexley', 'Birmingham', 'Blackburn with Darwen', 'Blackpool', 'Blaenau Gwent', 'Bolton', 'Bournemouth, Christchurch and Poole', 'Bracknell Forest', 'Bradford', 'Brent', 'Bridgend', 'Brighton and Hove', 'Bristol', 'Bromley', 'Buckinghamshire', 'Bury', 'Caerphilly', 'Calderdale', 'Cambridgeshire', 'Camden', 'Cardiff', 'Carmarthenshire', 'Causeway Coast and Glens', 'Central Bedfordshire', 'Ceredigion', 'Cheshire East', 'Cheshire West and Chester', 'City of Kingston upon Hull', 'City of Southampton', 'Clackmannanshire', 'Conwy', 'Cornwall', 'Coventry', 'Croydon', 'Cumbria', 'Darlington', 'Denbighshire', 'Derby', 'Derbyshire', 'Derry City and Strabane', 'Devon', 'Doncaster', 'Dorset', 'Dudley', 'Dumfries and Galloway', 'Dundee', 'Durham', 'Ealing', 'East Ayrshire', 'East Dunbartonshire', 'East Lothian', 'East Renfrewshire', 'East Riding of Yorkshire', 'East Sussex', 'Edinburgh', 'Enfield', 'England', 'Essex', 'Falkirk', 'Fermanagh and Omagh', 'Fife', 'Flintshire', 'Gateshead', 'Glasgow', 'Gloucestershire', 'Greenwich', 'Gwynedd', 'Hackney', 'Halton', 'Hammersmith and Fulham', 'Hampshire', 'Haringey', 'Harrow', 'Hartlepool', 'Havering', 'Herefordshire', 'Hertfordshire', 'Highland', 'Hillingdon', 'Hounslow', 'Inverclyde', 'Isle of Anglesey', 'Isle of Wight', 'Isles of Scilly', 'Islington', 'Kensington and Chelsea', 'Kent', 'Kingston upon Thames', 'Kirklees', 'Knowsley', 'Lambeth', 'Lancashire', 'Leeds', 'Leicester', 'Leicestershire', 'Lewisham', 'Lincolnshire', 'Lisburn and Castlereagh', 'Liverpool', 'London', 'Luton', 'Manchester', 'Medway', 'Merthyr Tydfil', 'Merton', 'Mid and East Antrim', 'Mid Ulster', 'Middlesbrough', 'Midlothian', 'Milton Keynes', 'Monmouthshire', 'Moray', 'Neath Port Talbot', 'Newcastle upon Tyne', 'Newham', 'Newport', 'Newry, Mourne and Down', 'Norfolk', 'North Ayrshire', 'North East Lincolnshire', 'North Lanarkshire', 'North Lincolnshire', 'North Northamptonshire', 'North Somerset', 'North Tyneside', 'North Yorkshire', 'Northern Ireland', 'Northumberland', 'Nottingham', 'Nottinghamshire', 'Oldham', 'Orkney Islands', 'Outer Hebrides', 'Oxfordshire', 'Pembrokeshire', 'Perth and Kinross', 'Peterborough', 'Plymouth', 'Portsmouth', 'Powys', 'Reading', 'Redbridge', 'Redcar and Cleveland', 'Renfrewshire', 'Rhondda Cynon Taf', 'Richmond upon Thames', 'Rochdale', 'Rotherham', 'Rutland', 'Salford', 'Sandwell', 'Scotland', 'Scottish Borders', 'Sefton', 'Sheffield', 'Shetland Islands', 'Shropshire', 'Slough', 'Solihull', 'Somerset', 'South Ayrshire', 'South Gloucestershire', 'South Lanarkshire', 'South Tyneside', 'Southend-on-Sea', 'Southwark', 'St Helens', 'Staffordshire', 'Stirling', 'Stockport', 'Stockton-on-Tees', 'Stoke-on-Trent', 'Suffolk', 'Sunderland', 'Surrey', 'Sutton', 'Swansea', 'Swindon', 'Tameside', 'Telford and Wrekin', 'Thurrock', 'Torbay', 'Torfaen', 'Tower Hamlets', 'Trafford', 'Vale of Glamorgan', 'Wakefield', 'Wales', 'Walsall', 'Waltham Forest', 'Wandsworth', 'Warrington', 'Warwickshire', 'West Berkshire', 'West Dunbartonshire', 'West Lothian', 'West Northamptonshire', 'West Sussex', 'Westminster', 'Wigan', 'Wiltshire', 'Windsor and Maidenhead', 'Wirral', 'Wokingham', 'Wolverhampton', 'Worcestershire', 'Wrexham', 'York'],
      'United States': ['Alabama', 'Alaska', 'American Samoa', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Guam', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Northern Mariana Islands', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'United States Minor Outlying Islands', 'United States Virgin Islands', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'],
      'Uzbekistan': ['Andijan', 'Bukhara', 'Fergana', 'Jizzakh', 'Karakalpakstan', 'Namangan', 'Navoiy', 'Qashqadaryo', 'Samarqand', 'Sirdaryo', 'Surxondaryo', 'Tashkent', 'Tashkent', 'Xorazm'],
      'Vietnam': ['An Giang', 'Bắc Ninh', 'Cà Mau', 'Cần Thơ', 'Cao Bằng', 'Đà Nẵng', 'Đắk Lắk', 'Điện Biên', 'Đồng Nai', 'Đồng Tháp', 'Gia Lai', 'Hà Nội', 'Hà Tĩnh', 'Hải Phòng', 'Hồ Chí Minh', 'Hưng Yên', 'Khánh Hòa', 'Lai Châu', 'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Nghệ An', 'Ninh Bình', 'Phú Thọ', 'Quảng Ngãi', 'Quảng Ninh', 'Quảng Trị', 'Sơn La', 'Tây Ninh', 'Thái Nguyên', 'Thanh Hóa', 'Thừa Thiên-Huế', 'Tuyên Quang', 'Vĩnh Long'],
    };

    return countryStates[countryName] ?? [];
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
    _availablePrStates = _getStatesForCountry(country);
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
