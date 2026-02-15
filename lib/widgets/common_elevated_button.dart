import 'package:flutter/material.dart';

class CommonElevatedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? iconSize;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final bool isExpand;
  final Widget? loadingWidget;

  const CommonElevatedButton({
    super.key,
    required this.label,
    this.icon,
    this.imagePath,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.iconSize,
    this.isExpand = false,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            side:
                borderColor != null
                    ? BorderSide(color: borderColor!)
                    : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child:
            isLoading
                ? (loadingWidget ??
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ))
                : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null || imagePath != null) ...[
                      imagePath != null
                          ? Image.asset(
                            imagePath!,
                            width: iconSize ?? 18,
                            height: iconSize ?? 18,
                            color: textColor ?? Colors.white,
                            fit: BoxFit.contain,
                          )
                          : Icon(
                            icon!,
                            size: iconSize ?? 18,
                            color: textColor ?? Colors.white,
                          ),
                      const SizedBox(width: 8),
                    ],
                    isExpand ? Expanded(child:
                 Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize ?? 14,
                          fontWeight: fontWeight ?? FontWeight.w600,
                          color: textColor ?? Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),): Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize ?? 14,
                        fontWeight: fontWeight ?? FontWeight.w600,
                        color: textColor ?? Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )

                  ],
                ),
      ),
    );
  }
}

// Convenience constructors for common button styles
class CommonElevatedButtonStyles {
  // Primary button (filled)
  static Widget primary({
    required String label,
    IconData? icon,
    String? imagePath,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    double? fontSize,
    FontWeight? fontWeight,
    bool isLoading = false,
    Widget? loadingWidget,
  }) {
    return CommonElevatedButton(
      label: label,
      icon: icon,
      imagePath: imagePath,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      iconSize: iconSize,
      fontSize: fontSize,
      fontWeight: fontWeight,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
    );
  }

  // Secondary button (outlined)
  static Widget secondary({
    required String label,
    IconData? icon,
    String? imagePath,
    VoidCallback? onPressed,
    Color? textColor,
    Color? borderColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    double? fontSize,
    FontWeight? fontWeight,
    bool isLoading = false,
    Widget? loadingWidget,
  }) {
    return CommonElevatedButton(
      label: label,
      icon: icon,
      imagePath: imagePath,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: textColor,
      borderColor: borderColor,
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      iconSize: iconSize,
      fontSize: fontSize,
      fontWeight: fontWeight,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
    );
  }

  // Icon only button
  static Widget iconOnly({
    required IconData icon,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? iconSize,
    bool isLoading = false,
    Widget? loadingWidget,
  }) {
    return CommonElevatedButton(
      label: '',
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: iconColor,
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      iconSize: iconSize,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
    );
  }
}
