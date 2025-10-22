// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);
    final isConfirmed = status == 'confirmed';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall.w,
        vertical: AppSizes.paddingXs.h,
      ),
      decoration: BoxDecoration(
        color: isConfirmed
            ? AppColors.getSuccess(isDark).withOpacity(0.15)
            : AppColors.getError(isDark).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
          color: isConfirmed ? AppColors.getSuccess(isDark) : AppColors.getError(isDark),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}