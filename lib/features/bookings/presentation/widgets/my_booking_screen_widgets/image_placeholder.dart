import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/theme_util.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Container(
      width: AppSizes.getImageSize(context, mobileSize: 80, tabletSize: 100, desktopSize: 120),
      height: AppSizes.getImageSize(context, mobileSize: 80, tabletSize: 100, desktopSize: 120),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Icon(
        Icons.event,
        size: AppSizes.getIconSize(context, baseSize: AppSizes.iconLarge),
        color: AppColors.getTextSecondary(isDark),
      ),
    );
  }
}