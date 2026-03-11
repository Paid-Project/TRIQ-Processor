import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  ResultFuture<File> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // Request permission
      final statusPhotos = await Permission.photos.request();
      final statusStorage = await Permission.storage.request();
      if (!statusStorage.isGranted && !statusPhotos.isGranted) {
        Fluttertoast.showToast(msg: 'Gallery permission denied');
        return Left(Failure('Gallery permission denied'));
      }

      // Pick image
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return Left(Failure('No image selected'));
      }

      return Right(File(pickedFile.path));
    } catch (e) {
      AppLogger.error('Error picking image from gallery: $e');
      return Left(Failure('Failed to pick image: $e'));
    }
  }

  /// Take a photo using the camera
  /// Returns the captured image file on success
  ResultFuture<File> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // Request permission
      final permissionStatus = await Permission.camera.request();
      if (permissionStatus.isDenied) {
        return Left(Failure('Camera permission denied'));
      }
      if (permissionStatus.isPermanentlyDenied) {
        return Left(
          Failure(
            'Camera permission permanently denied. Please enable it from app settings.',
          ),
        );
      }

      // Take photo
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return Left(Failure('No photo taken'));
      }

      return Right(File(pickedFile.path));
    } catch (e) {
      AppLogger.error('Error taking photo: $e');
      return Left(Failure('Failed to take photo: $e'));
    }
  }

  /// Pick multiple images from the gallery
  /// Returns a list of selected image files on success
  ResultFuture<List<File>> pickMultipleImages() async {
    try {
      // Request permission
      final statusPhotos = await Permission.photos.request();
      final statusStorage = await Permission.storage.request();
      if (!statusStorage.isGranted && !statusPhotos.isGranted) {
        Fluttertoast.showToast(msg: 'Gallery permission denied');
        return Left(Failure('Gallery permission denied'));
      }

      // Pick multiple images
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No images selected'));
      }

      // Convert PlatformFile to File
      final files =
          result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();

      return Right(files);
    } catch (e) {
      AppLogger.error('Error picking multiple images: $e');
      return Left(Failure('Failed to pick images: $e'));
    }
  }

  /// Pick a document file (PDF, DOC, etc.)
  /// Returns the selected document file on success
  ResultFuture<File> pickDocument({List<String>? allowedExtensions}) async {
    try {
      // Request permission
      final permissionStatus = await Permission.storage.request();
      if (permissionStatus.isDenied) {
        return Left(Failure('Storage permission denied'));
      }
      if (permissionStatus.isPermanentlyDenied) {
        return Left(
          Failure(
            'Storage permission permanently denied. Please enable it from app settings.',
          ),
        );
      }

      // Pick document
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No document selected'));
      }

      if (result.files.first.path == null) {
        return Left(Failure('Invalid document path'));
      }

      return Right(File(result.files.first.path!));
    } catch (e) {
      AppLogger.error('Error picking document: $e');
      return Left(Failure('Failed to pick document: $e'));
    }
  }

  /// Pick an audio file using the system file picker.
  /// No storage permission request is needed for SAF-based pickers.
  ResultFuture<File> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No audio selected'));
      }

      if (result.files.first.path == null) {
        return Left(Failure('Invalid audio path'));
      }

      return Right(File(result.files.first.path!));
    } catch (e) {
      AppLogger.error('Error picking audio file: $e');
      return Left(Failure('Failed to pick audio file: $e'));
    }
  }
  /// Pick any file type
  /// Returns the selected file on success
  ResultFuture<File> pickAnyFile() async {
    try {
      // Request permission
      final permissionStatus = await Permission.storage.request();
      if (permissionStatus.isDenied) {
        return Left(Failure('Storage permission denied'));
      }
      if (permissionStatus.isPermanentlyDenied) {
        return Left(
          Failure(
            'Storage permission permanently denied. Please enable it from app settings.',
          ),
        );
      }

      // Pick file
      final result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No file selected'));
      }

      if (result.files.first.path == null) {
        return Left(Failure('Invalid file path'));
      }

      return Right(File(result.files.first.path!));
    } catch (e) {
      AppLogger.error('Error picking file: $e');
      return Left(Failure('Failed to pick file: $e'));
    }
  }

  ResultFuture<File> pickVideoFromGallery({Duration? maxDuration}) async {
    try {
      // Request permission
      final statusPhotos = await Permission.photos.request();
      final statusStorage = await Permission.storage.request();
      if (!statusStorage.isGranted && !statusPhotos.isGranted) {
        Fluttertoast.showToast(msg: 'Gallery permission denied');
        return Left(Failure('Gallery permission denied'));
      }

      // Pick video
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (pickedFile == null) {
        return Left(Failure('No video selected'));
      }

      return Right(File(pickedFile.path));
    } catch (e) {
      AppLogger.error('Error picking video from gallery: $e');
      return Left(Failure('Failed to pick video: $e'));
    }
  }

  ResultFuture<File> recordVideo({Duration? maxDuration}) async {
    try {
      // Request permission
      final permissionStatus = await Permission.camera.request();
      if (permissionStatus.isDenied) {
        return Left(Failure('Camera permission denied'));
      }
      if (permissionStatus.isPermanentlyDenied) {
        return Left(
          Failure(
            'Camera permission permanently denied. Please enable it from app settings.',
          ),
        );
      }

      // Record video
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
      );

      if (pickedFile == null) {
        return Left(Failure('No video recorded'));
      }

      return Right(File(pickedFile.path));
    } catch (e) {
      AppLogger.error('Error recording video: $e');
      return Left(Failure('Failed to record video: $e'));
    }
  }

  ResultFuture<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    try {
      // Request permission
      final permissionStatus = await Permission.storage.request();
      if (permissionStatus.isDenied) {
        return Left(Failure('Storage permission denied'));
      }
      if (permissionStatus.isPermanentlyDenied) {
        return Left(
          Failure(
            'Storage permission permanently denied. Please enable it from app settings.',
          ),
        );
      }

      // Pick multiple files
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No files selected'));
      }

      // Convert PlatformFile to File
      final files =
          result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();

      return Right(files);
    } catch (e) {
      AppLogger.error('Error picking multiple files: $e');
      return Left(Failure('Failed to pick files: $e'));
    }
  }

  /// Pick media (image or video) from gallery
  /// Returns the selected media file on success
  ResultFuture<File> pickMediaFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    Duration? maxDuration,
  }) async {
    try {
      // Request permission
      final statusPhotos = await Permission.photos.request();
      final statusStorage = await Permission.storage.request();
      if (!statusStorage.isGranted && !statusPhotos.isGranted) {
        Fluttertoast.showToast(msg: 'Gallery permission denied');
        return Left(Failure('Gallery permission denied'));
      }

      // Pick media files (both image and video)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('No media selected'));
      }

      if (result.files.first.path == null) {
        return Left(Failure('Invalid media path'));
      }

      return Right(File(result.files.first.path!));
    } catch (e) {
      AppLogger.error('Error picking media from gallery: $e');
      return Left(Failure('Failed to pick media: $e'));
    }
  }
}



