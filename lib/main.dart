import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/bottom_sheets.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/notification.service.dart';

import 'app/app.view.dart';
import 'core/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  // await initPrefs();
  await setupStorage();
  AppLogger.info(getUser().toJson());

  setUpLocators();
  setUpBottomSheets();
  setUpDialogs();
  await LanguageService.load();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.getToken();

  runApp(AppView());
}
