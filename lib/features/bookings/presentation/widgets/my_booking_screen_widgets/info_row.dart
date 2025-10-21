import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.getIconSize(context, baseSize: AppSizes.iconSmall),
          color: AppColors.getTextSecondary(isDark),
        ),
        SizedBox(width: AppSizes.spacingSmall.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall(isDark: isDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}