import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors

  static const primary = Color(0xFF04007C);
  static const primaryVariant = Color(0xFF4E42F5);
  static const secondary = Color(0xFF64B5F6);
  static const secondaryVariant = Color(0xFF90CAF9);

  static const Color primaryLight = Color(0xFF6B7FFF);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // Light Mode Colors

  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF5F5F5);
  static const cardLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF212121);
  static const textSecondaryLight = Color(0xFF757575);
  static const borderLight = Color(0xFFE0E0E0);
  static const dividerLight = Color(0xFFBDBDBD);
  static const shadowLight = Color(0x1A000000);
  static const disabledLight = Color(0xFFBDBDBD);

  // Dark Mode Colors

  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2C2C2C);
  static const textPrimaryDark = Color(0xFFE0E0E0);
  static const textSecondaryDark = Color(0xFFB0B0B0);
  static const borderDark = Color(0xFF2C2C2C);
  static const dividerDark = Color(0xFF424242);
  static const shadowDark = Color(0x33000000);
  static const disabledDark = Color(0xFF616161);

  // Status Colors (Universal)

  static const success = Color(0xFF388E3C);
  static const successDark = Color(0xFF66BB6A);

  static const error = Color(0xFFD32F2F);
  static const errorDark = Color(0xFFEF5350);

  static const warning = Color(0xFFF57C00);
  static const warningDark = Color(0xFFFFB74D);

  static const info = Color(0xFF1976D2);
  static const infoDark = Color(0xFF42A5F5);

  // Accent Colors

  static const favorite = Color(0xFFE91E63);
  static const favoriteDark = Color(0xFFEC407A);

  // Shimmer Colors
  static const shimmerBaseLight = borderLight;
  static const shimmerHighlightLight = Color(0xFFF5F5F5);
  static const shimmerBaseDark = borderDark;
  static const shimmerHighlightDark = Color(0xFF424242);

  // Special Use (Splash / Branding)

  static const splash = Color(0xFF131C67);
  static const splashText = Color(0xFFA6AFFF);

  // Helper Methods

  /// Get primary color based on theme mode
  static Color getPrimary(bool isDark) => isDark ? primaryVariant : primary;

  static Color getSplash(bool isDark) => isDark ? splash : splashText;

  /// Get secondary color based on theme mode
  static Color getSecondary(bool isDark) =>
      isDark ? secondaryVariant : secondary;

  /// Get background color based on theme mode
  static Color getBackground(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;

  /// Get surface color based on theme mode
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;

  /// Get card color based on theme mode
  static Color getCard(bool isDark) => isDark ? cardDark : cardLight;

  /// Get primary text color based on theme mode
  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  /// Get secondary text color based on theme mode
  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;

  /// Get border color based on theme mode
  static Color getBorder(bool isDark) => isDark ? borderDark : borderLight;

  /// Get divider color based on theme mode
  static Color getDivider(bool isDark) => isDark ? dividerDark : dividerLight;

  /// Get shadow color based on theme mode
  static Color getShadow(bool isDark) => isDark ? shadowDark : shadowLight;

  /// Get disabled color based on theme mode
  static Color getDisabled(bool isDark) =>
      isDark ? disabledDark : disabledLight;

  /// Get error color based on theme mode
  static Color getError(bool isDark) => isDark ? errorDark : error;

  /// Get success color based on theme mode
  static Color getSuccess(bool isDark) => isDark ? successDark : success;

  /// Get warning color based on theme mode
  static Color getWarning(bool isDark) => isDark ? warningDark : warning;

  /// Get info color based on theme mode
  static Color getInfo(bool isDark) => isDark ? infoDark : info;

  /// Get favorite color based on theme mode
  static Color getFavorite(bool isDark) => isDark ? favoriteDark : favorite;

  static Color getShimmerBase(bool isDark) =>
      isDark ? shimmerBaseDark : shimmerBaseLight;
  static Color getShimmerHighlight(bool isDark) =>
      isDark ? shimmerHighlightDark : shimmerHighlightLight;
}
