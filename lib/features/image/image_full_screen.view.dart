import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stacked/stacked.dart';
import 'package:photo_view/photo_view.dart';

import 'image_full_screen.vm.dart';

class ImageViewerView extends StatelessWidget {
  final String imageUrl;

  const ImageViewerView({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImageViewerViewModel>.reactive(
      viewModelBuilder: () => ImageViewerViewModel(),
      onViewModelReady: (model) => model.init(imageUrl),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Image with zoom capability
                _buildImageView(context, model),

                // Loading indicator
                if (model.isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                // Error message
                if (model.hasError)
                  Center(
                    child: _buildErrorWidget(context, model),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageView(BuildContext context, ImageViewerViewModel model) {
    return Center(
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          imageUrl,
          errorListener: model.onImageError,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        initialScale: PhotoViewComputedScale.contained,
        basePosition: Alignment.center,
        onTapUp: (context, details, controllerValue) {
          // Single tap to toggle AppBar visibility
          // You can implement this functionality if needed
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, ImageViewerViewModel model) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white70,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Unable to load image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            model.errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => model.init(imageUrl), // Retry loading
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}