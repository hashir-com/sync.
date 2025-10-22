import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/util/responsive_helper.dart';

/// Responsive utility class for handling different screen sizes and platforms
/// This class now delegates to ResponsiveHelper for comprehensive breakpoint support
class ResponsiveUtil {
  // Prevent instantiation
  ResponsiveUtil._();

  // Legacy breakpoints (deprecated - use ResponsiveHelper instead)
  @Deprecated('Use ResponsiveHelper.isMobile() instead')
  static const double mobileBreakpoint = 600;
  @Deprecated('Use ResponsiveHelper.isTablet() instead')
  static const double tabletBreakpoint = 900;
  @Deprecated('Use ResponsiveHelper.isDesktop() instead')
  static const double desktopBreakpoint = 1200;
  @Deprecated('Use ResponsiveHelper.isLargeDesktop() instead')
  static const double largeDesktopBreakpoint = 1600;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return ResponsiveHelper.isMobile(context);
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return ResponsiveHelper.isTablet(context);
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return ResponsiveHelper.isDesktop(context);
  }

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return ResponsiveHelper.isLargeDesktop(context);
  }

  /// Get responsive AppBar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return 56.h; // Standard mobile AppBar height
    } else if (isTablet(context)) {
      return 64.h; // Slightly larger for tablets
    } else {
      return 72.h; // Larger for desktop
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.all(16.w);
    } else if (isTablet(context)) {
      return EdgeInsets.all(24.w);
    } else {
      return EdgeInsets.all(32.w);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: 16.w);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 24.w);
    } else {
      return EdgeInsets.symmetric(horizontal: 32.w);
    }
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(vertical: 16.h);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(vertical: 20.h);
    } else {
      return EdgeInsets.symmetric(vertical: 24.h);
    }
  }

  /// Get responsive screen padding with safe area
  static EdgeInsets getResponsiveScreenPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = isMobile(context) ? 16.w : 
                            isTablet(context) ? 24.w : 32.w;
    final verticalPadding = isMobile(context) ? 16.h : 
                           isTablet(context) ? 20.h : 24.h;
    
    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      top: verticalPadding + mediaQuery.padding.top,
      bottom: verticalPadding + mediaQuery.padding.bottom,
    );
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive spacing multiplier
  static double getSpacingMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.2;
    } else {
      return 1.5;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - 32.w; // Full width minus padding
    } else if (isTablet(context)) {
      return (screenWidth - 48.w) / 2; // Half width for tablet
    } else {
      return (screenWidth - 64.w) / 3; // Third width for desktop
    }
  }

  /// Get responsive grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800.w;
    } else {
      return 1200.w;
    }
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.6;
    } else {
      return 400.w;
    }
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.h;
    } else if (isTablet(context)) {
      return 52.h;
    } else {
      return 56.h;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    if (isMobile(context)) {
      return baseSize.sp;
    } else if (isTablet(context)) {
      return (baseSize * 1.1).sp;
    } else {
      return (baseSize * 1.2).sp;
    }
  }

  /// Get responsive avatar size
  static double getAvatarSize(BuildContext context, {double baseSize = 40}) {
    if (isMobile(context)) {
      return baseSize.r;
    } else if (isTablet(context)) {
      return (baseSize * 1.1).r;
    } else {
      return (baseSize * 1.2).r;
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, {double baseRadius = 12}) {
    if (isMobile(context)) {
      return baseRadius.r;
    } else if (isTablet(context)) {
      return (baseRadius * 1.1).r;
    } else {
      return (baseRadius * 1.2).r;
    }
  }

  /// Get responsive elevation
  static double getElevation(BuildContext context, {double baseElevation = 2}) {
    if (isMobile(context)) {
      return baseElevation;
    } else if (isTablet(context)) {
      return baseElevation * 1.2;
    } else {
      return baseElevation * 1.5;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {double baseSpacing = 16}) {
    final multiplier = getSpacingMultiplier(context);
    return (baseSpacing * multiplier).w;
  }

  /// Get responsive height spacing
  static double getHeightSpacing(BuildContext context, {double baseSpacing = 16}) {
    final multiplier = getSpacingMultiplier(context);
    return (baseSpacing * multiplier).h;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive column count for different content types
  static int getColumnCount(BuildContext context, {int mobileColumns = 1, int tabletColumns = 2, int desktopColumns = 3}) {
    if (isMobile(context)) {
      return mobileColumns;
    } else if (isTablet(context)) {
      return tabletColumns;
    } else {
      return desktopColumns;
    }
  }

  /// Get responsive aspect ratio
  static double getAspectRatio(BuildContext context, {double mobileRatio = 16/9, double tabletRatio = 16/10, double desktopRatio = 16/9}) {
    if (isMobile(context)) {
      return mobileRatio;
    } else if (isTablet(context)) {
      return tabletRatio;
    } else {
      return desktopRatio;
    }
  }

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    // Limit text scale factor for better readability
    if (textScaleFactor > 1.3) {
      return 1.3;
    } else if (textScaleFactor < 0.8) {
      return 0.8;
    }
    
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
    
    if (keyboardHeight > 0) {
      return keyboardHeight + safeAreaBottom;
    }
    
    return safeAreaBottom;
  }
}