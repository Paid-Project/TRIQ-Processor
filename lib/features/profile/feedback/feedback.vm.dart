import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class FeedbackViewModel extends ReactiveViewModel {
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();

  final TextEditingController descriptionController = TextEditingController();
  final ReactiveValue<bool> _includeSystemLogs = ReactiveValue<bool>(false);

  bool get includeSystemLogs => _includeSystemLogs.value;

  void toggleSystemLogs(bool value) {
    _includeSystemLogs.value = value;
    notifyListeners();
  }

  String get currentUserEmail {
    final user = getUser();
    return user.email ?? '';
  }

  Future<void> sendFeedback() async {
    if (descriptionController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your feedback', backgroundColor: Colors.red);
      return;
    }

    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () async {
          try {
            final apiResponse = await _apiService.post(
              url: ApiEndpoints.sendFeedback,
              data: {'mail': currentUserEmail, 'feedback': descriptionController.text.trim()},
            );

            if (apiResponse.statusCode == 200) {
              AppLogger.info('Feedback sent successfully');
              Fluttertoast.showToast(msg: apiResponse.data['msg'] ?? "Feedback sent successfully", backgroundColor: Colors.green);
              Get.back();
              // Clear the form after successful submission
              descriptionController.clear();
              _includeSystemLogs.value = false;
              notifyListeners();

              return true;
            } else {
              AppLogger.error('Failed to send feedback: ${apiResponse.statusMessage}');
              Fluttertoast.showToast(msg: 'Failed to send feedback: ${apiResponse.statusMessage}', backgroundColor: Colors.red);
              return false;
            }
          } catch (e) {
            AppLogger.error('Error sending feedback: $e');
            Fluttertoast.showToast(msg: 'Error sending feedback: $e', backgroundColor: Colors.red);
            return false;
          }
        },
      ),
    );

    if (response?.confirmed == true) {
      // Feedback sent successfully
      AppLogger.info('Feedback submission completed');
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
