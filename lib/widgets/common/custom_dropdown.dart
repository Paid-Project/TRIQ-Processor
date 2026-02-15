import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CustomDropdownFormField<T> extends StatelessWidget {

  final T? value;

  /// The list of items to display in the dropdown.
  /// This is now a standard list of DropdownMenuItems.
  final List<DropdownMenuItem<T>> items;

  /// The callback function that is triggered when a new item is selected.
  final ValueChanged<T?>? onChanged;

  /// The validator function for the form field.
  final FormFieldValidator<T>? validator;

  /// The text displayed as the label for the dropdown.
  final String label;

  /// Optional text to display as a hint when no value is selected.
  final String? hintText;

  /// Optional icon to display before the text.
  final Widget? prefixIcon;

  /// Optional icon to display at the end (defaults to dropdown arrow).
  final Widget? icon;

  /// The fixed height of the dropdown. Defaults to 50.
  final double? height;
  final double? width;

  /// The background color of the dropdown menu.
  final Color? dropdownColor;

  /// The text style for the selected item and items in the list.
  final TextStyle? style;

  /// The text style for the label when it's floating.
  final TextStyle? floatingLabelStyle;

  /// The text style for the label when it's not floating.
  final TextStyle? labelStyle;

  /// The text style for the hint text.
  final TextStyle? hintStyle;

  /// The padding inside the dropdown button.
  final EdgeInsetsGeometry? contentPadding;

  /// The border radius for all corners of the dropdown.
  final double borderRadius;

  /// Whether the dropdown should expand to fill its horizontal space.
  final bool isExpanded;

  /// Maximum height of the dropdown menu
  final double? menuMaxHeight;

  /// **NEW:** If you provide this, the dropdown becomes a "fake"
  /// tap-able field (for lookups like a country picker).
  final VoidCallback? onTap;

  /// **CHANGED:** Now generic, with [prefixIcon] and [icon] (suffix) added.
  /// [items] is now List<DropdownMenuItem<T>>.
  const CustomDropdownFormField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.label,
    this.value,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.icon,
    this.height = 50.0,
    this.width = double.infinity,
    this.dropdownColor,
    this.style,
    this.floatingLabelStyle,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.borderRadius = 13.0,
    this.isExpanded = false,
    this.menuMaxHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided style or default to the theme's bodyLarge
    final textStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    final effectiveLabelStyle =
        labelStyle ?? const TextStyle(color: AppColors.textGrey, fontSize: 13);
    final effectiveFloatingLabelStyle = floatingLabelStyle ??
        const TextStyle(color: AppColors.textGrey, fontSize: 14);
    final effectiveHintStyle = hintStyle ?? effectiveLabelStyle;

    final effectivePadding = contentPadding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 0);

    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget dropdown = DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: textStyle,
      dropdownColor: dropdownColor ?? AppColors.white,
      icon: icon,
      isExpanded: isExpanded,
      menuMaxHeight: menuMaxHeight,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        labelStyle: effectiveLabelStyle,
        floatingLabelStyle: effectiveFloatingLabelStyle,
        hintStyle: effectiveHintStyle,
        contentPadding: effectivePadding,
        helperText: ' ', // Step 1: Error message ke liye jagah reserve karein
        helperStyle: const TextStyle(height: 0.5), // Step 2: Us jagah ki height kam rakhein
        errorStyle: const TextStyle(height: 0.5), // Optional: Error text ki height ko bhi control karein
        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: onChanged == null ? AppColors.lightGrey : AppColors.primary,
            width: onChanged == null ? 1 : 0.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: dropdown,
        ),
      );
    }

    return dropdown;
  }
}
class CustomLookupFormField extends StatelessWidget {
  /// The controller for the text field.
  final TextEditingController controller;

  /// The text to display as the label.
  final String labelText;

  /// The text to display as a hint.
  final String? hintText;

  /// The function to call when the field is tapped.
  final VoidCallback onTap;

  /// The validator function for the form field.
  final FormFieldValidator<String>? validator;

  /// The icon to display at the end of the field.
  final Widget? suffixIcon;

  const CustomLookupFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onTap,
    this.hintText,
    this.validator,
    this.suffixIcon = const Icon(
      Icons.keyboard_arrow_down,
      color: AppColors.primary,
    ),
  });

  @override
  Widget build(BuildContext buildContext) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            floatingLabelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            hintText: hintText,
            suffixIcon: suffixIcon,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}