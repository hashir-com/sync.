// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for share event tile
class ShareTile extends StatelessWidget {
  final bool isDark;

  const ShareTile({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Build share tile with icon and text
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Center(
                  child: Icon(
                    Icons.share_rounded,
                    color: AppColors.getPrimary(isDark),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Share with your friends',
                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          GestureDetector(
            child: Text(
              'Share',
              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                color: AppColors.getPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}