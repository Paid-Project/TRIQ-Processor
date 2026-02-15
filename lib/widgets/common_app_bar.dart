import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? titleKey;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? elevation;
  final double? titleSpacing;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    this.title,
    this.titleKey,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.gradient,
    this.elevation = 0,
    this.titleSpacing = 0,
    this.titleStyle,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      titleSpacing: titleSpacing,
      centerTitle: centerTitle,
      leading: _buildLeading(),
      actions: actions,
      flexibleSpace: _buildFlexibleSpace(),
      title: _buildTitle(),
      bottom: bottom,
    );
  }

  Widget? _buildLeading() {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: onBackPressed ?? () => Get.back(),
      );
    }

    return null;
  }

  Widget? _buildTitle() {
    // If titleWidget is provided, use it directly
    if (titleWidget != null) return titleWidget;

    // If no title or titleKey, return null
    if (title == null && titleKey == null) return null;

    final displayTitle =
        title ?? (titleKey != null ? LanguageService.get(titleKey!) : '');

    return Text(
      displayTitle,
      style:
          titleStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget? _buildFlexibleSpace() {
    if (gradient != null) {
      return Container(decoration: BoxDecoration(gradient: gradient));
    }

    return null;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

// Predefined gradient manager bar for common use cases
class GradientAppBar extends CommonAppBar {
  const GradientAppBar({
    super.key,
    super.title,
    super.titleKey,
    super.titleWidget,
    super.leading,
    super.actions,
    super.showBackButton,
    super.onBackPressed,
    super.titleSpacing,
    super.titleStyle,
    super.centerTitle,
    super.bottom,
    Gradient? gradient,
  }) : super(
         gradient:
             gradient ??
             const LinearGradient(
               colors: [AppColors.primaryLight, AppColors.primaryDark],
               begin: Alignment.centerRight,
               end: Alignment.centerLeft,
               stops: [0.08, 1],
             ),
       );
}

// Simple manager bar without gradient
class SimpleAppBar extends CommonAppBar {
  const SimpleAppBar({
    super.key,
    super.title,
    super.titleKey,
    super.titleWidget,
    super.leading,
    super.actions,
    super.showBackButton,
    super.onBackPressed,
    super.backgroundColor,
    super.elevation,
    super.titleSpacing,
    super.titleStyle,
    super.centerTitle,
    super.bottom,
  });
}
