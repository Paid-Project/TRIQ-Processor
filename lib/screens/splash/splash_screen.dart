import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/notification.service.dart';
import 'package:manager/services/secure_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureApiService _secureApiService = locator<SecureApiService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runStartupFlow();
    });
  }

  Future<void> _runStartupFlow() async {
    bool shouldAllowAppEntry = true;

    try {
      shouldAllowAppEntry = await _secureApiService.isManufacturerEnabled();
    } catch (error) {
      AppLogger.warning(
        'Splash availability check failed. Allowing app entry. Error: $error',
      );
    }

    if (!mounted) return;

    final String nextRoute =
        shouldAllowAppEntry ? Routes.root : Routes.updateRequired;

    Navigator.of(context).pushNamedAndRemoveUntil(
      nextRoute,
      (Route<dynamic> route) => false,
    );

    if (shouldAllowAppEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirebaseNotificationService.handlePendingNavigation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(AppImages.triqLogo, height: 112),
                const SizedBox(height: 28),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  'Checking app availability...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
