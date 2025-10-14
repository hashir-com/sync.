import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';

/// Centralized text styles for consistent typography across the app
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // =======================
  // Headings
  // =======================
  static TextStyle headingLarge({required bool isDark}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: -0.5,
  );

  static TextStyle extraHeadingLarge({required bool isDark}) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: 0,
  );

  static TextStyle headingMedium({required bool isDark}) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: -0.5,
  );

  static TextStyle headingSmall({required bool isDark}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
  );

  // =======================
  // Subheadings / Titles
  // =======================
  static TextStyle titleLarge({required bool isDark}) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.getTextPrimary(isDark),
  );

  static TextStyle titleMedium({required bool isDark}) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
  );

  static TextStyle titleSmall({required bool isDark}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
  );

  // =======================
  // Body Text
  // =======================
  static TextStyle bodyLarge({required bool isDark}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: 0.15,
  );

  static TextStyle bodyMedium({required bool isDark}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall({required bool isDark}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: 0.4,
  );

  // =======================
  // Buttons
  // =======================
  static TextStyle button({required bool isDark}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.getBackground(isDark),
    letterSpacing: 0.8,
  );

  // =======================
  // Captions / Hints
  // =======================
  static TextStyle caption({required bool isDark}) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.getTextSecondary(isDark),
  );

  // =======================
  // Labels
  // =======================
  static TextStyle labelLarge({required bool isDark}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium({required bool isDark}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall({required bool isDark}) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: 0.5,
  );
}
