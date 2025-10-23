import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';

/// Centralized text styles for consistent typography across the app
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // =======================
  // Headings
  // =======================
  static TextStyle headingLarge({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontDisplay1,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: AppSizes.letterSpacingTight,
  );

  static TextStyle mediumHeading({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  static TextStyle headingMedium({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontDisplay2,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: AppSizes.letterSpacingTight,
  );

  static TextStyle headingSmall({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontXxxl,
    fontWeight: FontWeight.bold,
    color: AppColors.getTextPrimary(isDark),
  );

  static TextStyle headingxSmall({required bool isDark}) =>
      GoogleFonts.montserrat(
        fontSize: 19, // Responsive with flutter_screenutil
        fontWeight:
            FontWeight.bold, // Medium-bold, mimicking AirBnB's thickness
        color: AppColors.getTextPrimary(isDark),
        letterSpacing: -0.4, // Tight letter spacing for a refined look
      );

  // =======================
  // Subheadings / Titles
  // =======================
  static TextStyle titleLarge({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontHeadline1,
    fontWeight: FontWeight.w600,
    color: AppColors.getTextPrimary(isDark),
  );

  static TextStyle titleMedium({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontHeadline3,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
  );

  static TextStyle titleSmall({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontLarge,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
  );

  // =======================
  // Body Text
  // =======================
  static TextStyle bodyLarge({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontLarge,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: AppSizes.letterSpacingWide,
  );

  static TextStyle bodyMedium({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontMedium,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: AppSizes.letterSpacingExtraWide,
  );

  static TextStyle bodySmall({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontSmall,
    fontWeight: FontWeight.normal,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: AppSizes.letterSpacingLabel,
  );

  // =======================
  // Buttons
  // =======================
  static TextStyle button({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontLarge,
    fontWeight: FontWeight.w600,
    color: AppColors.getBackground(isDark),
    letterSpacing: AppSizes.letterSpacingLabel,
  );

  // =======================
  // Captions / Hints
  // =======================
  static TextStyle caption({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontSmall + 1,
    fontWeight: FontWeight.w400,
    color: AppColors.getTextSecondary(isDark),
  );

  // =======================
  // Labels
  // =======================
  static TextStyle labelLarge({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextPrimary(isDark),
    letterSpacing: AppSizes.letterSpacingWide,
  );

  static TextStyle labelMedium({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: AppSizes.letterSpacingLabel,
  );

  static TextStyle labelSmall({required bool isDark}) => TextStyle(
    fontSize: AppSizes.fontXs + 1,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: AppSizes.letterSpacingLabel,
  );
}
