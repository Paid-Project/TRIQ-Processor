part of 'app_resources.dart';

/// A centralized class for defining application-wide gradient constants.
///
/// This ensures consistency across the manager and makes it easy to update gradients in one place.
class AppGradients {
  static const primaryGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [AppColors.primary, AppColors.primaryLight],
    stops: [0.0, 0.95],
  );
}
