import 'dart:math';

import 'package:flutter/widgets.dart';

/// Extension on `num` to provide adaptive height, width, font size, and radius.
/// Uses [ScreenUtil] to calculate responsive sizes.
extension Percentage on num {
  /// Returns the responsive height based on the screen size.
  double get h => ScreenUtil.instance.height(this);

  /// Returns the responsive width based on the screen size.
  double get w => ScreenUtil.instance.width(this);

  /// Returns the responsive font size based on the screen size.
  double get sp => ScreenUtil.instance.setSp(this);

  /// Returns the responsive radius size based on the screen size.
  double get r => ScreenUtil.instance.radius(this);
}

/// A utility class for handling responsive UI scaling.
///
/// It calculates dimensions relative to a base design size (e.g., 411x820) and
/// scales widgets accordingly to fit different screen sizes.
class ScreenUtil {
  /// Singleton instance of [ScreenUtil].
  static final ScreenUtil instance = ScreenUtil._();

  /// Scale factor based on the screen width.
  late double scaleWidth;

  /// Scale factor based on the screen height.
  late double scaleHeight;

  /// Scale factor for text sizes (based on the smaller of width/height scaling).
  late double scaleText;

  /// Private constructor for singleton pattern.
  ScreenUtil._();

  /// Initializes the [ScreenUtil] with the device's screen size.
  ///
  /// This method **must** be called inside the `build` method of the manager's root widget.
  /// ```dart
  /// ScreenUtil.instance.init(context);
  /// ```
  void init() {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    scaleWidth = size.width/411;
    scaleHeight = size.height/820;
    scaleText = min(
      scaleWidth,
      scaleHeight,
    ); // Use the smallest factor for text scaling
  }

  /// Returns the responsive height based on the screen size.
  double height(num height) => height * scaleHeight;

  /// Returns the responsive width based on the screen size.
  double width(num width) => width * scaleWidth;

  /// Returns the responsive font size based on the screen size.
  double setSp(num fontSize) => fontSize * scaleText;

  /// Returns the responsive radius size based on the screen size.
  double radius(num radius) => radius * scaleText;

  /// Determines the device type based on screen dimensions.
  ///
  /// Returns one of:
  /// - `TypeOfDevice.verySmall` for very small screens.
  /// - `TypeOfDevice.small` for small screens.
  /// - `TypeOfDevice.medium` for medium screens.
  /// - `TypeOfDevice.large` for large screens.
  /// - `TypeOfDevice.xl` for extra-large screens.
  TypeOfDevice get typeOfDevice {
    final screenSize =
        MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    final plus = screenSize.width + screenSize.height;

    if (plus < 950) return TypeOfDevice.verySmall;
    if (plus < 1170) return TypeOfDevice.small;
    if (plus < 1190) return TypeOfDevice.medium;
    if (plus < 1229) return TypeOfDevice.large;
    return TypeOfDevice.xl;
  }
}

/// Enum representing different device sizes.
enum TypeOfDevice { none, verySmall, small, medium, large, xl }
