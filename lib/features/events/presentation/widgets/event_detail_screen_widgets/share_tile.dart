// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for share event tile
class ShareTile extends StatelessWidget {
  const ShareTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Build share tile with icon and text
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.share_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spacingSmall.w),
              Text(
                'Share with your friends',
                style: AppTextStyles.bodyMedium(isDark: false),
              ),
            ],
          ),
          Text('share', style: AppTextStyles.bodySmall(isDark: false)),
        ],
      ),
    );
  }
}
