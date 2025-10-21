// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';

class FilterCard extends ConsumerWidget {
  final String userId;
  final BookingsFilterState filterState;

  const FilterCard({super.key, required this.userId, required this.filterState});

  Future<void> _showDateRangePicker(BuildContext context, WidgetRef ref, DateTimeRange? currentRange, bool isDark) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: currentRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.getPrimary(isDark),
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(bookingsFilterProvider.notifier).setDateFilter(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Card(
      color: AppColors.getCard(isDark),
      elevation: AppSizes.cardElevationLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r)),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Bookings', style: AppTextStyles.titleMedium(isDark: isDark)),
                if (filterState.hasActiveFilters)
                  TextButton(
                    onPressed: () => ref.read(bookingsFilterProvider.notifier).clearFilters(),
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.bodySmall(isDark: isDark).copyWith(color: AppColors.getPrimary(isDark)),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSizes.spacingSmall.h),
            TextField(
              onChanged: (value) => ref.read(bookingsFilterProvider.notifier).setSearchQuery(value),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: AppSizes.getIconSize(context, baseSize: AppSizes.iconMedium), color: AppColors.getTextSecondary(isDark)),
                hintText: 'Search by ID, type, or payment ID',
                hintStyle: AppTextStyles.bodySmall(isDark: isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                  borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                  borderSide: BorderSide(color: AppColors.getPrimary(isDark), width: AppSizes.borderWidthThick),
                ),
                filled: true,
                fillColor: AppColors.getSurface(isDark).withOpacity(0.5),
              ),
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filterState.statusFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                    ],
                    onChanged: (value) => ref.read(bookingsFilterProvider.notifier).setStatusFilter(value ?? 'all'),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: AppTextStyles.bodySmall(isDark: isDark),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                        borderSide: BorderSide(color: AppColors.getPrimary(isDark), width: AppSizes.borderWidthThick),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurface(isDark).withOpacity(0.5),
                    ),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ),
                SizedBox(width: AppSizes.spacingMedium.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDateRangePicker(context, ref, filterState.dateFilter, isDark),
                    icon: Icon(Icons.date_range, size: AppSizes.getIconSize(context, baseSize: AppSizes.iconSmall), color: AppColors.getTextSecondary(isDark)),
                    label: Text(
                      filterState.dateFilter == null
                          ? 'Filter by Date'
                          : '${DateFormat('MMM d').format(filterState.dateFilter!.start)} - ${DateFormat('MMM d').format(filterState.dateFilter!.end)}',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: Theme.of(context).outlinedButtonTheme.style,
                  ),
                ),
                if (filterState.dateFilter != null)
                  IconButton(
                    tooltip: 'Clear date filter',
                    onPressed: () => ref.read(bookingsFilterProvider.notifier).clearDateFilter(),
                    icon: Icon(Icons.clear, size: AppSizes.getIconSize(context, baseSize: AppSizes.iconSmall), color: AppColors.getTextSecondary(isDark)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}