import 'package:flutter/services.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/services/user.service.dart';
import 'dart:convert';

import '../core/storage/storage.dart';
import '../core/utils/app_logger.dart';

class LanguageService {
  static Map<String, dynamic> _data = {};
  String get _selectedLanguage =>
      locator<UserService>().selectedLanguage; // Default fallback

  static Future<void> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/lang/language.json',
      );
      _data = json.decode(jsonString);
    } catch (e) {
      AppLogger.error('Error loading language file: ${e.toString()}');
    }
  }

  static String get(String key) {
    String selectedLanguage = ["English (UK)", "English"].contains(locator<UserService>().selectedLanguage) ? "English" : locator<UserService>().selectedLanguage;
    return _data[key]?[selectedLanguage] ?? key;
  }

  static String selectLanguage() {
    return locator<UserService>().selectedLanguage;
  }

  // Get available languages
  static List<String> getLanguages() {
    if (_data.isEmpty) return ['English'];
    return _data.values.first.keys.toList().cast<String>();
  }

  // Check if language is valid
  static bool _isValidLanguage(String language) {
    if (_data.isEmpty) return false;
    return getLanguages().contains(language);
  }

  // Check if language data is loaded
  static bool isLoaded() {
    return _data.isNotEmpty;
  }
}

// Extension for easier usage
extension StringTranslation on String {
  String get lang => LanguageService.get(this);
}
