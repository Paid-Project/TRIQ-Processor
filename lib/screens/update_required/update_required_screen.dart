import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final resolvedMessage =
        message?.trim().isNotEmpty == true
            ? message!.trim()
            : 'Please update the app or try again later.';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.warningLightRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 64,
                      color: AppColors.warningRed,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    resolvedMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
