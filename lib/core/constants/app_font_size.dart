import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';

class AppFontSizes {
  // Headings
  static double heading1 = 32.sp; // Very large headings
  static double heading2 = 28.0; // Main screen title
  static double heading3 = 24.0; // Section title
  static double heading4 = 20.0; // Card titles

  // Body Text
  static const double bodyLarge = 18.0; // Large paragraph text
  static const double body = 16.0; // Standard body text
  static const double bodySmall = 14.0; // Secondary text

  // Captions & Hints
  static const double caption = 12.0; // Labels, small descriptions
  static const double tiny = 10.0; // Very small text, like tooltips
}

Widget heading(String heading) => Text(
  heading,
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.textwhite,
    fontSize: 22.sp,
  ),
  textAlign: TextAlign.center,
);
