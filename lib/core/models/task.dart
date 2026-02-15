
import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final List<String> media;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String priority;
  final AssignTo assignTo;
  final String user;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.media,
    this.startDateTime,
    this.endDateTime,
    required this.priority,
    required this.assignTo,
    required this.user,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      media: List<String>.from(json['media'].map((x) => x)),
      startDateTime: json['startDateTime'] != null
          ? DateTime.tryParse(json['startDateTime'])
          : null,
      endDateTime: json['endDateTime'] != null
          ? DateTime.tryParse(json['endDateTime'])
          : null,
      priority: json['priority'],
      assignTo: AssignTo.fromJson(json['assignTo']??{}),
      user: json['user'],
    );
  }

  // UI me time dikhane ke liye helper function
  String getRemainingTime() {
    if (endDateTime == null) {
      return 'N/A';
    }
    // Format: Jun 17,2025 14:23 (jaisa aapke UI code me tha)
    return DateFormat('MMM dd, yyyy HH:mm').format(endDateTime!);
  }
}

// Poore API response ko handle karne ke liye wrapper class
class TaskApiResponse {
  final bool success;
  final int currentPage;
  final int totalPages;
  final int totalTasks;
  final List<Task> tasks;

  TaskApiResponse({
    required this.success,
    required this.currentPage,
    required this.totalPages,
    required this.totalTasks,
    required this.tasks,
  });

  factory TaskApiResponse.fromJson(Map<String, dynamic> json) {
    return TaskApiResponse(
      success: json['success'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalTasks: json['totalTasks'],
      tasks: List<Task>.from(json['tasks'].map((x) => Task.fromJson(x))),
    );
  }
}
class AssignTo {
  final String id;
  final String name;


  AssignTo({
    required this.id,
    required this.name,
  });

  factory AssignTo.fromJson(Map<String, dynamic> json) {
    return AssignTo(
      id: json['_id'],
      name: json['name'],
    );
  }
}