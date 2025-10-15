// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility helpers to make theme-related logic simpler and reusable
class ThemeUtils {
  ThemeUtils._();

  
  //BRIGHTNESS HELPERS
  

  /// Returns true if current theme is dark
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Returns the correct background color for current theme
  static Color background(BuildContext context) =>
      AppColors.getBackground(isDark(context));

  /// Returns primary text color based on theme
  static Color textPrimary(BuildContext context) =>
      AppColors.getTextPrimary(isDark(context));

  /// Returns secondary text color based on theme
  static Color textSecondary(BuildContext context) =>
      AppColors.getTextSecondary(isDark(context));

  /// Returns app primary color
  static Color primaryColor(BuildContext context) =>
      AppColors.primary;

  
  // COLOR CONTRAST HELPERS
  

  /// Returns a text color (black/white) that contrasts best with [background]
  static Color getContrastingTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  /// Blends two colors together by [t] percentage (0.0–1.0)
  static Color blendColors(Color a, Color b, double t) {
    assert(t >= 0 && t <= 1);
    return Color.lerp(a, b, t)!;
  }

  
  // MATERIAL STATE HELPERS
  

  /// Creates a WidgetStateProperty for button background colors
  static WidgetStateProperty<Color?> buttonColor(
    BuildContext context, {
    required Color color,
  }) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return color.withOpacity(0.5);
      }
      if (states.contains(WidgetState.pressed)) {
        return color.withOpacity(0.8);
      }
      return color;
    });
  }

  /// Creates a WidgetStateProperty for text/button foreground colors
  static WidgetStateProperty<Color?> textColor(
    BuildContext context, {
    required Color color,
  }) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return color.withOpacity(0.4);
      }
      return color;
    });
  }

  
  //  ELEVATION / SHADOW HELPERS
  

  /// Returns appropriate shadow color based on current theme
  static Color shadowColor(BuildContext context) =>
      isDark(context) ? Colors.black.withOpacity(0.4) : Colors.black12;

  /// Returns card color that matches elevation style of current theme
  static Color cardColor(BuildContext context) =>
      isDark(context)
          ? AppColors.surfaceDark
          : AppColors.surfaceLight;
}
