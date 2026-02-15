part of 'app_resources.dart';

abstract class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.transparent,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SlideRightPageTransitionsBuilder(),
        TargetPlatform.iOS: SlideRightPageTransitionsBuilder(),
      },
    ),
    chipTheme: ChipThemeData(side: BorderSide.none),
    appBarTheme: AppBarTheme(
      actionsIconTheme: IconThemeData(color: AppColors.white),
      actionsPadding: EdgeInsets.only(right: AppSizes.w10),
      backgroundColor: AppColors.transparent,
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      centerTitle: false,
    ),
    datePickerTheme: DatePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.white),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: AppSizes.h4, horizontal: AppSizes.w16),
        ),
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.white;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.primary.withValues(alpha: 0.1);
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.white;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.primary.withValues(alpha: 0.1);
      }),
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      headerForegroundColor: AppColors.primary,
      headerBackgroundColor: AppColors.white,
      confirmButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.h4,
          horizontal: AppSizes.w26,
        ),
        disabledBackgroundColor: AppColors.gray,
        disabledForegroundColor: AppColors.textOnPrimary,
        maximumSize: Size(double.infinity, AppSizes.h70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.v16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.gray,
      selectedLabelStyle: TextStyle(
        fontSize: AppSizes.v10,
        color: AppColors.primary,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppSizes.v10,
        color: AppColors.gray,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      selectedIconTheme: IconThemeData(
        color: AppColors.white,
        size: AppSizes.v34,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.gray,
        size: AppSizes.v34,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.v16),
      ),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: AppSizes.v18,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      contentTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppSizes.v14,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnSecondary,
      onSurface: AppColors.textOnPrimary,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(AppColors.primary),
      fillColor: WidgetStateColor.transparent,
      overlayColor: WidgetStateProperty.all(AppColors.transparent),
      side: WidgetStateBorderSide.resolveWith((states) {
        return BorderSide(color: AppColors.primary, width: 1.5);
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.v6),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.white,
      linearTrackColor: AppColors.primary,
      linearMinHeight: AppSizes.h6,
      borderRadius: BorderRadius.circular(AppSizes.v10),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.background),
        shadowColor: WidgetStatePropertyAll(AppColors.darkGray),
        surfaceTintColor: WidgetStatePropertyAll(AppColors.background),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.v12,
            ), // Custom Border Radius
          ),
        ),
      ),
      textStyle: TextStyle(color: AppColors.white, fontSize: AppSizes.v16),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
        ),
        hintStyle: TextStyle(color: AppColors.gray),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(AppColors.scaffoldBackground),
      overlayColor: WidgetStatePropertyAll(AppColors.gray),
      surfaceTintColor: WidgetStatePropertyAll(AppColors.scaffoldBackground),
      elevation: WidgetStatePropertyAll(0),
      shadowColor: WidgetStatePropertyAll(AppColors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
        ),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: AppColors.gray)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(color: AppColors.black, fontSize: AppSizes.v16),
      ),
      hintStyle: WidgetStatePropertyAll(
        TextStyle(color: AppColors.gray, fontSize: AppSizes.v16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.v12)),
      ),
      labelStyle: TextStyle(color: AppColors.gray),
      hintStyle: TextStyle(color: AppColors.gray),
      helperStyle: TextStyle(color: AppColors.gray),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.gray,
        disabledForegroundColor: AppColors.textOnPrimary,
        maximumSize: Size(double.infinity, AppSizes.h70),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w18,
          vertical: AppSizes.h18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.v16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primary,
        // disabledBackgroundColor: AppColors.gray,
        disabledForegroundColor: AppColors.textOnPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w16,
          vertical: AppSizes.v16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          side: BorderSide(color: AppColors.primary),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.v16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.primary,
        surfaceTintColor: AppColors.transparent,
        padding: EdgeInsets.all(AppSizes.v12),
        shape: CircleBorder(),
        overlayColor: AppColors.primaryDark,
      ),
    ),
    dividerTheme: DividerThemeData(color: AppColors.lightGrey, thickness: 1),
    tabBarTheme: TabBarThemeData(
      dividerHeight: 0.0,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v16,
        color: AppColors.black,
        decorationColor: AppColors.black,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v16,
        color: AppColors.gray,
        decorationColor: AppColors.gray,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: AppSizes.v30,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v22,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.v20,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v18,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.v16,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.v14,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: AppSizes.v18,
        color: AppColors.primary,
        decorationColor: AppColors.primary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v16,
        color: AppColors.primary,
        decorationColor: AppColors.primary,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.v14,
        color: AppColors.primary,
        decorationColor: AppColors.primary,
      ),
      bodyLarge: TextStyle(
        fontSize: AppSizes.v16,
        color: AppColors.black,
        decorationColor: AppColors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.v14,
        color: AppColors.darkGray,
        decorationColor: AppColors.darkGray,
      ),
      bodySmall: TextStyle(
        fontSize: AppSizes.v12,
        color: AppColors.gray,
        decorationColor: AppColors.gray,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.v14,
        color: AppColors.white,
        decorationColor: AppColors.white,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.v12,
        color: AppColors.white,
        decorationColor: AppColors.white,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: AppSizes.v10,
        color: AppColors.white,
        decorationColor: AppColors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    fontFamily: GoogleFonts.lato().fontFamily,
  );

  /// **Dark Theme**
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: Colors.blueAccent,
      surface: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    fontFamily: GoogleFonts.lato().fontFamily,
  );
}
