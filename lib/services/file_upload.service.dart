import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';
import 'package:path/path.dart' as path;

class FileUploadService {
  final apiService = locator<ApiService>();

  /// Upload multiple files to the server
  /// Returns a list of URLs for the uploaded files on success
  ResultFuture<List<String>> uploadFiles(List<File> files) async {
    try {
      // Create form data with multiple files
      final formData = FormData();

      // Add each file to the form data
      for (var i = 0; i < files.length; i++) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              files[i].path,
              filename: path.basename(files[i].path),
            ),
          ),
        );
      }

      // Make the request
      final response = await apiService.post(
        url: ApiEndpoints.uploadImages,
        data: formData,
      );

      // Check response
      if (response.data['success'] == true) {
        final List<String> urls = List<String>.from(response.data['data']);
        return Right(urls);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to upload files'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(
          'Files upload error: ${e.response?.data?['message'] ?? e.message}',
        );
        return Left(
          Failure(
            e.response?.data?['message'] ?? 'Network error during files upload',
          ),
        );
      }
      AppLogger.error('Files upload error: $e');
      return Left(Failure('Failed to upload files: $e'));
    }
  }

  /// Upload file with progress tracking
  /// The progress callback provides upload progress from 0.0 to 1.0
  ResultFuture<String> uploadFileWithProgress(
    File file,
    void Function(double progress) onProgress,
  ) async {
    try {
      // Create form data
      // Create form data with multiple files
      final formData = FormData();

      // Add each file to the form data
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: path.basename(file.path),
          ),
        ),
      );

      // Options with onSendProgress callback
      final options = Options(contentType: 'multipart/form-data');

      // Make the request with progress tracking
      final response = await apiService.post(
        url: ApiEndpoints.uploadImages,
        data: formData,
        options: options,
        cancelToken: CancelToken(),
        queryParameters: {
          'onSendProgress': (int sent, int total) {
            if (total != 0) {
              final progress = sent / total;
              onProgress(progress);
            }
          },
        },
      );

      // Check response
      if (response.data['success'] == true) {
        return Right(response.data['data'][0]);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to upload file'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(
          'File upload error: ${e.response?.data?['message'] ?? e.message}',
        );
        return Left(
          Failure(
            e.response?.data?['message'] ?? 'Network error during file upload',
          ),
        );
      }
      AppLogger.error('File upload error: $e');
      return Left(Failure('Failed to upload file: $e'));
    }
  }

  /// Delete a file from the server by URL
  ResultFuture<bool> deleteFile(String fileUrl) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.uploadImages,
        data: {'url': fileUrl},
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to delete file'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(
          'File deletion error: ${e.response?.data?['message'] ?? e.message}',
        );
        return Left(
          Failure(
            e.response?.data?['message'] ??
                'Network error during file deletion',
          ),
        );
      }
      AppLogger.error('File deletion error: $e');
      return Left(Failure('Failed to delete file: $e'));
    }
  }
}
