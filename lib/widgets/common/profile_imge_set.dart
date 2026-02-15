import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CheckNetworkProfileImage extends StatelessWidget {
  final String? imagePath; // API path OR full URL OR local file path
  final String baseUrl;    // https://api.triqinnovations.com
  final double size;
  final double borderWidth;
  final Color borderColor;

  const CheckNetworkProfileImage({
    super.key,
    required this.imagePath,
    required this.baseUrl,
    this.size = 60,
    this.borderWidth = 2,
    this.borderColor = Colors.blue,
  });

  bool get _isNetworkImage =>
      imagePath != null &&
          imagePath!.isNotEmpty &&
          (imagePath!.startsWith('http://') ||
              imagePath!.startsWith('https://'));

  bool get _isApiPath =>
      imagePath != null &&
          imagePath!.isNotEmpty &&
          !imagePath!.startsWith('http') &&
          !File(imagePath!).existsSync();

  bool get _isLocalFile =>
      imagePath != null &&
          imagePath!.isNotEmpty &&
          File(imagePath!).existsSync();

  String get _fullNetworkUrl {
    if (_isNetworkImage) return imagePath!;
    if (_isApiPath) {
      return imagePath!.startsWith('/')
          ? '$baseUrl$imagePath'
          : '$baseUrl/$imagePath';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // 1️⃣ Local file image (camera / gallery)
    if (_isLocalFile) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }

    // 2️⃣ Network image (API path OR full URL)
    if (_fullNetworkUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _fullNetworkUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _loading(),
        errorWidget: (_, __, ___) => _defaultAvatar(),
      );
    }

    // 3️⃣ Default avatar
    return _defaultAvatar();
  }

  Widget _loading() {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}
