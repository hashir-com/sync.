import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';

class NoResultsView extends ConsumerWidget {
  final BookingsFilterState filterState;

  const NoResultsView({super.key, required this.filterState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Center(
      child: Padding(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: AppSizes.getIconSize(context, baseSize: AppSizes.iconLarge),
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: AppSizes.getHeightSpacing(context, baseSpacing: AppSizes.spacingSmall)),
            Text(
              'No bookings match your filters',
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            if (filterState.hasActiveFilters) ...[
              SizedBox(height: AppSizes.getHeightSpacing(context, baseSpacing: AppSizes.spacingSmall)),
              TextButton(
                onPressed: () => ref.read(bookingsFilterProvider.notifier).clearFilters(),
                child: Text(
                  'Clear Filters',
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(color: AppColors.getPrimary(isDark)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}