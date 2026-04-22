import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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
      final result = await _filePickerService.pickImageFromGallery(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to pick image: ${failure.message}');
        },
            (file) {
          _attachments.value.add(file);
          _attachmentsError.value = null;
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error('Error picking image: $e');
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
  Future<File> _compressImage(File file) async {
    try {
      // Pehle check karo - agar already small hai toh skip
      final fileSize = await file.length();
      if (fileSize < 300 * 1024) return file; // 300KB se kam? skip

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 50,      // quality aur kam karo
        minWidth: 800,    // ⚠️ ye MIN hai - isliye MAX use karo differently
        minHeight: 800,
      );

      if (result == null) return file;

      final compressed = File(result.path);
      final newSize = await compressed.length();

      AppLogger.info(
          'Compressed: ${(fileSize / 1024).toStringAsFixed(1)}KB → '
              '${(newSize / 1024).toStringAsFixed(1)}KB'
      );

      // Agar phir bhi 500KB se bada hai - ek aur pass
      if (newSize > 500 * 1024) {
        final targetPath2 =
            '${tempDir.path}/compressed2_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final result2 = await FlutterImageCompress.compressAndGetFile(
          compressed.path,
          targetPath2,
          quality: 30,
          minWidth: 600,
          minHeight: 600,
        );
        return result2 != null ? File(result2.path) : compressed;
      }

      return compressed;
    } catch (e) {
      AppLogger.error('Error compressing image: $e');
      return file;
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
        // Compress all images before submitting
        final compressedFiles = await Future.wait(
          _attachments.value.map((file) => _compressImage(file)),
        );
        // Close dialog first so submit action continues on next screen cleanly.
        if (context.mounted) {
          Navigator.of(context).pop(DialogResponse(confirmed: true));
        }

        await _attributes?.onSubmit?.call(
          problemController.text.trim(),
          errorCodeController.text.trim(),
          additionalNotesController.text.trim(),
          compressedFiles, // compressed list bhejo
          // _attachments.value,
          selectedMachineId ?? "",
          selectedOrganizationId ?? "",
        );
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

