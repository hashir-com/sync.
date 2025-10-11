import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<bool>((ref) => false);
class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF04007C);
  static const Color lightSecondary = Color(0xFF64B5F6);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkPrimary = Color.fromARGB(255, 78, 66, 245);
  static const Color darkSecondary = Color(0xFF90CAF9);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkShadow = Color(0x33000000);
  static const Color darkCardBackground = Color(0xFF2C2C2C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
    ),
    cardTheme: CardThemeData(
      color: lightCardBackground,
      elevation: 2,
      shadowColor: lightShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: lightTextPrimary),
      bodyMedium: TextStyle(color: lightTextSecondary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
    ),
    cardTheme: CardThemeData(
      color: darkCardBackground,
      elevation: 4,
      shadowColor: darkShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextSecondary),
    ),
  );
}

class AppColors {
  final bool isDark;

  AppColors(this.isDark);

  Color get primary => isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
  Color get secondary =>
      isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary;
  Color get background =>
      isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get textPrimary =>
      isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get textSecondary =>
      isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get border => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get cardBackground =>
      isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
  Color get shadow => isDark ? AppTheme.darkShadow : AppTheme.lightShadow;
}
