import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/theme_util.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Card(
      color: AppColors.getCard(isDark),
      elevation: AppSizes.cardElevationLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r)),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}