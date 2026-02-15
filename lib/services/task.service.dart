import 'dart:io';

import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
// Iska istemaal karenge
import 'package:manager/core/models/task.dart'; // Naya model
import 'package:manager/services/api.service.dart';

class TaskService {
  final _api = locator<ApiService>();

  Future<TaskApiResponse?> getTasks({
    required int page,
    int limit = 10,
    required String tab, // "mytask" ya "assignedtask"
    required String status, // "all", "low", "medium", "high"
    String? search, // Search query
  }) async {
    // API ke parameters
    final params = {
      'page': page.toString(),
      'limit': limit.toString(),
      'tab': tab,
      'status': status,
    };

    // Agar search query hai to add karo
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    try {
      final response = await _api.get(
        url: ApiEndpoints.getAllTasks,
        queryParameters: params,
      );

      if (response != null && response.data['success'] == true) {
        // Response ko naye model me parse karna
        return TaskApiResponse.fromJson(response.data);
      } else {
        // Error handle karein
        return null;
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      return null;
    }
  }

  Future<bool> createTask({
    required Map<String, String> fields,
    required List<File> files,
  }) async {
    try {
      // (Main assume kar raha hoon ki aapki ApiService me 'postMultipart' method hai)
      final response = await _api.postMultipart(
        ApiEndpoints.createTask,
        files: files,
        data: fields,
        fileField: 'media',
      );

      // (Aapke code me 'ApiResponse' hai, uske hisaab se error handling)
      if (response != null && response.data['success'] == true) {
        return true;
      } else {
        // Error response
        return false;
      }
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }
}
