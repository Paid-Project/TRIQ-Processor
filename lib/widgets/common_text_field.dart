import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String placeholder;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final bool enabled;
  final String? helperText;
  final String? errorText;
  final Color? disabledBackgroundColor;
  final EdgeInsets? contentPadding;
  final TextStyle? textStyle;
  final void Function(PointerDownEvent)? onTapOutside;

  const CommonTextField({
    super.key,
    required this.controller,
    this.label,
    required this.placeholder,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.disabledBackgroundColor,
    this.contentPadding,
    this.suffix,
    this.textStyle,
    this.onTapOutside,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (only show if provided)
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,

    onTap:onTap,
          onTapOutside:
          onTapOutside ??
                  (event) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          validator: validator,
          style: textStyle,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            suffix: suffix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            helperText: helperText,
            errorText: errorText,
            filled: true,
            fillColor:
            enabled
                ? AppColors.white
                : (disabledBackgroundColor ?? AppColors.colorF8FBFE),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? AppColors.lightGrey : AppColors.primary,
                width: readOnly ? 1 : 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.lightGrey.withValues(alpha: 0.5),
              ),
            ),
            contentPadding:
            contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// Common validation functions
class CommonValidators {
  static String? Function(String?)? required(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? email(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? phone(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      if (value.length < 10) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? minLength(
      int minLength,
      String errorMessage,
      ) {
    return (value) {
      if (value == null || value.length < minLength) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? maxLength(
      int maxLength,
      String errorMessage,
      ) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? pattern(
      RegExp pattern,
      String errorMessage,
      ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Allow empty values, use required validator if needed
      }
      if (!pattern.hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}
