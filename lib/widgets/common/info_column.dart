import 'package:flutter/material.dart';
import '../../resources/app_resources/app_resources.dart';

/// A reusable widget for displaying label-value pairs in a column layout.
///
/// This widget provides a consistent way to display information with a label
/// on top and a value below it, following the manager's design system.
class InfoColumn extends StatelessWidget {
  /// The label text to display at the top
  final String label;

  /// The value text to display below the label
  final String value;

  /// Optional color for the value text
  final Color? valueColor;

  /// Optional font weight for the value text
  final FontWeight? valueFontWeight;

  /// Optional font size for the label text
  final double? labelFontSize;

  /// Optional font size for the value text
  final double? valueFontSize;

  /// Maximum number of lines for the value text
  final int? maxLines;

  /// Text overflow behavior for the value text
  final TextOverflow? overflow;

  /// Cross axis alignment for the column
  final CrossAxisAlignment crossAxisAlignment;

  const InfoColumn({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontWeight,
    this.labelFontSize,
    this.valueFontSize,
    this.maxLines,
    this.overflow,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize ?? AppSizes.f11,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize ?? AppSizes.f11,
            color: valueColor ?? AppColors.black,
            fontWeight: valueFontWeight,
          ),
          maxLines: maxLines,
          overflow: overflow,
        ),
      ],
    );
  }
}
