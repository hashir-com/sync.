import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class LocationDeniedState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const LocationDeniedState({
    super.key,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveUtil.getResponsiveHorizontalPadding(context),
      padding: EdgeInsets.all(ResponsiveUtil.getResponsivePadding(context).horizontal),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: AppSizes.iconXxl,
            color: AppColors.getError(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Location Permission Denied',
            style: AppTextStyles.titleMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Grant location permission in settings to find nearby events',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingXl),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.settings_rounded, size: AppSizes.iconSmall),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXxl,
                vertical: AppSizes.paddingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}