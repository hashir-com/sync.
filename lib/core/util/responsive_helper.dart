import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Comprehensive responsive helper class for handling all screen sizes
/// from mobile (320px) to ultra-wide monitors (4K+)
class ResponsiveHelper {
  // Prevent instantiation
  ResponsiveHelper._();

  // Comprehensive Breakpoints
  static const double mobileSmallBreakpoint = 360;    // iPhone SE, compact phones
  static const double mobileStandardBreakpoint = 600; // Most phones
  static const double tabletPortraitBreakpoint = 840; // Tablet portrait
  static const double tabletLandscapeBreakpoint = 1200; // Tablet landscape / Small desktop
  static const double desktopBreakpoint = 1600;       // Desktop / Large tablet
  static const double largeDesktopBreakpoint = 2560;  // Large desktop
  // Ultra-wide / 4K: > 2560dp

  /// Check if current screen is mobile small (< 360dp)
  static bool isMobileSmall(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileSmallBreakpoint;
  }

  /// Check if current screen is mobile standard (360dp - 600dp)
  static bool isMobileStandard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileSmallBreakpoint && width < mobileStandardBreakpoint;
  }

  /// Check if current screen is mobile (any mobile size < 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileStandardBreakpoint;
  }

  /// Check if current screen is tablet portrait (600dp - 840dp)
  static bool isTabletPortrait(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileStandardBreakpoint && width < tabletPortraitBreakpoint;
  }

  /// Check if current screen is tablet landscape (840dp - 1200dp)
  static bool isTabletLandscape(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletPortraitBreakpoint && width < tabletLandscapeBreakpoint;
  }

  /// Check if current screen is tablet (any tablet size 600dp - 1200dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileStandardBreakpoint && width < tabletLandscapeBreakpoint;
  }

  /// Check if current screen is desktop (1200dp - 1600dp)
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletLandscapeBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is large desktop (1600dp - 2560dp)
  static bool isLargeDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint && width < largeDesktopBreakpoint;
  }

  /// Check if current screen is ultra-wide / 4K (> 2560dp)
  static bool isUltraWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen orientation
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Get responsive value based on screen size
  static double getResponsiveValue(
    BuildContext context, {
    required double mobileSmall,
    required double mobileStandard,
    required double tabletPortrait,
    required double tabletLandscape,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
  }) {
    if (isUltraWide(context)) return ultraWide;
    if (isLargeDesktop(context)) return largeDesktop;
    if (isDesktop(context)) return desktop;
    if (isTabletLandscape(context)) return tabletLandscape;
    if (isTabletPortrait(context)) return tabletPortrait;
    if (isMobileStandard(context)) return mobileStandard;
    return mobileSmall;
  }

  /// Get responsive value with simplified breakpoints
  static double getResponsiveValueSimple(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isDesktop(context) || isLargeDesktop(context) || isUltraWide(context)) {
      return desktop;
    }
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(getResponsiveValueSimple(
      context,
      mobile: 16.w,
      tablet: 24.w,
      desktop: 32.w,
    ));
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final padding = getResponsiveValueSimple(
      context,
      mobile: 16.w,
      tablet: 24.w,
      desktop: 32.w,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    final padding = getResponsiveValueSimple(
      context,
      mobile: 16.h,
      tablet: 20.h,
      desktop: 24.h,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get responsive screen padding with safe area
  static EdgeInsets getResponsiveScreenPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = getResponsiveValueSimple(
      context,
      mobile: 16.w,
      tablet: 24.w,
      desktop: 32.w,
    );
    final verticalPadding = getResponsiveValueSimple(
      context,
      mobile: 16.h,
      tablet: 20.h,
      desktop: 24.h,
    );
    
    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      top: verticalPadding + mediaQuery.padding.top,
      bottom: verticalPadding + mediaQuery.padding.bottom,
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final baseSize = getResponsiveValueSimple(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    
    // Apply text scale factor with limits
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final limitedScaleFactor = textScaleFactor.clamp(0.8, 1.3);
    
    return (baseSize * limitedScaleFactor).sp;
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    return getResponsiveValueSimple(
      context,
      mobile: mobile.w,
      tablet: tablet.w,
      desktop: desktop.w,
    );
  }

  /// Get responsive height spacing
  static double getResponsiveHeightSpacing(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    return getResponsiveValueSimple(
      context,
      mobile: mobile.h,
      tablet: tablet.h,
      desktop: desktop.h,
    );
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(
    BuildContext context, {
    int mobileSmall = 1,
    int mobileStandard = 1,
    int tabletPortrait = 2,
    int tabletLandscape = 3,
    int desktop = 4,
    int largeDesktop = 5,
    int ultraWide = 6,
  }) {
    return getResponsiveValue(
      context,
      mobileSmall: mobileSmall,
      mobileStandard: mobileStandard,
      tabletPortrait: tabletPortrait,
      tabletLandscape: tabletLandscape,
      desktop: desktop,
      largeDesktop: largeDesktop,
      ultraWide: ultraWide,
    ).round();
  }

  /// Get responsive max content width
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: double.infinity,
      tablet: 800.w,
      desktop: 1200.w,
    );
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValueSimple(
      context,
      mobile: screenWidth * 0.9,
      tablet: screenWidth * 0.6,
      desktop: 400.w,
    );
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 48.h,
      tablet: 52.h,
      desktop: 56.h,
    );
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    final multiplier = getResponsiveValueSimple(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return (baseSize * multiplier).sp;
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context, {double baseSize = 40}) {
    final multiplier = getResponsiveValueSimple(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return (baseSize * multiplier).r;
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, {double baseRadius = 12}) {
    final multiplier = getResponsiveValueSimple(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return (baseRadius * multiplier).r;
  }

  /// Get responsive elevation
  static double getElevation(BuildContext context, {double baseElevation = 2}) {
    return getResponsiveValueSimple(
      context,
      mobile: baseElevation,
      tablet: baseElevation * 1.2,
      desktop: baseElevation * 1.5,
    );
  }

  /// Get responsive aspect ratio
  static double getAspectRatio(
    BuildContext context, {
    double mobileRatio = 16/9,
    double tabletRatio = 16/10,
    double desktopRatio = 16/9,
  }) {
    return getResponsiveValueSimple(
      context,
      mobile: mobileRatio,
      tablet: tabletRatio,
      desktop: desktopRatio,
    );
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive text scale factor (limited)
  static double getTextScaleFactor(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor.clamp(0.8, 1.3);
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get keyboard height
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
    
    if (keyboardHeight > 0) {
      return keyboardHeight + safeAreaBottom;
    }
    
    return safeAreaBottom;
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 56.h,
      tablet: 64.h,
      desktop: 72.h,
    );
  }

  /// Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 60.h,
      tablet: 70.h,
      desktop: 80.h,
    );
  }

  /// Get responsive floating action button size
  static double getFabSize(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 56.r,
      tablet: 64.r,
      desktop: 72.r,
    );
  }

  /// Get responsive list tile height
  static double getListTileHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 56.h,
      tablet: 64.h,
      desktop: 72.h,
    );
  }

  /// Get responsive input field height
  static double getInputHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 48.h,
      tablet: 52.h,
      desktop: 56.h,
    );
  }

  /// Get responsive chip height
  static double getChipHeight(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 32.h,
      tablet: 36.h,
      desktop: 40.h,
    );
  }

  /// Get responsive image size
  static double getImageSize(
    BuildContext context, {
    double mobileSize = 80,
    double tabletSize = 120,
    double desktopSize = 160,
  }) {
    return getResponsiveValueSimple(
      context,
      mobile: mobileSize.w,
      tablet: tabletSize.w,
      desktop: desktopSize.w,
    );
  }

  /// Get responsive divider thickness
  static double getDividerThickness(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.5,
    );
  }

  /// Get responsive snackbar padding
  static double getSnackbarPadding(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 16.w,
      tablet: 24.w,
      desktop: 32.w,
    );
  }

  /// Get responsive dialog padding
  static double getDialogPadding(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 16.w,
      tablet: 24.w,
      desktop: 32.w,
    );
  }

  /// Get responsive column count for different content types
  static int getColumnCount(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return getResponsiveValueSimple(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    ).round();
  }

  /// Get responsive touch target size (minimum 48x48)
  static double getTouchTargetSize(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      mobile: 48.h,
      tablet: 52.h,
      desktop: 56.h,
    );
  }

  /// Get responsive navigation type
  static NavigationType getNavigationType(BuildContext context) {
    if (isMobile(context)) {
      return NavigationType.drawer;
    } else if (isTablet(context)) {
      return NavigationType.rail;
    } else {
      return NavigationType.sidebar;
    }
  }

  /// Get responsive layout type
  static LayoutType getLayoutType(BuildContext context) {
    if (isMobile(context)) {
      return LayoutType.mobile;
    } else if (isTablet(context)) {
      return LayoutType.tablet;
    } else {
      return LayoutType.desktop;
    }
  }
}

/// Navigation types for responsive design
enum NavigationType {
  drawer,   // Mobile: < 600dp
  rail,     // Tablet: 600dp - 1200dp
  sidebar,  // Desktop: > 1200dp
}

/// Layout types for responsive design
enum LayoutType {
  mobile,   // < 600dp
  tablet,   // 600dp - 1200dp
  desktop,  // > 1200dp
}