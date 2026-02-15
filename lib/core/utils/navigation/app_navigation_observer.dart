import 'package:flutter/material.dart';

import '../app_logger.dart';

/// A custom `NavigatorObserver` to track navigation events throughout the manager.
///
/// This observer logs navigation changes and maintains a navigation stack
/// to track the current and previously visited routes.
class AppNavigatorObserver extends NavigatorObserver {
  /// A stack to keep track of the navigation history.
  static final List<String> _navigationStack = [];

  /// Called when a new route is pushed onto the navigator.
  ///
  /// Logs the newly pushed route and updates the navigation stack.
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _navigationStack.add(route.settings.name ?? 'Unknown');
    AppLogger.info(
      'Pushed Route: ${route.settings.name}'
      '\nPrevious Route: ${previousRoute?.settings.name ?? "NA"}',
    );
  }

  /// Called when a route is popped from the navigator.
  ///
  /// Logs the popped route and updates the navigation stack accordingly.
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _navigationStack.remove(route.settings.name ?? 'Unknown');
    AppLogger.info(
      'Popped Route: ${route.settings.name}'
      '\nCurrent Route: ${previousRoute?.settings.name ?? "NA"}',
    );
  }

  /// Called when a route is replaced with a new one.
  ///
  /// Logs the route replacement and updates the navigation stack.
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _navigationStack.remove(oldRoute.settings.name ?? 'Unknown');
    }
    if (newRoute != null) {
      _navigationStack.add(newRoute.settings.name ?? 'Unknown');
    }
    AppLogger.info(
      'Replaced Route: ${oldRoute?.settings.name}\n with ${newRoute?.settings.name}',
    );
  }

  /// Called when a route is removed from the navigator stack.
  ///
  /// Logs the removed route and updates the navigation stack.
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _navigationStack.remove(route.settings.name ?? 'Unknown');
    AppLogger.info(
      'Removed Route: ${route.settings.name}'
      '\nPrevious Route: ${previousRoute?.settings.name ?? "NA"}',
    );
  }

  /// Called when the user starts a back gesture (e.g., swipe back on iOS/Android).
  ///
  /// Logs the gesture start event.
  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    AppLogger.info('User started a gesture on route: ${route.settings.name}');
  }

  /// Called when the user completes or cancels a back gesture.
  ///
  /// Logs the gesture stop event.
  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    AppLogger.info('User stopped a gesture');
  }

  /// Returns the current active route name, or `null` if there are no active routes.
  static String? get currentRoute =>
      _navigationStack.isNotEmpty ? _navigationStack.last : null;

  /// Checks if a specific route is currently active in the navigation stack.
  ///
  /// Returns `true` if the given [routeName] exists in the stack; otherwise, `false`.
  static bool isRouteActive(String routeName) {
    return _navigationStack.contains(routeName);
  }
}
