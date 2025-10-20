// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Mode Provider

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_event/core/constants/app_colors.dart';

// ---------------- Theme Persistence Provider ----------------

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

// App Theme Configuration

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Light Theme

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
      outline: AppColors.borderLight,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
      hintStyle: TextStyle(
        color: AppColors.textSecondaryLight.withOpacity(0.6),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 24),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 1,
      space: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 16,
        letterSpacing: 0.15,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.disabledLight,
      labelStyle: const TextStyle(color: AppColors.textPrimaryLight),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimaryLight,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardLight,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.disabledLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withOpacity(0.5);
        }
        return AppColors.borderLight;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondaryLight;
      }),
    ),
  );

  // Dark Theme

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryVariant,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryVariant,
      secondary: AppColors.secondaryVariant,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimaryDark,
      onError: Colors.white,
      outline: AppColors.borderDark,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 4,
      shadowColor: AppColors.shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryVariant,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryVariant,
        side: const BorderSide(color: AppColors.primaryVariant, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryVariant, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
      hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.6)),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16,
        letterSpacing: 0.15,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.primaryVariant,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryVariant,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.primaryVariant,
      disabledColor: AppColors.disabledDark,
      labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: AppColors.borderDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryVariant,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryVariant;
        }
        return AppColors.disabledDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryVariant.withOpacity(0.5);
        }
        return AppColors.borderDark;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryVariant;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryVariant;
        }
        return AppColors.textSecondaryDark;
      }),
    ),
  );
}
