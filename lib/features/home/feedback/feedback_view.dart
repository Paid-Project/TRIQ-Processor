import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: _buildAppBar(context)
    );
  }
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    // CustomersListViewModel model,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        'Feedback & Ratings',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}