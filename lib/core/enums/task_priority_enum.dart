import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

enum TaskPriority {
  high,
  medium,
  low,
}

extension TaskPriorityExtension on TaskPriority {
  String getDisplayName() {
    switch (this) {
      case TaskPriority.high:
        return LanguageService.get('priorityHigh');
      case TaskPriority.medium:
        return LanguageService.get('priorityMedium');
      case TaskPriority.low:
        return LanguageService.get('priorityLow');
    }
  }

  Color getDisplayColor() {
    // Aapki di hui AppColors file ke hisaab se
    switch (this) {
      case TaskPriority.high:
        return AppColors.red; // SAHI
      case TaskPriority.medium:
        return AppColors.yellow; // SAHI
      case TaskPriority.low:
        return AppColors.softGreen; // SAHI
    }
  }
}