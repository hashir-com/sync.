// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_form_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingPriceSummaryCard extends ConsumerWidget {
  final EventEntity event;
  final bool isDark;

  const BookingPriceSummaryCard({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(bookingFormProvider);
    final validCategories = event.categoryPrices.entries
        .where(
          (entry) =>
              entry.value > 0 && event.categoryCapacities[entry.key]! > 0,
        )
        .map((entry) => entry.key)
        .toList();

    final selectedCategory = validCategories.contains(formState.selectedCategory)
        ? formState.selectedCategory
        : (validCategories.isNotEmpty ? validCategories.first : '');

    final pricePerTicket = event.categoryPrices[selectedCategory] ?? 0.0;
    final totalAmount = pricePerTicket * formState.quantity;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark).withOpacity(0.08),
            AppColors.getPrimary(isDark).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: AppTextStyles.headingSmall(isDark: isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          _PriceRow(
            label: 'Price per ticket',
            value: '₹${pricePerTicket.toStringAsFixed(0)}',
            isDark: isDark,
            isSubtitle: true,
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          _PriceRow(
            label: 'Quantity',
            value: '${formState.quantity}x',
            isDark: isDark,
            isSubtitle: true,
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          Divider(
            color: AppColors.getPrimary(isDark).withOpacity(0.2),
            thickness: 1.h,
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          _PriceRow(
            label: 'Total Amount',
            value: '₹${totalAmount.toStringAsFixed(0)}',
            isDark: isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isSubtitle;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isSubtitle = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyLarge(isDark: isDark)
                  .copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.headingSmall(isDark: isDark).copyWith(
                  color: AppColors.getPrimary(isDark),
                  fontWeight: FontWeight.w800,
                )
              : AppTextStyles.bodyMedium(isDark: isDark)
                  .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}