import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/user.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../services/dialogs.service.dart';
import '../../../../services/profile.service.dart';
import '../../../../widgets/dialogs/loader/loader_dialog.view.dart';

class LanguageController extends GetxController {
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  var selectedLanguageCode = ''.obs;
  RxBool isAutoTranslateEnabled = false.obs;

  ValueNotifier<LanguageModel> selectedChatLanguage = ValueNotifier(
    LanguageModel(
      name: 'English',
      displayName: 'English',
      code: 'English',
      flag: '🇺🇸',
    ),
  );

  final List<LanguageModel> languages = [
    LanguageModel(
      name: 'English',
      displayName: 'English',
      code: 'en',
      flag: '🇺🇸',
    ),
    LanguageModel(
      name: 'English (UK)',
      displayName: 'English (UK)',
      code: 'en-GB',
      flag: '🇬🇧',
    ),
    LanguageModel(
      name: 'Hindi',
      displayName: 'हिन्दी',
      code: 'hi',
      flag: '🇮🇳',
    ),
    LanguageModel(
      name: 'Chinese (Simplified)',
      displayName: '中文（简体）',
      code: 'zh',
      flag: '🇨🇳',
    ),
    LanguageModel(
      name: 'Spanish',
      displayName: 'Español',
      code: 'es',
      flag: '🇪🇸',
    ),
    LanguageModel(
      name: 'Japanese',
      displayName: '日本語',
      code: 'ja',
      flag: '🇯🇵',
    ),
    LanguageModel(
      name: 'German',
      displayName: 'Deutsch',
      code: 'de',
      flag: '🇩🇪',
    ),
    LanguageModel(
      name: 'French',
      displayName: 'Français',
      code: 'fr',
      flag: '🇫🇷',
    ),
    LanguageModel(
      name: 'Arabic',
      displayName: 'العربية',
      code: 'ar',
      flag: '🇸🇦',
    ),
    LanguageModel(
      name: 'Portuguese',
      displayName: 'Português',
      code: 'pt',
      flag: '🇵🇹',
    ),
    LanguageModel(
      name: 'Russian',
      displayName: 'Русский',
      code: 'ru',
      flag: '🇷🇺',
    ),
    LanguageModel(
      name: 'Bengali',
      displayName: 'বাংলা',
      code: 'bn',
      flag: '🇧🇩',
    ),
    LanguageModel(
      name: 'Turkish',
      displayName: 'Türkçe',
      code: 'tr',
      flag: '🇹🇷',
    ),
    LanguageModel(
      name: 'Italian',
      displayName: 'Italiano',
      code: 'it',
      flag: '🇮🇹',
    ),
    LanguageModel(name: 'Korean', displayName: '한국어', code: 'ko', flag: '🇰🇷'),
    LanguageModel(
      name: 'Vietnamese',
      displayName: 'Tiếng Việt',
      code: 'vi',
      flag: '🇻🇳',
    ),
    LanguageModel(name: 'Thai', displayName: 'ไทย', code: 'th', flag: '🇹🇭'),
    LanguageModel(
      name: 'Dutch',
      displayName: 'Nederlands',
      code: 'nl',
      flag: '🇳🇱',
    ),
    LanguageModel(
      name: 'Polish',
      displayName: 'Polski',
      code: 'pl',
      flag: '🇵🇱',
    ),
    LanguageModel(
      name: 'Malay/Indonesian',
      displayName: 'Bahasa Melayu / Bahasa Indonesia',
      code: 'ms',
      flag: '🇮🇩',
    ),
    LanguageModel(
      name: 'Ukrainian',
      displayName: 'Українська',
      code: 'uk',
      flag: '🇺🇦',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentLanguage();
    _loadChatLanguage();
    _initData();
  }

  Future<void> _initData() async {
    final token = getUser().token;
    if (token == null || token.isEmpty || token == 'null') {
      AppLogger.info(
        'LanguageController: No valid token, skipping profile refresh',
      );
      return;
    }

    await _profileService.refreshProfile();
    print(
      "_profileService.globalProfileModel?.profile:- ${_profileService.globalProfileModel?.profile?.id}",
    );
    isAutoTranslateEnabled.value =
        _profileService.globalProfileModel?.profile?.autoChatLanguage ?? false;
    print(
      "_profileService.globalProfileModel?.profile autoChatLanguage:- ${_profileService.globalProfileModel?.profile?.autoChatLanguage}",
    );
  }

  void _loadCurrentLanguage() {
    final currentLang = getSelectedLanguage();
    selectedLanguageCode.value = currentLang;
  }

  void _loadChatLanguage() {
    LanguageModel chatLang = languages.first;
    String selectedChatLanguageCode = getChatSelectedLanguage();

    languages.forEach((lang) {
      if (selectedChatLanguageCode == lang.code) {
        chatLang = lang;
      }
    });

    selectedChatLanguage.value = chatLang;
  }

  List<LanguageModel> get filteredLanguages =>
      searchQuery.value.isEmpty
          ? languages
          : languages
          .where(
            (lang) => lang.name.toLowerCase().contains(
          searchQuery.value.toLowerCase(),
        ),
      )
          .toList();

  Future<void> selectLanguage(LanguageModel lang) async {
    selectedLanguageCode.value = lang.name;
  }

  void selectChatLanguage(LanguageModel lang) {
    _profileService.chatLanguage = lang.code;
    selectedChatLanguage.value = lang;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  Future<void> saveLanguage() async {
    try {
      isLoading.value = true;

      // Save to storage
      await saveSelectedLanguage(selectedLanguageCode.value);

      // Update user service
      final userService = locator<UserService>();
      userService.updateSelectedLanguage(selectedLanguageCode.value);

      AppLogger.info(
        'Language saved successfully: ${selectedLanguageCode.value}',
      );

      // Reset loading before restart so controller state is clean
      // if Dart VM persists across the restart
      isLoading.value = false;
      Restart.restartApp();
    } catch (e) {
      AppLogger.error('Error saving language: $e');
      Fluttertoast.showToast(msg: 'Failed to save language. Please try again.');
      isLoading.value = false;
    }
  }

  final _dialogService = locator<DialogService>();
  final _profileService = locator<ProfileService>();

  Future<void> saveChatLanguage() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final updateData = {
              'chatLanguage': selectedChatLanguage.value.code,
            };
            await _profileService.updateProfileData(updateData);
            saveSelectedChatLanguage(selectedChatLanguage.value.code);
            Get.back();
          } catch (e) {
            AppLogger.error('Error sending feedback: $e');
            Fluttertoast.showToast(
              msg: 'Error selecting Language: $e',
              backgroundColor: Colors.red,
            );
            return false;
          }
        },
      ),
    );
  }

  Future<void> autoTranslateChatLanguage() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final updateData = {
              'AutoChatLanguage': isAutoTranslateEnabled.value,
            };
            await _profileService.updateProfileData(updateData);
            // saveSelectedChatLanguage(selectedChatLanguage.value.code);
            Get.back();
          } catch (e) {
            AppLogger.error('Error sending feedback: $e');
            Fluttertoast.showToast(
              msg: 'Error selecting Language: $e',
              backgroundColor: Colors.red,
            );
            return false;
          }
        },
      ),
    );
    print("AutoChatLanguage:-${response}");
  }
}

class LanguageModel {
  final String name;
  final String code;
  final String flag;
  final String displayName;

  LanguageModel({
    required this.name,
    required this.code,
    required this.flag,
    required this.displayName,
  });
}
