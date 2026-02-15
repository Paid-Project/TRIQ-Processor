import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/user.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CurrencyController extends GetxController {
  var selectedLanguageCode = ''.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;

  final List<LanguageModel> languages = [
    LanguageModel(name: 'English', code: 'English', flag: '🇺🇸'),
    LanguageModel(name: 'Hindi', code: 'Hindi', flag: '🇮🇳'),
    LanguageModel(name: 'Chinese (Simplified)', code: 'Chinese (Simplified)', flag: '🇨🇳'),
    LanguageModel(name: 'Spanish', code: 'Spanish', flag: '🇪🇸'),
    LanguageModel(name: 'Japanese', code: 'Japanese', flag: '🇯🇵'),
    LanguageModel(name: 'German', code: 'German', flag: '🇩🇪'),
    LanguageModel(name: 'French', code: 'French', flag: '🇫🇷'),
    LanguageModel(name: 'Arabic', code: 'Arabic', flag: '🇸🇦'),
    LanguageModel(name: 'Portuguese', code: 'Portuguese', flag: '🇵🇹'),
    LanguageModel(name: 'Russian', code: 'Russian', flag: '🇷🇺'),
    LanguageModel(name: 'Bengali', code: 'Bengali', flag: '🇧🇩'),
    LanguageModel(name: 'Turkish', code: 'Turkish', flag: '🇹🇷'),
    LanguageModel(name: 'Italian', code: 'Italian', flag: '🇮🇹'),
    LanguageModel(name: 'Korean', code: 'Korean', flag: '🇰🇷'),
    LanguageModel(name: 'Vietnamese', code: 'Vietnamese', flag: '🇻🇳'),
    LanguageModel(name: 'Thai', code: 'Thai', flag: '🇹🇭'),
    LanguageModel(name: 'Dutch', code: 'Dutch', flag: '🇳🇱'),
    LanguageModel(name: 'Polish', code: 'Polish', flag: '🇵🇱'),
    LanguageModel(name: 'Malay/Indonesian', code: 'Malay/Indonesian', flag: '🇮🇩'),
    LanguageModel(name: 'Ukrainian', code: 'Ukrainian', flag: '🇺🇦'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final currentLang = getSelectedLanguage();
    selectedLanguageCode.value = currentLang;

  }

  List<LanguageModel> get filteredLanguages =>
      searchQuery.value.isEmpty ? languages : languages.where((lang) => lang.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();

  Future<void> selectLanguage(LanguageModel lang) async {
     selectedLanguageCode.value = lang.code;
    locator<UserService>().updateSelectedLanguage(lang.name);
     await saveSelectedLanguage(lang.name);
     await saveLanguageSelectionFlag();

  }
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  Future<void> saveLanguage() async {
    Get.back();
    // try {
    //   isLoading.value = true;
    //
    //   // Save to storage
    //   await saveSelectedLanguage(selectedLanguageCode.value);
    //
    //   // Update user service
    //   final userService = locator<UserService>();
    //   userService.updateSelectedLanguage(selectedLanguageCode.value);
    //
    //   AppLogger.info('Language saved successfully: ${selectedLanguageCode.value}');
    //
    //   // Show success message
    //   Fluttertoast.showToast(msg: 'Language changed to ${selectedLanguageCode.value}. App will restart...');
    //
    //   // Wait a bit for the user to see the success message
    //   await Future.delayed(Duration(seconds: 1));
    //
    //   // Restart the manager
    //   Restart.restartApp();
    // } catch (e) {
    //   AppLogger.error('Error saving language: $e');
    //
    //   // Show error message
    //   Fluttertoast.showToast(msg: 'Failed to save language. Please try again.');
    // } finally {
    //   isLoading.value = false;
    // }
  }
}

class LanguageModel {
  final String name;
  final String code;
  final String flag;

  LanguageModel({required this.name, required this.code, required this.flag});
}
