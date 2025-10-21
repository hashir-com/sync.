import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';

class NotAuthenticatedView extends ConsumerWidget {
  const NotAuthenticatedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Center(
      child: Padding(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: AppSizes.getIconSize(context, baseSize: AppSizes.iconXxl),
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: AppSizes.getHeightSpacing(context, baseSpacing: AppSizes.spacingMedium)),
            Text(
              'Please Log In',
              style: AppTextStyles.headingSmall(isDark: isDark),
            ),
            SizedBox(height: AppSizes.getHeightSpacing(context, baseSpacing: AppSizes.spacingSmall)),
            Text(
              'You need to be logged in to view your bookings',
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.getHeightSpacing(context, baseSpacing: AppSizes.spacingLarge)),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}