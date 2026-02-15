// import 'package:hive_flutter/hive_flutter.dart';
//
// import '../../resources/app_resources/app_resources.dart';
// import '../models/hive/user/user.dart';
// import '../utils/app_logger.dart';
//
// Future setupStorage() async {
//   try {
//     await Hive.initFlutter();
//     Hive.registerAdapter(UserAdapter());
//     await Hive.openBox(AppStrings.triqBox);
//   } catch (e) {
//     AppLogger.error(e);
//   }
// }
//
// Future<void> clearHive() async {
//   final box = await Hive.openBox(AppStrings.triqBox);
//   await box.clear();
// }
//
// User getUser() {
//   return Hive.box(
//     AppStrings.triqBox,
//   ).get(AppStrings.triqUser, defaultValue: User());
// }
//
// Future saveUser(User user) async {
//   await Hive.box(AppStrings.triqBox,
//   ).put(AppStrings.triqUser, user);
// }
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manager/core/models/hive/user/saved_account.dart';

import '../../resources/app_resources/app_resources.dart';
import '../models/hive/user/user.dart';
import '../utils/app_logger.dart';

Future setupStorage() async {
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(SavedAccountAdapter());
    Hive.registerAdapter(RoleAdapter());
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(UserTypeAdapter());
    Hive.registerAdapter(OrganizationTypeAdapter());
    Hive.registerAdapter(UserRoleAdapter());
    await Hive.openBox(AppStrings.triqBox);
  } catch (e) {
    AppLogger.error(e);
  }
}

Future<void> clearHive() async {
  final box = await Hive.openBox(AppStrings.triqBox);

  final languageSelected = box.get('language_selected', defaultValue: false);
  final selectedLanguage = box.get('selected_language', defaultValue: 'en');

  // Clear user data
  await Hive.box(AppStrings.triqBox).put(AppStrings.triqUser, User());

  // Clear customer data
  await box.delete('customer_data');
  await box.delete('customer_id');

  // Preserve language settings
  await box.put('language_selected', languageSelected);
  await box.put('selected_language', selectedLanguage);
}

Future<void> clearUserData() async {
  final box = await Hive.openBox(AppStrings.triqBox);

  await box.delete(AppStrings.triqUser);
}

User getUser() {
  return Hive.box(
    AppStrings.triqBox,
  ).get(AppStrings.triqUser, defaultValue: User());
}

Future saveUser(User user) async {
  await Hive.box(AppStrings.triqBox).put(AppStrings.triqUser, user);
}

// Language selection methods
bool getLanguageSelectionFlag() {
  try {
    return Hive.box(
      AppStrings.triqBox,
    ).get('language_selected', defaultValue: false);
  } catch (e) {
    AppLogger.error('Error getting language selection flag: $e');
    return false;
  }
}

Future<void> saveLanguageSelectionFlag() async {
  try {
    await Hive.box(AppStrings.triqBox).put('language_selected', true);
  } catch (e) {
    AppLogger.error('Error saving language selection flag: $e');
  }
}

Future<void> saveSelectedLanguage(String languageCode) async {
  try {
    AppLogger.info('Saving selected language: $languageCode');
    await Hive.box(AppStrings.triqBox).put('selected_language', languageCode);
  } catch (e) {
    AppLogger.error('Error saving selected language: $e');
  }
}

String getSelectedLanguage() {
  try {
    AppLogger.info('Getting selected language');
    return Hive.box(
      AppStrings.triqBox,
    ).get('selected_language', defaultValue: 'English');
  } catch (e) {
    AppLogger.error('Error getting selected language: $e');
    return 'en';
  }
}

Future<void> saveSelectedChatLanguage(String languageCode) async {
  try {
    AppLogger.info('Saving selected chat language: $languageCode');
    await Hive.box(AppStrings.triqBox).put('selected_chat_language', languageCode);
  } catch (e) {
    AppLogger.error('Error saving selected chat language: $e');
  }
}

String getChatSelectedLanguage() {
  try {
    AppLogger.info('Getting selected chat language');
    return Hive.box(
      AppStrings.triqBox,
    ).get('selected_chat_language', defaultValue: 'en');
  } catch (e) {
    AppLogger.error('Error getting selected chat language: $e');
    return 'en';
  }
}
