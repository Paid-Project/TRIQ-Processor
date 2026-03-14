import 'package:flutter/material.dart';
import 'package:manager/core/utils/navigation/app_navigation_observer.dart';

import 'package:manager/routes/router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../l10n/app_localizations.dart';
import '../resources/app_resources/app_resources.dart';
import 'app.vm.dart';


/// A global key for managing snack bars and other scaffold-related actions
/// throughout the manager.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// **AppView**
///
/// The root widget of the application. It sets up:
/// - `ViewModelBuilder` to manage the manager's state.
/// - `MaterialApp` with light and dark themes.
/// - `StackedService` for navigation.
/// - `AppNavigatorObserver` for navigation tracking.
/// - `AppRouter` for generating routes dynamically.
///
/// This widget listens to `AppViewModel` to manage navigation and theme settings.
class AppView extends StatelessWidget {
  /// Creates an instance of [AppView].
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppViewModel>.reactive(

      /// Provides an instance of [AppViewModel].
      viewModelBuilder: () => AppViewModel(),

      /// Initializes the view model when the widget is created.
      onViewModelReady: (AppViewModel model) => model.init(),

      /// Indicates whether the view model should be disposed of when the widget
      /// is removed from the widget tree.
      disposeViewModel: false,

      builder: (BuildContext context, AppViewModel model, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Triq Processor',

          /// Global key for scaffold-related actions such as showing snack bars.
          scaffoldMessengerKey: rootScaffoldMessengerKey,

          /// Sets up the theme for light and dark modes.
          theme: AppThemes.lightTheme,
          // darkTheme: AppThemes.darkTheme,

          /// The global navigator key used by `StackedService`.
          navigatorKey: StackedService.navigatorKey,

          /// Generates routes dynamically.
          onGenerateRoute: AppRouter().onGenerateRoute,

          /// Adds a navigation observer to track manager navigation events.
          navigatorObservers: [AppNavigatorObserver()],

          /// Supported locales for localization.
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          /// The default locale for localization.
          locale: const Locale('en'),

          /// Determines the initial screen based on the manager's state.
          initialRoute: model.getInitialRoute(),
        );

      },
    );
  }
}
