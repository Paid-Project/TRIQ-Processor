import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgIcon extends StatelessWidget {
  final String svgName;
  final Color backgroundColor;
  final Color? iconColor;
  final String backgroundType;
  final double size;
  final bool isFilled;

  const CustomSvgIcon({
    super.key,
    required this.svgName,
    required this.backgroundColor,
    this.iconColor,
    this.backgroundType = "square",
    this.size = 10,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadAndModifySvg(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: backgroundType == "circle"
                  ? BorderRadius.circular(size / 2)
                  : BorderRadius.circular(size * 0.1), // Slight rounding for square
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.2), // 20% padding
              child: SvgPicture.string(
                snapshot.data!,
                fit: BoxFit.contain,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: backgroundType == "circle"
                  ? BorderRadius.circular(size / 2)
                  : BorderRadius.circular(size * 0.1),
            ),
            child: Icon(
              Icons.error,
              color: iconColor ?? Colors.grey,
              size: size * 0.6,
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: backgroundType == "circle"
                ? BorderRadius.circular(size / 2)
                : BorderRadius.circular(size * 0.1),
          ),
          child: Center(
            child: SizedBox(
              width: size * 0.3,
              height: size * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor ?? Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _loadAndModifySvg() async {
    try {
      // Load the SVG file from assets
      String svgString = await rootBundle.loadString('assets/svg/$svgName');

      // Calculate the icon size (60% of total size for proper padding)
      double iconSize = size * 0.6;

      // Modify the SVG string
      String modifiedSvg = _modifySvgString(svgString, iconSize);

      return modifiedSvg;
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  String _modifySvgString(String originalSvg, double iconSize) {
    String modifiedSvg = originalSvg;

    // Replace the SVG opening tag with custom width, height, and viewBox
    RegExp svgTagRegex = RegExp(r'<svg[^>]*>');
    String newSvgTag = '<svg width="$iconSize" height="$iconSize" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">';
    modifiedSvg = modifiedSvg.replaceFirst(svgTagRegex, newSvgTag);

    // Only modify colors if iconColor is provided
    if (iconColor != null) {
      String colorHex = '#${iconColor!.value.toRadixString(16).substring(2).toUpperCase()}';

      if (isFilled) {
        // For filled icons: replace all fill attributes with the new icon color
        modifiedSvg = modifiedSvg.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="$colorHex"');

        // If there are no fill attributes, add them to path elements
        if (!modifiedSvg.contains('fill=')) {
          modifiedSvg = modifiedSvg.replaceAll('<path d=', '<path fill="$colorHex" d=');
        }

        // Remove stroke attributes for filled icons
        modifiedSvg = modifiedSvg.replaceAll(RegExp(r'stroke="[^"]*"'), '');
        modifiedSvg = modifiedSvg.replaceAll(RegExp(r'stroke-width="[^"]*"'), '');
      } else {
        // For outlined icons: set fill to none and add stroke
        modifiedSvg = modifiedSvg.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="none"');
        modifiedSvg = modifiedSvg.replaceAll(RegExp(r'stroke="[^"]*"'), 'stroke="$colorHex"');

        // If there are no stroke attributes, add them to path elements
        if (!modifiedSvg.contains('stroke=')) {
          modifiedSvg = modifiedSvg.replaceAll('<path d=', '<path fill="none" stroke="$colorHex" stroke-width="2" d=');
        }

        // Ensure stroke-width is set
        if (!modifiedSvg.contains('stroke-width')) {
          modifiedSvg = modifiedSvg.replaceAll('stroke="$colorHex"', 'stroke="$colorHex" stroke-width="2"');
        }
      }
    }
    return modifiedSvg;
  }
}