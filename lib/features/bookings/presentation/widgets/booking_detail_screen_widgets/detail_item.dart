import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for individual detail items in detail cards
class DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const DetailItem({super.key, required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Build detail item with icon and text
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: AppColors.getPrimary(isDark)),
        SizedBox(width: AppSizes.spacingMedium.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall(isDark: isDark).copyWith(color: AppColors.getTextSecondary(isDark))),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}