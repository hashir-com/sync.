import 'package:flutter/material.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    return Card(
      color: AppColors.getCard(isDark),
      elevation: AppSizes.cardElevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Text(
          'Error loading event details',
          style: AppTextStyles.bodyMedium(isDark: isDark),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
