import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'dart:io';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/profile.service.dart';
import 'package:manager/services/location.service.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/configs.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

import '../../../services/language.service.dart';

class UpdateOrganizationViewModel extends ReactiveViewModel {
  final _apiService = locator<ApiService>();
  final _filePickerService = FilePickerService();
  final _profileService = locator<ProfileService>();
  final _locationService = locator<LocationService>();

  // ProfileModel to store API response
  final ReactiveValue<ProfileModel?> _profileModel =
      ReactiveValue<ProfileModel?>(null);
  ProfileModel? get profileModel => _profileModel.value;

  // Profile image file
  File? _profileImageFile;
  File? get profileImageFile => _profileImageFile;

  String? _organizationType;
  String? get organizationType => _organizationType;
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  RxBool isEmailVarificationSend=false.obs;
  // Organization basic info controllers
  final TextEditingController yourNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Corporate Address controllers
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Factory Address controllers
  final TextEditingController factoryAddressLine1Controller =
      TextEditingController();
  final TextEditingController factoryAddressLine2Controller =
      TextEditingController();
  final TextEditingController factoryCityController = TextEditingController();
  final TextEditingController factoryStateController = TextEditingController();
  final TextEditingController factoryCountryController =
      TextEditingController();
  final TextEditingController factoryPinCodeController =
      TextEditingController();

  // Additional info controllers
  final TextEditingController establishedYearController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherDesignationController =
      TextEditingController();
  final TextEditingController organizationNameController = TextEditingController();
  final TextEditingController otherDescriptionController = TextEditingController();

  // Designation type
  final ReactiveValue<String> _designationType = ReactiveValue<String>('md');
  String get designationType => _designationType.value;

  void updateDesignationType(String? value) {
    if (value != null) {
      _designationType.value = value;
      notifyListeners();
    }
  }

  // Language selection
  String _language = 'English';
  String get language => _language;

  void updateLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  // Other designation flag
  final ReactiveValue<bool> _showOtherDesignation = ReactiveValue<bool>(false);
  bool get showOtherDesignation => _showOtherDesignation.value;

  set showOtherDesignation(bool value) {
    _showOtherDesignation.value = value;
    notifyListeners();
  }

  // Same as corporate address flag
  final ReactiveValue<bool> _sameAsCorpAddress = ReactiveValue<bool>(false);
  bool get sameAsCorpAddress => _sameAsCorpAddress.value;

