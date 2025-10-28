import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes and platforms
class ResponsiveUtil {
  // Prevent instantiation
  ResponsiveUtil._();

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600; // For TV/large web

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Check if current screen is large desktop/TV
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Get responsive AppBar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return 56.0;
    if (isTablet(context)) return 64.0;
    if (isDesktop(context)) return 72.0;
    return 80.0; // Large desktop/TV
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16.0);
    if (isTablet(context)) return const EdgeInsets.all(24.0);
    if (isDesktop(context)) return const EdgeInsets.all(32.0);
    return const EdgeInsets.all(40.0); // Large desktop/TV
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.symmetric(horizontal: 16.0);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 24.0);
    if (isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 32.0);
    return const EdgeInsets.symmetric(horizontal: 40.0);
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.symmetric(vertical: 16.0);
    if (isTablet(context)) return const EdgeInsets.symmetric(vertical: 20.0);
    return const EdgeInsets.symmetric(vertical: 24.0);
  }

  /// Get responsive screen padding with safe area
  static EdgeInsets getResponsiveScreenPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = isMobile(context)
        ? 16.0
        : isTablet(context)
        ? 24.0
        : isDesktop(context)
        ? 32.0
        : 40.0;
    final verticalPadding = isMobile(context)
        ? 16.0
        : isTablet(context)
        ? 20.0
        : 24.0;

    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      top: verticalPadding + mediaQuery.padding.top,
      bottom: verticalPadding + mediaQuery.padding.bottom,
    );
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) return 1.0;
    if (isTablet(context)) return 1.1;
    if (isDesktop(context)) return 1.2;
    return 1.4; // Large desktop/TV
  }

  /// Get responsive spacing multiplier
  static double getSpacingMultiplier(BuildContext context) {
    if (isMobile(context)) return 1.0;
    if (isTablet(context)) return 1.2;
    if (isDesktop(context)) return 1.5;
    return 2.0; // Large desktop/TV
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = isMobile(context)
        ? 32.0
        : isTablet(context)
        ? 48.0
        : isDesktop(context)
        ? 64.0
        : 80.0;
    if (isMobile(context)) return screenWidth - padding;
    if (isTablet(context)) return (screenWidth - padding) / 2;
    if (isDesktop(context)) return (screenWidth - padding) / 3;
    return (screenWidth - padding) / 4; // Large desktop/TV
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isDesktop(context)) return 3;
    return 4; // Large desktop/TV
  }

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800.0;
    if (isDesktop(context)) return 1200.0;
    return 1600.0; // Large desktop/TV
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return screenWidth * 0.6;
    if (isDesktop(context)) return 400.0;
    return 500.0; // Large desktop/TV
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48.0;
    if (isTablet(context)) return 52.0;
    if (isDesktop(context)) return 56.0;
    return 60.0; // Large desktop/TV
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context, {double baseSize = 40.0}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }

  /// Get responsive border radius
  static double getBorderRadius(
    BuildContext context, {
    double baseRadius = 12.0,
  }) {
    final multiplier = getFontSizeMultiplier(context);
    return baseRadius * multiplier;
  }

  /// Get responsive elevation
  static double getElevation(
    BuildContext context, {
    double baseElevation = 2.0,
  }) {
    if (isMobile(context)) return baseElevation;
    if (isTablet(context)) return baseElevation * 1.2;
    if (isDesktop(context)) return baseElevation * 1.5;
    return baseElevation * 1.8; // Large desktop/TV
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {double baseSpacing = 16.0}) {
    final multiplier = getSpacingMultiplier(context);
    return baseSpacing * multiplier;
  }

  /// Get responsive height spacing
  static double getHeightSpacing(
    BuildContext context, {
    double baseSpacing = 16.0,
  }) {
    final multiplier = getSpacingMultiplier(context);
    return baseSpacing * multiplier;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive column count for different content types
  static int getColumnCount(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
  }) {
    if (isMobile(context)) return mobileColumns;
    if (isTablet(context)) return tabletColumns;
    if (isDesktop(context)) return desktopColumns;
    return largeDesktopColumns;
  }

  /// Get responsive aspect ratio
  static double getAspectRatio(
    BuildContext context, {
    double mobileRatio = 16 / 9,
    double tabletRatio = 16 / 10,
    double desktopRatio = 16 / 9,
  }) {
    if (isMobile(context)) return mobileRatio;
    if (isTablet(context)) return tabletRatio;
    return desktopRatio;
  }

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var textScaleFactor = mediaQuery.textScaleFactor;

    // Limit text scale factor for better readability
    if (textScaleFactor > 1.3) textScaleFactor = 1.3;
    if (textScaleFactor < 0.8) textScaleFactor = 0.8;

    return textScaleFactor;
  }

  /// Get responsive safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get responsive bottom padding (considering keyboard)
  static double getBottomPadding(BuildContext context) {
    final keyboardHeight = getKeyboardHeight(context);
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    if (keyboardHeight > 0) return keyboardHeight + safeAreaBottom;

    return safeAreaBottom;
  }

  /// Get responsive padding value (horizontal/vertical base) as double
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    if (isDesktop(context)) return 32.0;
    return 40.0; // Large desktop/TV
  }
}
