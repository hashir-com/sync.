import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';

class EmptyState extends ConsumerWidget {
  const EmptyState({super.key});

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
              Icons.event_busy,
              size: AppSizes.getIconSize(context, baseSize: AppSizes.iconXxl),
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(
              height: AppSizes.getHeightSpacing(
                context,
                baseSpacing: AppSizes.spacingMedium,
              ),
            ),
            Text(
              'No Bookings Yet',
              style: AppTextStyles.headingSmall(isDark: isDark),
            ),
            SizedBox(
              height: AppSizes.getHeightSpacing(
                context,
                baseSpacing: AppSizes.spacingSmall,
              ),
            ),
            Text(
              'Book your first event now!',
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: AppSizes.getHeightSpacing(
                context,
                baseSpacing: AppSizes.spacingLarge,
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go('/root'),
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text('Browse Events'),
            ),
          ],
        ),
      ),
    );
  }
}
