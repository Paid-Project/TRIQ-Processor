import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/file_picker.service.dart';
import '../../../services/language.service.dart';
import '../../../widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';

class CreateTicketDialogViewModel extends ReactiveViewModel {
  final _filePickerService = locator<FilePickerService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController problemController = TextEditingController();
  final TextEditingController errorCodeController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();

  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  bool get isLoading => _isLoading.value;

  final ReactiveValue<List<File>> _attachments = ReactiveValue<List<File>>([]);
  List<File> get attachments => _attachments.value;

  final ReactiveValue<String?> _attachmentsError = ReactiveValue<String?>(null);
  String? get attachmentsError => _attachmentsError.value;

  CreateTicketDialogAttributes? _attributes;

  String? selectedOrganizationId;
  String? selectedMachineId;

  void init(CreateTicketDialogAttributes attributes) {
    _attributes = attributes;

    // Initialize with provided values
    problemController.text = attributes.initialProblem ?? '';
    errorCodeController.text = attributes.initialErrorCode ?? '';
    additionalNotesController.text = attributes.initialAdditionalNotes ?? '';
    _attachments.value = List.from(attributes.initialAttachments ?? []);

    notifyListeners();
  }

  Future<void> pickMedia() async {
    try {
      // Show options for image or video
      final result = await _filePickerService.pickMediaFromGallery(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
        type: FileType.image,
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to pick media: ${failure.message}');
          // You could show a toast here if needed
        },
        (file) {
          _attachments.value.add(file);
          _attachmentsError.value = null; // Clear error when file is added
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error('Error picking media: $e');
    }
  }

  Future<void> pickMediaFromCamera() async {
    try {
      final result = await _filePickerService.takePhoto(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to pick media: ${failure.message}');
          // Optional: toast/snackbar
        },
            (file) {
          _attachments.value.add(file);
          _attachmentsError.value = null;
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error('Error picking media from camera: $e');
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.value.length) {
      _attachments.value.removeAt(index);
      // Clear error if there are still attachments, or set error if no attachments left
      if (_attachments.value.isNotEmpty) {
        _attachmentsError.value = null;
      }
      notifyListeners();
    }
  }

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      // Validate attachments
      if (_attachments.value.isEmpty) {
        _attachmentsError.value =
            '${LanguageService.get('upload_media')} ${LanguageService.get('required')}';
        notifyListeners();
        return;
      }

      _isLoading.value = true;
      notifyListeners();

      try {
        await _attributes?.onSubmit?.call(
          problemController.text.trim(),
          errorCodeController.text.trim(),
          additionalNotesController.text.trim(),
          _attachments.value,
          selectedMachineId ?? "",
          selectedOrganizationId ?? "",
        );

        // Close dialog after successful submission
        if (context.mounted) {
          Navigator.of(context).pop(DialogResponse(confirmed: true));
        }
      } catch (e) {
        AppLogger.error('Error in onSubmit: $e');
      } finally {
        _isLoading.value = false;
        notifyListeners();
      }
    }
  }

  bool validateForm() {
    bool isFormValid = formKey.currentState?.validate() ?? false;

    // Validate attachments
    if (_attachments.value.isEmpty) {
      _attachmentsError.value =
          '${LanguageService.get('upload_media')} ${LanguageService.get('required')}';
      notifyListeners();
      return false;
    } else {
      _attachmentsError.value = null;
      notifyListeners();
    }

    return isFormValid;
  }

  void onCancel() {
    _attributes?.onCancel?.call();
  }

  void stopLoading() {
    _isLoading.value = false;
    notifyListeners();
  }

  void closeDialog() {
    // This will be called after successful submission
    // The dialog will be closed by the parent view
  }

  @override
  void dispose() {
    problemController.dispose();
    errorCodeController.dispose();
    additionalNotesController.dispose();
    super.dispose();
  }
}
