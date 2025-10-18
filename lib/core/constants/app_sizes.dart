import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  // Prevent instantiation
  AppSizes._();

  // Spacing & Padding
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

  // Border Radius
  static double get radiusXs => 4.r;
  static double get radiusSmall => 8.r;
  static double get radiusMedium => 12.r;
  static double get radiusLarge => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusXxl => 24.r;
  static double get radiusXxxl => 28.r;
  static double get radiusSemiRound => 70.r;
  static double get radiusRound => 100.r; // For circular elements

  // Button Sizes
  static double get buttonHeightSmall => 36.h;
  static double get buttonHeightMedium => 44.h;
  static double get buttonHeightLarge => 52.h;
  static double get buttonPaddingHorizontal => 24.w;
  static double get buttonPaddingVertical => 12.h;

  // Icon Sizes
  static double get iconXs => 16.sp;
  static double get iconSmall => 20.sp;
  static double get iconMedium => 24.sp;
  static double get iconLarge => 32.sp;
  static double get iconXl => 40.sp;
  static double get iconXxl => 48.sp;

  // Avatar Sizes
  static double get avatarSmall => 32.r;
  static double get avatarMedium => 40.r;
  static double get avatarLarge => 50.r;
  static double get avatarXl => 64.r;
  static double get avatarXxl => 80.r;

  // Card & Container
  static double get cardElevationLow => 2.0; // Elevation remains static
  static double get cardElevationMedium => 4.0;
  static double get cardElevationHigh => 8.0;
  static double get cardMarginHorizontal => 16.w;
  static double get cardMarginVertical => 8.h;
  static double get cardPadding => 16.w;

  // Input Fields
  static double get inputHeight => 56.h;
  static double get inputPaddingHorizontal => 16.w;
  static double get inputPaddingVertical => 16.h;
  static double get inputBorderWidth => 1.0; // Border width remains static
  static double get inputBorderWidthFocused => 2.0;

  // Typography Sizes
  static double get fontXs => 10.sp;
  static double get fontSmall => 12.sp;
  static double get fontMedium => 14.sp;
  static double get fontLarge => 16.sp;
  static double get fontXl => 18.sp;
  static double get fontXxl => 20.sp;
  static double get fontXxxl => 24.sp;

  // Display text sizes
  static double get fontDisplay1 => 32.sp;
  static double get fontDisplay2 => 28.sp;
  static double get fontDisplay3 => 24.sp;

  // Headline sizes
  static double get fontHeadline1 => 22.sp;
  static double get fontHeadline2 => 20.sp;
  static double get fontHeadline3 => 18.sp;

  // Letter Spacing
  static double get letterSpacingTight => -0.5;
  static double get letterSpacingNormal => 0.0;
  static double get letterSpacingWide => 0.15;
  static double get letterSpacingExtraWide => 0.25;
  static double get letterSpacingLabel => 0.5;

  // Divider & Border
  static double get dividerThickness => 1.0; // Remains static
  static double get borderWidthThin => 1.0;
  static double get borderWidthMedium => 1.5;
  static double get borderWidthThick => 2.0;

  // App Bar
  static double get appBarHeight => 56.h;
  static double get appBarElevation => 0.0; // Elevation remains static

  // Bottom Navigation
  static double get bottomNavHeight => 60.h;
  static double get bottomNavElevation => 8.0; // Elevation remains static
  static double get bottomNavIconSize => 24.sp;

  // Floating Action Button
  static double get fabSize => 56.r;
  static double get fabElevation => 4.0; // Elevation remains static
  static double get fabIconSize => 24.sp;

  // Dot Indicator (Onboarding/Carousel)
  static double get dotIndicatorActiveWidth => 14.w;
  static double get dotIndicatorInactiveWidth => 8.w;
  static double get dotIndicatorHeight => 8.h;
  static double get dotIndicatorSpacing => 6.w;

  // Chip
  static double get chipHeight => 32.h;
  static double get chipPaddingHorizontal => 12.w;
  static double get chipPaddingVertical => 8.h;

  // Dialog
  static double get dialogElevation => 8.0; // Elevation remains static
  static double get dialogPadding => 24.w;
  static double get dialogMaxWidth => 400.w;

  // Snackbar
  static double get snackbarElevation => 6.0; // Elevation remains static
  static double get snackbarPadding => 16.w;

  // List Items
  static double get listTileHeight => 56.h;
  static double get listTileVerticalPadding => 12.h;
  static double get listTileHorizontalPadding => 16.w;

  // Image Sizes
  static double get imageSmall => 80.w;
  static double get imageMedium => 120.w;
  static double get imageLarge => 200.w;
  static double get imageXl => 300.w;

  // Screen Padding
  static double get screenPaddingHorizontal => 16.w;
  static double get screenPaddingVertical => 16.h;
  static double get screenPaddingTop => 20.h;
  static double get screenPaddingBottom => 20.h;
}
