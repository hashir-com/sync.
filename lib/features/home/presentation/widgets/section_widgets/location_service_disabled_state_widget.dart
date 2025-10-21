import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class LocationServiceDisabledState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEnableLocation;

  const LocationServiceDisabledState({
    super.key,
    required this.isDark,
    required this.onEnableLocation,
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
            color: AppColors.getWarning(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Location Service Disabled',
            style: AppTextStyles.titleMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Please turn on location services to discover events near you',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingXl),
          ElevatedButton.icon(
            onPressed: onEnableLocation,
            icon: Icon(Icons.location_on_rounded, size: AppSizes.iconSmall),
            label: const Text('Turn On Location'),
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