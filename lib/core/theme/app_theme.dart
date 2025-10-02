import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      onPrimary: Colors.white, // Button text
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headingLarge(AppColors.textPrimaryLight),
      headlineMedium: AppTextStyles.headingMedium(AppColors.textPrimaryLight),
      bodyLarge: AppTextStyles.bodyLarge(AppColors.textSecondaryLight),
      bodyMedium: AppTextStyles.bodyMedium(AppColors.textSecondaryLight),
      labelLarge: AppTextStyles.button(Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      onPrimary: Colors.white, // Button text
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headingLarge(AppColors.textPrimaryDark),
      headlineMedium: AppTextStyles.headingMedium(AppColors.textPrimaryDark),
      bodyLarge: AppTextStyles.bodyLarge(AppColors.textSecondaryDark),
      bodyMedium: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
      labelLarge: AppTextStyles.button(Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );
}
