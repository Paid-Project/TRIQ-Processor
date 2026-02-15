import 'package:flutter/material.dart';
import 'package:manager/services/language.service.dart';

enum TaskStatus {
  todo,
  inProgress,
  done,
}

extension TaskStatusExtension on TaskStatus {
  String getDisplayName() {
    switch (this) {
      case TaskStatus.todo:
        return LanguageService.get('statusTodo');
      case TaskStatus.inProgress:
        return LanguageService.get('statusInProgress');
      case TaskStatus.done:
        return LanguageService.get('statusDone');
    }
  }
}