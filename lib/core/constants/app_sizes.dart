import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class AppSizes {
  // Prevent instantiation
  AppSizes._();

  // Responsive Breakpoints

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Responsive Spacing & Padding

  static double getSpacing(BuildContext context, {double baseSpacing = 16}) {
    return ResponsiveUtil.getSpacing(context, baseSpacing: baseSpacing);
  }

  static double getHeightSpacing(
    BuildContext context, {
    double baseSpacing = 16,
  }) {
    return ResponsiveUtil.getHeightSpacing(context, baseSpacing: baseSpacing);
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return ResponsiveUtil.getResponsivePadding(context);
  }

  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return ResponsiveUtil.getResponsiveHorizontalPadding(context);
  }

  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    return ResponsiveUtil.getResponsiveVerticalPadding(context);
  }

  static EdgeInsets getResponsiveScreenPadding(BuildContext context) {
    return ResponsiveUtil.getResponsiveScreenPadding(context);
  }

  // Legacy Spacing (for backward compatibility)

  static double get spacingXs => 4.w;
  static double get spacingSmall => 8.w;
  static double get spacingMedium => 12.w;
  static double get spacingLarge => 16.w;
  static double get spacingXl => 20.w;
  static double get spacingXxl => 24.w;
  static double get spacingXxxl => 32.w;
  static double get spacingMaxl => 82.w;

  static double get paddingXs => 4.w;
  static double get paddingSmall => 8.w;
  static double get paddingMedium => 12.w;
  static double get paddingLarge => 16.w;
  static double get paddingXl => 20.w;
  static double get paddingXxl => 24.w;
  static double get paddingXxxl => 32.w;

  // Responsive Border Radius

  static double getBorderRadius(
    BuildContext context, {
    double baseRadius = 12,
  }) {
    return ResponsiveUtil.getBorderRadius(context, baseRadius: baseRadius);
  }

  // Legacy border radius
  static double get radiusXs => 4.r;
  static double get radiusSmall => 8.r;
  static double get radiusMedium => 12.r;
  static double get radiusLarge => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusXxl => 24.r;
  static double get radiusXxxl => 28.r;
  static double get radiusSemiRound => 70.r;
  static double get radiusRound => 100.r;

  // Responsive Button Sizes

  static double getButtonHeight(BuildContext context) {
    return ResponsiveUtil.getButtonHeight(context);
  }

  static double getButtonPaddingHorizontal(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 24.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 32.w;
    } else {
      return 40.w;
    }
  }

  static double getButtonPaddingVertical(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 12.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 16.h;
    } else {
      return 20.h;
    }
  }

  // Legacy button sizes
  static double get buttonHeightSmall => 36.h;
  static double get buttonHeightMedium => 44.h;
  static double get buttonHeightLarge => 52.h;
  static double get buttonPaddingHorizontal => 24.w;
  static double get buttonPaddingVertical => 12.h;

  // Responsive Icon Sizes

  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    return ResponsiveUtil.getIconSize(context, baseSize: baseSize);
  }

  // Legacy icon sizes
  static double get iconXs => 16.sp;
  static double get iconSmall => 20.sp;
  static double get iconMedium => 24.sp;
  static double get iconLarge => 32.sp;
  static double get iconXl => 40.sp;
  static double get iconXxl => 48.sp;

  // Responsive Avatar Sizes

  static double getAvatarSize(BuildContext context, {double baseSize = 40}) {
    return ResponsiveUtil.getAvatarSize(context, baseSize: baseSize);
  }

  // Legacy avatar sizes
  static double get avatarSmall => 32.r;
  static double get avatarMedium => 40.r;
  static double get avatarLarge => 50.r;
  static double get avatarXl => 64.r;
  static double get avatarXxl => 80.r;

  // Responsive Card & Container

  static double getCardWidth(BuildContext context) {
    return ResponsiveUtil.getCardWidth(context);
  }

  static double getElevation(BuildContext context, {double baseElevation = 2}) {
    return ResponsiveUtil.getElevation(context, baseElevation: baseElevation);
  }

  static double getMaxContentWidth(BuildContext context) {
    return ResponsiveUtil.getMaxContentWidth(context);
  }

  // Legacy card properties
  static double get cardElevationLow => 2.0;
  static double get cardElevationMedium => 4.0;
  static double get cardElevationHigh => 8.0;
  static double get cardMarginHorizontal => 16.w;
  static double get cardMarginVertical => 8.h;
  static double get cardPadding => 16.w;

  // Responsive Input Fields

  static double getInputHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 48.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 52.h;
    } else {
      return 56.h;
    }
  }

  static double getInputPaddingHorizontal(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 16.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 20.w;
    } else {
      return 24.w;
    }
  }

  static double getInputPaddingVertical(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 16.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 18.h;
    } else {
      return 20.h;
    }
  }

  // Legacy input properties
  static double get inputHeight => 56.h;
  static double get inputPaddingHorizontal => 16.w;
  static double get inputPaddingVertical => 16.h;
  static double get inputBorderWidth => 1.0;
  static double get inputBorderWidthFocused => 2.0;

  // Responsive Typography Sizes

  static double getFontSize(BuildContext context, {double baseSize = 14}) {
    final multiplier = ResponsiveUtil.getFontSizeMultiplier(context);
    return (baseSize * multiplier).sp;
  }

  // Legacy font sizes
  static double get fontXs => 10.sp;
  static double get fontSmall => 12.sp;
  static double get fontMedium => 14.sp;
  static double get fontLarge => 16.sp;
  static double get fontXl => 18.sp;
  static double get fontXxxl => 24.sp;

  // Display text sizes
  static double get fontDisplay1 => 32.sp;
  static double get fontDisplay2 => 28.sp;
  static double get fontDisplay3 => 24.sp;

  // Headline sizes
  static double get fontHeadline1 => 22.sp;
  static double get fontHeadline2 => 20.sp;
  static double get fontHeadline3 => 18.sp;

  // Responsive Layout Properties

  static int getGridCrossAxisCount(BuildContext context) {
    return ResponsiveUtil.getGridCrossAxisCount(context);
  }

  static int getColumnCount(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return ResponsiveUtil.getColumnCount(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );
  }

  static double getAspectRatio(
    BuildContext context, {
    double mobileRatio = 16 / 9,
    double tabletRatio = 16 / 10,
    double desktopRatio = 16 / 9,
  }) {
    return ResponsiveUtil.getAspectRatio(
      context,
      mobileRatio: mobileRatio,
      tabletRatio: tabletRatio,
      desktopRatio: desktopRatio,
    );
  }

  // Responsive Dialog & Modal

  static double getDialogWidth(BuildContext context) {
    return ResponsiveUtil.getDialogWidth(context);
  }

  static double getDialogPadding(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 16.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 24.w;
    } else {
      return 32.w;
    }
  }

  // Legacy dialog properties
  static double get dialogElevation => 8.0;
  static double get dialogPadding => 24.w;
  static double get dialogMaxWidth => 400.w;

  // Responsive App Bar

  static double getAppBarHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 56.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 64.h;
    } else {
      return 72.h;
    }
  }

  // Legacy app bar
  static double get appBarHeight => 56.h;
  static double get appBarElevation => 0.0;

  // Responsive Bottom Navigation

  static double getBottomNavHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 60.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 70.h;
    } else {
      return 80.h;
    }
  }

  static double getBottomNavIconSize(BuildContext context) {
    return ResponsiveUtil.getIconSize(context, baseSize: 24);
  }

  // Legacy bottom nav
  static double get bottomNavHeight => 60.h;
  static double get bottomNavElevation => 8.0;
  static double get bottomNavIconSize => 24.sp;

  // Responsive Floating Action Button

  static double getFabSize(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 56.r;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 64.r;
    } else {
      return 72.r;
    }
  }

  static double getFabIconSize(BuildContext context) {
    return ResponsiveUtil.getIconSize(context, baseSize: 24);
  }

  // Legacy FAB
  static double get fabSize => 56.r;
  static double get fabElevation => 4.0;
  static double get fabIconSize => 24.sp;

  // Responsive List Items

  static double getListTileHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 56.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 64.h;
    } else {
      return 72.h;
    }
  }

  static double getListTilePadding(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 16.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 20.w;
    } else {
      return 24.w;
    }
  }

  // Legacy list tile
  static double get listTileHeight => 56.h;
  static double get listTileVerticalPadding => 12.h;
  static double get listTileHorizontalPadding => 16.w;

  // Responsive Image Sizes

  static double getImageSize(
    BuildContext context, {
    double mobileSize = 80,
    double tabletSize = 120,
    double desktopSize = 160,
  }) {
    if (ResponsiveUtil.isMobile(context)) {
      return mobileSize.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return tabletSize.w;
    } else {
      return desktopSize.w;
    }
  }

  // Legacy image sizes
  static double get imageSmall => 80.w;
  static double get imageMedium => 120.w;
  static double get imageLarge => 200.w;
  static double get imageXl => 300.w;

  // Responsive Screen Padding

  static EdgeInsets getScreenPadding(BuildContext context) {
    return ResponsiveUtil.getResponsiveScreenPadding(context);
  }

  // Legacy screen padding
  static double get screenPaddingHorizontal => 16.w;
  static double get screenPaddingVertical => 16.h;
  static double get screenPaddingTop => 20.h;
  static double get screenPaddingBottom => 20.h;

  // Responsive Chip

  static double getChipHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 32.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 36.h;
    } else {
      return 40.h;
    }
  }

  static double getChipPadding(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 12.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 16.w;
    } else {
      return 20.w;
    }
  }

  // Legacy chip
  static double get chipHeight => 32.h;
  static double get chipPaddingHorizontal => 12.w;
  static double get chipPaddingVertical => 8.h;

  // Responsive Dot Indicator

  static double getDotIndicatorWidth(
    BuildContext context, {
    bool isActive = true,
  }) {
    final baseWidth = isActive ? 14 : 8;
    if (ResponsiveUtil.isMobile(context)) {
      return baseWidth.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return (baseWidth * 1.2).w;
    } else {
      return (baseWidth * 1.4).w;
    }
  }

  static double getDotIndicatorHeight(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 8.h;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 10.h;
    } else {
      return 12.h;
    }
  }

  // Legacy dot indicator
  static double get dotIndicatorActiveWidth => 14.w;
  static double get dotIndicatorInactiveWidth => 8.w;
  static double get dotIndicatorHeight => 8.h;
  static double get dotIndicatorSpacing => 6.w;

  // Responsive Snackbar

  static double getSnackbarPadding(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 16.w;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 24.w;
    } else {
      return 32.w;
    }
  }

  // Legacy snackbar
  static double get snackbarElevation => 6.0;
  static double get snackbarPadding => 16.w;

  // Responsive Divider & Border

  static double getDividerThickness(BuildContext context) {
    if (ResponsiveUtil.isMobile(context)) {
      return 1.0;
    } else if (ResponsiveUtil.isTablet(context)) {
      return 1.2;
    } else {
      return 1.5;
    }
  }

  // Legacy divider
  static double get dividerThickness => 1.0;
  static double get borderWidthThin => 1.0;
  static double get borderWidthMedium => 1.5;
  static double get borderWidthThick => 2.0;

  // Responsive Letter Spacing

  static double get letterSpacingTight => -0.5;
  static double get letterSpacingNormal => 0.0;
  static double get letterSpacingWide => 0.15;
  static double get letterSpacingExtraWide => 0.25;
  static double get letterSpacingLabel => 0.5;
}
