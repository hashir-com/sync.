import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_form_provider.dart';
import 'package:sync_event/features/bookings/presentation/screens/booking_screen.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingTicketSelectionCard extends ConsumerWidget {
  final EventEntity event;
  final bool isDark;

  const BookingTicketSelectionCard({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);
    final event = this.event;

    final validCategories = event.categoryPrices.entries
        .where(
          (entry) =>
              entry.value > 0 && event.categoryCapacities[entry.key]! > 0,
        )
        .map((entry) => entry.key)
        .toList();

    final selectedCategory =
        validCategories.contains(formState.selectedCategory)
        ? formState.selectedCategory
        : (validCategories.isNotEmpty ? validCategories.first : '');

    if (selectedCategory.isEmpty && validCategories.isNotEmpty) {
      Future.microtask(() => formNotifier.setCategory(validCategories.first));
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge.w),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Tickets',
            style: AppTextStyles.headingSmall(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          _buildCategoryDropdown(
            validCategories,
            selectedCategory,
            formNotifier,
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          _buildQuantitySelector(
            formState,
            formNotifier,
            event,
            selectedCategory,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.getSurface(isDark),
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
      border: Border.all(
        color: AppColors.getPrimary(isDark).withOpacity(0.15),
        width: 1.w,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.getPrimary(isDark).withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
    List<String> categories,
    String selectedCategory, // Use formState.selectedCategory directly
    BookingFormNotifier notifier,
  ) {
    if (categories.isEmpty) {
      return Text(
        'No tickets available',
        style: AppTextStyles.bodyMedium(isDark: isDark),
      );
    }

    return DropdownButtonFormField<String>(
      value: categories.contains(selectedCategory)
          ? selectedCategory
          : null, // Key fix!
      decoration: InputDecoration(
        // ... your decoration
      ),
      items: categories.map((category) {
        final price = event.categoryPrices[category] ?? 0.0; // Safe access
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.getPrimary(isDark),
                ),
              ),
              SizedBox(width: AppSizes.spacingSmall.w),
              Text(
                '${category.toUpperCase()} - ₹${price.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          notifier.setCategory(value);
        }
      },
    );
  }

  Widget _buildQuantitySelector(
    BookingFormState formState,
    BookingFormNotifier notifier,
    EventEntity event,
    String selectedCategory,
  ) {
    final maxCapacity = event.categoryCapacities[selectedCategory] ?? 1;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.getBackground(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuantityLabel(),
          _buildQuantityControls(formState, notifier, maxCapacity),
        ],
      ),
    );
  }

  Widget _buildQuantityLabel() {
    return Row(
      children: [
        Icon(
          Icons.person_add_alt_1_rounded,
          color: AppColors.getPrimary(isDark),
          size: AppSizes.iconMedium.sp,
        ),
        SizedBox(width: AppSizes.spacingMedium.w),
        Text(
          'Quantity',
          style: AppTextStyles.bodyMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(
    BookingFormState formState,
    BookingFormNotifier notifier,
    int maxCapacity,
  ) {
    return Row(
      children: [
        _buildControlButton(
          icon: Icons.remove_rounded,
          onPressed: formState.quantity > 1
              ? () => notifier.setQuantity(formState.quantity - 1)
              : null,
        ),
        SizedBox(width: AppSizes.spacingSmall.w),
        _buildQuantityDisplay(formState.quantity),
        SizedBox(width: AppSizes.spacingSmall.w),
        _buildControlButton(
          icon: Icons.add_rounded,
          onPressed: formState.quantity < maxCapacity
              ? () => notifier.setQuantity(formState.quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.getPrimary(isDark)),
        onPressed: onPressed,
        iconSize: AppSizes.iconMedium.sp,
        constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
      ),
    );
  }

  Widget _buildQuantityDisplay(int quantity) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium.w,
        vertical: AppSizes.paddingSmall.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Text(
        '$quantity',
        style: AppTextStyles.bodyLarge(
          isDark: isDark,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
