part of 'app_resources.dart';

/// A centralized class for defining application-wide color constants.
///
/// This ensures consistency across the manager and makes it easy to update colors in one place.
abstract class AppColors {
  // Basic Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = Colors.red;
  static const Color grey = Colors.grey;
  static const Color orange = Colors.orange;
  static const Color blue = Colors.blue;
  static const Color transparent = Colors.transparent;

  // Primary Theme Colors
  static const Color primary = Color(0xFF042c74);
  static const Color primaryLight = Color(0xFF2681E1);
  static const Color primaryDark = Color(0xFF003382);
  static const Color primaryVariant = Color(0xFF2681E1);
  static const Color primarySuperLight = Color(0xFF687FE5);

  // Secondary Colors
  static const Color secondary = primary;
  static const Color secondaryLight = Color(0xFFb5a8d5);
  static const Color secondaryDark = Color(0xFF5746A6);
  static const Color secondaryVariant = Color(0xFF43307F);
  static const Color appbarVarient = Color(0xFF003382);
  static const Color violetBlue = Color(0xFF8F87F1);

  // Accent Colors
  static const Color accent = Color(0xFFff6b6b);
  static const Color accentLight = Color(0xFFFFA8A8);
  static const Color accentDark = Color(0xFFD43D3D);

  // Neutral Colors
  static const Color gray = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF616161);
  static const Color softGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFBDBDBD);
  static const Color whisperGray = Color(0xFFEFEEEF);

  static const Color softGreen = Color(0xFF4CAF50);
  static const Color backgroundlightgreen = Color(0xFF3A98B9);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  static const Color textOnAccent = Colors.white;
  static const Color textGrey = Color(0xFF595959);
  static const Color textOnSurface = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFF5F5FA);
  static const Color scaffoldBackground = Color(0xFFF6F6F6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color appBarBackground = Color(0xFFECECEC);
  static const Color walletBackground = Color(0xFF76BA99);

  // State Colors
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF28A745);
  static const Color info = Color(0xFF1976D2);

  // Disabled & Inactive Colors
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color inactive = Color(0xFFEEEEEE);
  static const Color overlay = Color(0x66000000);

  static const Color pink = Color(0xFFED75E3); // 40% black for overlays
  static const Color lightGreen = Color(0xFF6CCA9B); // 40% black for overlays
  static const Color yellow = Color(0xFFF3B33E); // 40% black for overlays
  static const Color darkGreen = Color(0xFFB7BE79); // 40% black for overlays
  static const Color darkPink = Color(0xFFD28591); // 40% black for overlays

  // icon background color
  static const Color bluebackground = Color(0xFF4ED7F1);
  static const Color periwinklePurple = Color(0xFF8F86F0);
  static const Color greenbackground = Color(0xFF76BA99);
  static const Color redbackground = Color(0xFFE97777);
  static const Color darkGreenBack = Color(0xFF3A98B9);
  static const Color redBack = Color(0xFFC52E2E);
  static const Color skyBlue = Color(0xFF4ED6F0);
  static const Color forestGreen = Color(0xFF537D5D);
  static const Color colorBlue = Color(0xFF314E8D);
  static const Color amberOrange = Color(0xFFFEB040);
  static const Color colorF0F2FC = Color(0xFFF0F2FC);
  static const Color crimsonRed = Color(0xFFDF4747);
  static const Color indigoBlue = Color(0xFF687EE4);
  static const Color mintGreen = Color(0xFF41C392);
  static const Color oliveGreen = Color(0xFF9E9F0C);
  static const Color lavenderMist = Color(0xFFF1F2FD);
  static const Color mediumPeriwinkle = Color(0xFF8F87F0);
  static const Color lightCoral = Color(0xFFE97776);
  static const Color blueLagoon = Color(0xFF3A99B8);
  static const Color snowDrift = Color(0xFFF6F7F6);
  static const Color almostWhite = Color(0xFFFEFEFE);

  // Dialog Colors
  static const Color warningRed = Color(0xFFD93025);
  static const Color warningLightRed = Color(0xFFFCE8E6);

  // Additional Colors
  static const Color orangeColor = Color(0xFFFF9800);
  static const Color colorFF6868 = Color(0xFFFF6868);
  static const Color colorF2A22E = Color(0xFFF2A22E);
  static const Color color41C293 = Color(0xFF41C293);
  static const Color colorFFB141 = Color(0xFFFFB141);
  static const Color color0ABAB5 = Color(0xFF0ABAB5);
  static const Color purple = Color(0xFF9C27B0);
  static const Color colorF8FBFE = Color(0xFFF8FBFE);
  static const Color peachPuff = Color(0xFFFEF3E7);
  static const Color mistyRose = Color(0xFFFFEAEB);
  static const Color teaGreen = Color(0xFFF0F6EB);
  static const Color lavenderBlue = Color(0xFFE9ECFB);

  // Organization Colors
  static const Color organizationGreen = Color(0xFF179959);

  // Profile Progress Colors
  static const Color progressRed = Color(0xFFDF4747); // 0-30% Completed
  static const Color progressOrange = Color(0xFFFFB141); // 31-69% Completed
  static const Color progressBlue = Color(0xFF687FE5); // 70-99% Completed
  static const Color progressGreen = Color(0xFF41C293); // 100% Completed

  static const Color periwinkleBlue = Color(0xFF687FE5);
  static const Color emeraldGreen = Color(0xFF38AE41);
  static const Color leafGreen = Color(0xFF3DAF41);
  static const Color turquoiseBlue = Color(0xFF4FD6F0);
  static const Color cultured = Color(0xFFF7F7F6);
  static const Color gunmetal = Color(0xFF292D32);
}
