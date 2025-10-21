import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtil.getResponsivePadding(context).horizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppSizes.iconXxl,
            color: AppColors.getTextSecondary(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(message, style: AppTextStyles.bodyMedium(isDark: isDark)),
        ],
      ),
    );
  }
}