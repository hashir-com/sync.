import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const primary = Color(0xFF0057FF); 
  static const secondary = Color(0xFF1A1A1A); 

  // Light mode
  static const backgroundLight = Color(0xFFFFFFFF); 
  static const surfaceLight = Color(0xFFF5F5F5); // Cards, sheets
  static const textPrimaryLight = Color(0xFF000000); // Black text
  static const textSecondaryLight = Color(0xFF444444); // Muted black/gray

  // Dark mode
  static const backgroundDark = Color(0xFF121212); 
  static const surfaceDark = Color(0xFF1E1E1E); // Dark cards, sheets
  static const textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const textSecondaryDark = Color(0xFFB3B3B3); // Muted white/gray

  // Status colors (universal)
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFF9800);

  // Special use (Splash / branding)
  static const splash = Color(0xFF131C67);
  static const splashText = Color(0xFFA6AFFF);
}
