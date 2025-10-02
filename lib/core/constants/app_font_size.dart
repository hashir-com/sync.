import 'package:flutter/material.dart';

class AppTextStyles {
  // Shared font family
  static const fontFamily = "baron";

  // These will be overridden by theme (light/dark)
  static TextStyle splash(Color color) =>
      TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: color);

  static TextStyle headingLarge(Color color) =>
      TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: color);

  static TextStyle headingMedium(Color color) =>
      TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color);

  static TextStyle bodyLarge(Color color) =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color);

  static TextStyle bodyMedium(Color color) =>
      TextStyle(fontSize: 14, color: color);

  static TextStyle button(Color color) =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color);
}
