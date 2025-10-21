// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for detail tiles (date, time, location)
class DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DetailTile({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    // Build detail tile with icon and text
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r)),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r)),
            child: Center(child: Icon(icon, color: AppColors.primary, size: 20.sp)),
          ),
          SizedBox(width: AppSizes.spacingSmall.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium(isDark: false)),
                SizedBox(height: 4.h),
                Text(subtitle, style: AppTextStyles.bodySmall(isDark: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}