import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CustomDatePicker {
  /// Shows a custom date picker with consistent styling
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
            datePickerTheme: DatePickerThemeData(
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.gray.withOpacity(0.3);
                }
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return AppColors.black;
              }),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.black),
                backgroundColor: WidgetStatePropertyAll(AppColors.white),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    vertical: AppSizes.h4,
                    horizontal: AppSizes.w16,
                  ),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                    side: BorderSide(color: AppColors.gray),
                  ),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(
                    fontSize: AppSizes.v16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.white),
                backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    vertical: AppSizes.h4,
                    horizontal: AppSizes.w16,
                  ),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
                  ),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(
                    fontSize: AppSizes.v16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
  static themeBuilder (BuildContext context) {
    return (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
          datePickerTheme: DatePickerThemeData(
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.gray.withOpacity(0.3);
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              return AppColors.black;
            }),
            cancelButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColors.black),
              backgroundColor: WidgetStatePropertyAll(AppColors.white),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  vertical: AppSizes.h4,
                  horizontal: AppSizes.w16,
                ),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                  side: BorderSide(color: AppColors.gray),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: AppSizes.v16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            confirmButtonStyle: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColors.white),
              backgroundColor: WidgetStatePropertyAll(AppColors.primary),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  vertical: AppSizes.h4,
                  horizontal: AppSizes.w16,
                ),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.v12),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: AppSizes.v16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.white,
            dialBackgroundColor: AppColors.primary.withAlpha(20),
            hourMinuteTextColor: AppColors.textPrimary,
            hourMinuteColor:  AppColors.primary.withAlpha(20),


            // --- AM/PM FIX YAHAN HAI ---

            // Selected (active) AM/PM toggle ka background color
            dayPeriodColor: AppColors.primary.withOpacity(0.40),

            // Dono (active aur inactive) AM/PM ka text color
            dayPeriodTextColor: AppColors.textPrimary,

            // Inactive AM/PM toggle ka border
            dayPeriodBorderSide: const BorderSide(color: AppColors.lightGrey),

            // Shape (optional, but for rounded corners)
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.h8),
            ),
          ),
        ),
        child: child!,
      );
    };
  }
}