  void toggleSameAsCorpAddress(bool value) {
    _sameAsCorpAddress.value = value;

    if (value) {
      // Copy corporate address to factory address
      copyCorporateToFactory();
    } else {
      // Clear factory address when unchecked
      factoryAddressLine1Controller.clear();
      factoryAddressLine2Controller.clear();
      factoryCityController.clear();
      factoryStateController.clear();
      factoryCountryController.clear();
      factoryPinCodeController.clear();
      _factoryCountry.value = 'India';
      _selectedFactoryState.value = null;
      // Load states for India when clearing
      onFactoryCountryChanged('India');
    }

    notifyListeners();
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

  // Factory country dropdown
  final ReactiveValue<String> _factoryCountry = ReactiveValue<String>('India');
  String get factoryCountry => _factoryCountry.value;

  void updateFactoryCountry(String? value) {
    if (value != null) {
      _factoryCountry.value = value;
      factoryCountryController.text = value;
      notifyListeners();
    }
  }

  // State management
  final ReactiveValue<String?> _selectedState = ReactiveValue<String?>(null);
  String? get selectedState => _selectedState.value;

  final ReactiveValue<String?> _selectedFactoryState = ReactiveValue<String?>(null);
  String? get selectedFactoryState => _selectedFactoryState.value;

  // Available states based on country
  List<String> _availableStates = _getStatesForCountry('India');
  List<String> get availableStates => _availableStates;

  List<String> _availableFactoryStates = _getStatesForCountry('India');
  List<String> get availableFactoryStates => _availableFactoryStates;

  void updateState(String? value) {
    _selectedState.value = value;
    stateController.text = value ?? '';
    notifyListeners();
  }

  void updateFactoryState(String? value) {
    _selectedFactoryState.value = value;
    factoryStateController.text = value ?? '';
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

  void onFactoryCountryChanged(String country) async {
    // Clear current state
    _selectedFactoryState.value = null;
    factoryStateController.clear();
    _availableFactoryStates = [];
    notifyListeners();
    
    // First, try to load from package asynchronously
    try {
      final packageStates = await _getStatesForCountryAsync(country);
      if (packageStates.isNotEmpty) {
        _availableFactoryStates = packageStates;
        notifyListeners();
        //AppLogger.info('Loaded ${packageStates.length} factory states from package for $country');
      }
    }
    catch (e) {
     //AppLogger.error('Error fetching factory states from package: $e');
    }

  }

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
  
  static List<String> _getStatesForCountry(String country) {
    // This is a synchronous fallback for initialization
    return [];
  }

  // Edit mode flags
  bool? isPersonalInfoEditable = false;
  bool? isCorporateAddressEditable = false;
  bool? isFactoryAddressEditable = false;
  bool? isAdditionalInfoEditable = false;

  void togglePersonalInfoEdit() async {
    if (isPersonalInfoEditable ?? false) {
      // Currently in edit mode, save the data
      await updatePersonalInfo();
    } else {
      // Currently in view mode, switch to edit mode
      isPersonalInfoEditable = true;
      notifyListeners();
    }
  }
  void updateOrganizationType(String? value) {
    _organizationType = value;
    if (value != "Others") {
      otherDescriptionController.clear();
    }

    notifyListeners();
  }
  void toggleCorporateAddressEdit() async {
    if (isCorporateAddressEditable ?? false) {
      // Currently in edit mode, validate and save the data
      if (formKey.currentState?.validate() ?? false) {
        await updateCorporateAddress();
      } else {
        // Show error message if validation fails
        Fluttertoast.showToast(
          msg: LanguageService.get('please_fill_all_required_fields'),
          backgroundColor: Colors.red,
        );
      }
    } else {
      // Currently in view mode, switch to edit mode
      isCorporateAddressEditable = true;
      notifyListeners();
    }
  }

  void toggleFactoryAddressEdit() async {
    if (isFactoryAddressEditable ?? false) {
      // Currently in edit mode, save the data
      await updateFactoryAddress();
    } else {
      // Currently in view mode, switch to edit mode
      isFactoryAddressEditable = true;
      notifyListeners();
    }
  }

  // Copy corporate address to factory address
  void copyCorporateToFactory() async {
    factoryAddressLine1Controller.text = addressLine1Controller.text;
    factoryAddressLine2Controller.text = addressLine2Controller.text;
    factoryCityController.text = cityController.text;
    factoryPinCodeController.text = pinCodeController.text;
    
    // Copy country and update factory country
    _factoryCountry.value = _country.value;
    factoryCountryController.text = _country.value;
    
    // Copy available states first
    _availableFactoryStates = List.from(_availableStates);
    
    // Copy state value
    _selectedFactoryState.value = _selectedState.value;
    factoryStateController.text = stateController.text;
    
    notifyListeners();
  }

  void toggleAdditionalInfoEdit() {
    isAdditionalInfoEditable = !(isAdditionalInfoEditable ?? false);
    notifyListeners();
  }

  // Logo management
  String logoUrl = '';
  bool hasLogoFile = false;

  // Profile image management
  String profileImageUrl = '';
  bool hasProfileImageFile = false;

  // Upload status
  final ReactiveValue<bool> _isUploading = ReactiveValue<bool>(false);
  bool get isUploading => _isUploading.value;

  final ReactiveValue<double> _uploadProgress = ReactiveValue<double>(0.0);
  double get uploadProgress => _uploadProgress.value;

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
  
  Future<void> _loadCountries() async {
    try {
      final countriesList = await csc.getAllCountries();
      _countriesList = countriesList.map((country) => country.name).toList()..sort();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error getting countries: $e');
    }
  }

  // Units management
  final ReactiveValue<List<Map<String, dynamic>>> _units = ReactiveValue<List<Map<String, dynamic>>>([]);
  List<Map<String, dynamic>> get units => _units.value;

  Map<int, TextEditingController> unitNameControllers = {};
  Map<int, TextEditingController> unitLocalityControllers = {};
  Map<int, String?> unitCountries = {};

  void addUnit() {
    final newIndex = _units.value.length;
    _units.value = [
      ..._units.value,
      {'name': '', 'locality': '', 'country': null},
    ];

    // Initialize controllers for the new unit
    unitNameControllers[newIndex] = TextEditingController();
    unitLocalityControllers[newIndex] = TextEditingController();
    unitCountries[newIndex] = null;

    notifyListeners();
  }

  void removeUnit(int index) {
    if (index < _units.value.length) {
      // Dispose controllers
      unitNameControllers[index]?.dispose();
      unitLocalityControllers[index]?.dispose();

      // Remove from lists
      _units.value = List.from(_units.value)..removeAt(index);

      // Rebuild controller maps with updated indices
      _rebuildControllerMaps();

      notifyListeners();
    }
  }

  void updateUnitCountry(int index, String? country) {
    if (index < _units.value.length) {
      unitCountries[index] = country;
      notifyListeners();
    }
  }

  void _rebuildControllerMaps() {
    final newNameControllers = <int, TextEditingController>{};
    final newLocalityControllers = <int, TextEditingController>{};
    final newCountries = <int, String?>{};

    for (int i = 0; i < _units.value.length; i++) {
      if (unitNameControllers.containsKey(i)) {
        newNameControllers[i] = unitNameControllers[i]!;
        newLocalityControllers[i] = unitLocalityControllers[i]!;
        newCountries[i] = unitCountries[i];
      }
    }

    unitNameControllers = newNameControllers;
    unitLocalityControllers = newLocalityControllers;
    unitCountries = newCountries;
  }

  // Image picker methods (UI only)
  Future<void> pickGalleryImage() async {
    // UI placeholder - no actual file picking logic
    hasLogoFile = true;
    notifyListeners();
  }

  Future<void> takePhoto() async {
    // UI placeholder - no actual camera logic
    hasLogoFile = true;
    notifyListeners();
  }

  void onLogoRemove() {
    logoUrl = '';
    hasLogoFile = false;
    notifyListeners();
  }

  Future<void> pickProfileImageFromGallery() async {
    final pickerResult = await _filePickerService.pickImageFromGallery(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    pickerResult.fold(
      (failure) {
        // Only show error if it's not "No image selected"
        if (failure.message != 'No image selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        _profileImageFile = file;
        hasProfileImageFile = true;
        notifyListeners();
        // Automatically upload the selected image
        uploadProfileImage();
      },
    );
  }

  Future<void> takeProfilePhoto() async {
    final pickerResult = await _filePickerService.takePhoto(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    pickerResult.fold(
      (failure) {
        // Only show error if it's not "No photo taken"
        if (failure.message != 'No photo taken') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        _profileImageFile = file;
        hasProfileImageFile = true;
        notifyListeners();
        // Automatically upload the captured photo
        uploadProfileImage();
      },
    );
  }

  void onProfileImageRemove() {
    profileImageUrl = '';
    hasProfileImageFile = false;
    _profileImageFile = null;
    notifyListeners();
  }

  // Upload profile image to server
  Future<void> uploadProfileImage() async {
    if (_profileImageFile == null) return;

    _isUploading.value = true;
    notifyListeners();

    try {
      // Create FormData for image upload
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          _profileImageFile!.path,
          filename:
              'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final response = await _apiService.put(
        url: ApiEndpoints.updateProfile,
        data: formData,
      );

      if (response.statusCode == 200) {
        // Handle response
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Use ProfileService to update profile data
        await _profileService.updateProfileData(responseData);

        // Refresh profile data from API to get latest data
        await refreshProfileData();

        Fluttertoast.showToast(
          msg: 'Profile image updated successfully',
          backgroundColor: Colors.green,
        );

        // Clear the file since it's now uploaded
        _profileImageFile = null;
        notifyListeners();
      } else {
        AppLogger.error(
          'Failed to update profile image: ${response.statusMessage}',
        );
        Fluttertoast.showToast(
          msg: 'Failed to update profile image',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLogger.error('Error uploading profile image: $e');
      Fluttertoast.showToast(
        msg: 'Error uploading profile image: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      _isUploading.value = false;
      notifyListeners();
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the data to send
      final updateData = {
        'organizationName': organizationNameController.text,
        'unitName': unitNameController.text,
        'fullName': yourNameController.text,
        'designation': _designationType.value,
        'phone': phoneController.text,
        'email': emailController.text,
        'processorType':_organizationType !='Others' ? _organizationType :"Others: ${otherDescriptionController.text}"
      };

      AppLogger.info('Updating personal info with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isPersonalInfoEditable = false;

      Fluttertoast.showToast(
        msg: 'Personal information updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating personal info: $e');
      Fluttertoast.showToast(
        msg: 'Error updating personal information: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update corporate address
  Future<void> updateCorporateAddress() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the corporate address data to send
      final updateData = {
        'corporateAddress': {
          'addressLine1': addressLine1Controller.text,
          'addressLine2': addressLine2Controller.text,
          'city': cityController.text,
          'state': stateController.text,
          'country': _country.value,
          'pincode': pinCodeController.text,
        },
        'factoryAddress': {
          'addressLine1': factoryAddressLine1Controller.text,
          'addressLine2': factoryAddressLine2Controller.text,
          'city': factoryCityController.text,
          'state': factoryStateController.text,
          'country': _factoryCountry.value,
          'pincode': factoryPinCodeController.text,
        },
        "isSameAddress":sameAsCorpAddress,
        // "isSameAddress":sameAsCorpAddress,
      };

      AppLogger.info('Updating corporate address with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isCorporateAddressEditable = false;

      Fluttertoast.showToast(
        msg: 'Corporate address updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating corporate address: $e');
      Fluttertoast.showToast(
        msg: 'Error updating corporate address: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update factory address
  Future<void> updateFactoryAddress() async {
    setBusy(true);
    notifyListeners();

    try {
      // Prepare the factory address data to send
      final updateData = {
        'factoryAddress': {
          'addressLine1': factoryAddressLine1Controller.text,
          'addressLine2': factoryAddressLine2Controller.text,
          'city': factoryCityController.text,
          'state': factoryStateController.text,
          'country': _factoryCountry.value,
          'pincode': factoryPinCodeController.text,
        },
      };

      AppLogger.info('Updating factory address with data: $updateData');

      // Use ProfileService to update profile data
      await _profileService.updateProfileData(updateData);

      // Refresh profile data from API to get latest data
      await refreshProfileData();

      // Switch back to view mode
      isFactoryAddressEditable = false;

      Fluttertoast.showToast(
        msg: 'Factory address updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppLogger.error('Error updating factory address: $e');
      Fluttertoast.showToast(
        msg: 'Error updating factory address: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Initialize the view model and load profile data
  Future<void> init() async {
    setBusy(true);
    await loadProfileData();
    setBusy(false);
  }

  // Refresh profile data from API after update
  Future<void> refreshProfileData() async {
    try {
      AppLogger.info('Refreshing profile data from API...');
      // Use ProfileService to refresh profile data
      await _profileService.refreshProfile();

      // Update local model with fresh data
      final updatedProfile = _profileService.globalProfileModel;
      if (updatedProfile != null) {
        _profileModel.value = updatedProfile;
        _sameAsCorpAddress.value = updatedProfile.profile?.isSameAddress ?? false;

        _populateFormWithProfileData(updatedProfile);
        AppLogger.info('Profile data refreshed successfully');
      }
    } catch (e) {
      AppLogger.error('Error refreshing profile data: $e');
    }
  }

  // Load profile data from ProfileService (no API call)
  Future<void> loadProfileData() async {
    try {
      // Get profile data from ProfileService (no API call)
      final profile = _profileService.globalProfileModel;
      if (profile != null) {
        _profileModel.value = profile;
        _sameAsCorpAddress.value = profile.profile?.isSameAddress ?? false;
        _populateFormWithProfileData(profile);
        AppLogger.info('Profile data loaded from ProfileService');
      }
      else {
        AppLogger.warning('No profile data available in ProfileService');
      }
    } catch (e) {
      AppLogger.error('Error loading profile data: $e');
    }
  }

  // Populate form fields with profile data
  void _populateFormWithProfileData(ProfileModel profile) async {

    if (profile.profile?.user != null) {
      yourNameController.text = profile.profile?.user!.fullName!.toUpperCase() ?? '';
      phoneController.text = profile.profile?.user!.phone ?? '';
      emailController.text = profile.profile?.user!.email ?? '';
    }

    // Set organization info - FIXED: organizationName should show organization name, not user name
    organizationNameController.text = profile.profile?.organizationName ?? '';
    _organizationType=profile.profile?.user?.processorType;
    unitNameController.text=profile.profile?.unitName??'';

    // Set designation
    if (profile.profile?.designation != null && (profile.profile?.designation??'').isNotEmpty) {
      _designationType.value = (profile.profile?.designation??'');
    }

    // Set profile image URL
    if (profile.profile?.profileImage != null && (profile.profile?.profileImage??'').isNotEmpty) {
      String baseUrl = Configurations().url;
      if ((profile.profile?.profileImage??'').startsWith('/')) {
        profileImageUrl = baseUrl + (profile.profile?.profileImage??'');
      } else {
        profileImageUrl = '$baseUrl/${(profile.profile?.profileImage??'')}';
      }
    }



    // Set corporate address
    if (profile.profile?.corporateAddress != null) {
      addressLine1Controller.text =
          profile.profile?.corporateAddress!.addressLine1 ?? '';
      addressLine2Controller.text =
          profile.profile?.corporateAddress!.addressLine2 ?? '';
      cityController.text = profile.profile?.corporateAddress!.city ?? '';
      stateController.text = profile.profile?.corporateAddress!.state ?? '';
      countryController.text = profile.profile?.corporateAddress!.country ?? '';
      _country.value = profile.profile?.corporateAddress!.country ?? 'India';
      pinCodeController.text = profile.profile?.corporateAddress!.pincode ?? '';
      
      // Load states asynchronously for the country
      final corporateCountry = _country.value;
      _loadStatesForCorporateAddress(corporateCountry, stateController.text);
    }

    // Set factory address
    if (profile.profile?.factoryAddress != null) {
      factoryAddressLine1Controller.text =
          profile.profile?.factoryAddress!.addressLine1 ?? '';
      factoryAddressLine2Controller.text =
          profile.profile?.factoryAddress!.addressLine2 ?? '';
      factoryCityController.text = profile.profile?.factoryAddress!.city ?? '';
      factoryStateController.text = profile.profile?.factoryAddress!.state ?? '';
      factoryCountryController.text = profile.profile?.factoryAddress!.country ?? '';
      _factoryCountry.value = profile.profile?.factoryAddress!.country ?? 'India';
      factoryPinCodeController.text = profile.profile?.factoryAddress!.pincode ?? '';
      
      // Load states asynchronously for the factory country
      final factoryCountry = _factoryCountry.value;
      _loadStatesForFactoryAddress(factoryCountry, factoryStateController.text);
    }
  }

  // Load states for corporate address and set the selected state
  Future<void> _loadStatesForCorporateAddress(String country, String stateValue) async {
    try {
      final states = await _getStatesForCountryAsync(country);
      if (states.isNotEmpty) {
        _availableStates = states;
        if (stateValue.isNotEmpty) {
          _selectedState.value = stateValue;
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error loading states for corporate address: $e');
    }
  }

  // Load states for factory address and set the selected state
  Future<void> _loadStatesForFactoryAddress(String country, String stateValue) async {
    try {
      final states = await _getStatesForCountryAsync(country);
      if (states.isNotEmpty) {
        _availableFactoryStates = states;
        if (stateValue.isNotEmpty) {
          _selectedFactoryState.value = stateValue;
        }
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error loading states for factory address: $e');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    yourNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    otherDesignationController.dispose();

    // Corporate address controllers
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pinCodeController.dispose();

    // Factory address controllers
    factoryAddressLine1Controller.dispose();
    factoryAddressLine2Controller.dispose();
    factoryCityController.dispose();
    factoryStateController.dispose();
    factoryCountryController.dispose();
    factoryPinCodeController.dispose();

    // Additional info controllers
    establishedYearController.dispose();
    descriptionController.dispose();

    for (var controller in unitNameControllers.values) {
      controller.dispose();
    }
    for (var controller in unitLocalityControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
  Future<void> sendVerificationEmail(String email) async {

    try{
      isEmailVarificationSend.value=true;
      final apiResponse = await _apiService.post(
        url: ApiEndpoints.send_email_varification,
        data: {'email': email},
      );

      if (apiResponse.statusCode == 200) {

        Fluttertoast.showToast(
          msg: LanguageService.get('Email sent successfully'),
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );

      } else {
        isEmailVarificationSend.value=false;
        throw Exception(
          apiResponse.data['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }

  }
  // Update phone number from string (used by phone input widget)
  void updatePhoneNumberFromString(String phoneNumber) {
    phoneController.text = phoneNumber;
    notifyListeners();
  }
}
