import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingEventDetailsCard extends StatelessWidget {
  final EventEntity event;
  final bool isDark;

  const BookingEventDetailsCard({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge.w),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: AppTextStyles.headingSmall(isDark: isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSizes.spacingLarge.h),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: DateFormat('EEEE, MMMM d, y').format(event.startTime),
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value:
                '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.spacingMedium.h),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: event.location,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingSmall.w),
          decoration: BoxDecoration(
            color: AppColors.getPrimary(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconMedium.sp,
            color: AppColors.getPrimary(isDark),
          ),
        ),
        SizedBox(width: AppSizes.spacingMedium.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondary(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSizes.spacingXs.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium(isDark: isDark)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}