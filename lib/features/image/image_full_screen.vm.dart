import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ImageViewerViewModel extends BaseViewModel {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Controller for zoom/pan functionality
  final TransformationController transformationController = TransformationController();

  // Initialize with the image URL
  void init(String imageUrl) {
    // Reset state
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Called when image is loaded successfully
  void onImageLoaded() {
    _isLoading = false;
    notifyListeners();
  }

  // Called when there's an error loading the image
  void onImageError(Object error) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = 'Failed to load image: ${error.toString()}';
    notifyListeners();
  }

  // Reset the zoom level
  void resetZoom() {
    transformationController.value = Matrix4.identity();
    notifyListeners();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}