import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../resources/app_resources/app_resources.dart';
import '../dialogs/image_preview/image_preview_dialog.dart';

class CommonCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final Color? placeholderColor;
  final Color? errorColor;
  final double? placeholderIconSize;
  final double? errorIconSize;
  final EdgeInsets? padding;
  final Decoration? decoration;

  const CommonCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.errorColor,
    this.placeholderIconSize,
    this.errorIconSize,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder != null ? placeholder!(context, url) : _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget != null ? errorWidget!(context, url, error) : _buildDefaultErrorWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    if (decoration != null) {
      imageWidget = Container(decoration: decoration, child: imageWidget);
    }

    if (padding != null) {
      imageWidget = Padding(padding: padding!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? AppColors.lightGrey.withValues(alpha: 0.3),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            placeholderColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: errorColor ?? AppColors.lightGrey.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: AppColors.textGrey,
          size: errorIconSize ?? 40,
        ),
      ),
    );
  }
}

/// A specialized cached image widget for chat message attachments
class ChatCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final List<String>? allImageUrls;
  final int? imageIndex;
  final String? messageContent;

  const ChatCachedImage({
    super.key,
    required this.imageUrl,
    this.width = 200,
    this.height = 200,
    this.borderRadius,
    this.onTap,
    this.allImageUrls,
    this.imageIndex,
    this.messageContent,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CommonCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.v8),
      placeholderColor: AppColors.lightGrey.withValues(alpha: 0.3),
      errorColor: AppColors.lightGrey.withValues(alpha: 0.3),
      errorIconSize: 40,
    );

    // If onTap is provided, use it; otherwise, use default image preview
    VoidCallback? tapHandler = onTap;
    if (tapHandler == null && allImageUrls != null && imageIndex != null) {
      tapHandler = () => _showImagePreview(context);
    }

    if (tapHandler != null) {
      imageWidget = GestureDetector(onTap: tapHandler, child: imageWidget);
    }

    return imageWidget;
  }

  void _showImagePreview(BuildContext context) {
    if (allImageUrls == null || imageIndex == null) return;

    showImagePreviewDialog(
      context: context,
      imageUrls: allImageUrls!,
      initialIndex: imageIndex!,
      messageContent: messageContent,
    );
  }
}

/// A specialized cached image widget for profile images
class ProfileCachedImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const ProfileCachedImage({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      placeholderColor: Colors.transparent, // Remove background color
      errorColor: Colors.transparent, // Remove background color on error
      errorIconSize: size * 0.4,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        color: Colors.transparent, // No background color
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        color: Colors.transparent, // No background color
        child: Center(
          child: Icon(
            Icons.person,
            color: AppColors.textGrey,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
