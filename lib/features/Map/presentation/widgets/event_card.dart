// File: features/map/presentation/widgets/event_card.dart
// Purpose: Display event details when a marker is tapped
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class EventDetailCard extends ConsumerWidget {
  final EventEntity event;

  const EventDetailCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    print('EventDetailCard: Building for ${event.title}, id=${event.id}');
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getCard(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(isDark),
                blurRadius: AppSizes.cardElevationMedium * 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.cardPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark, ref),
                SizedBox(height: AppSizes.spacingMedium.h),
                _buildDescription(isDark),
                SizedBox(height: AppSizes.spacingMedium.h),
                _buildFooter(isDark, context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BuildHeader: Display event image, title, and close button
  Widget _buildHeader(bool isDark, WidgetRef ref) {
    return Row(
      children: [
        Hero(
          tag: event.id,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadow(isDark),
                  blurRadius: AppSizes.cardElevationLow * 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
              child: Image.network(
                event.imageUrl ?? 'https://via.placeholder.com/80',
                width: AppSizes.imageSmall.w,
                height: AppSizes.imageSmall.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.event_rounded,
                  size: AppSizes.imageSmall.sp,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spacingXxl.w),
        Expanded(child: _buildEventTitle(isDark)),
        _buildCloseButton(isDark, ref),
      ],
    );
  }

  // BuildEventTitle: Display event title and category
  Widget _buildEventTitle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: AppTextStyles.titleMedium(isDark: isDark).copyWith(
            fontSize: AppSizes.fontLarge.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSizes.spacingSmall.h),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.chipPaddingHorizontal.w,
            vertical: AppSizes.chipPaddingVertical.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.getPrimary(isDark).withOpacity(0.1),
                AppColors.getPrimary(isDark).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
          ),
          child: Text(
            event.category,
            style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
              fontSize: AppSizes.fontSmall.sp,
              color: AppColors.getPrimary(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // BuildCloseButton: Button to clear selected event and hide card
  Widget _buildCloseButton(bool isDark, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusRound.r),
        onTap: () {
          print(
            'EventDetailCard: Close button tapped for event ${event.title}, id=${event.id}',
          );
          ref.read(selectedEventProvider.notifier).state = null;
          ref.invalidate(selectedEventProvider);
        },
        splashColor: AppColors.getPrimary(isDark).withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingSmall.w),
          child: Icon(
            Icons.close_rounded,
            size: AppSizes.iconSmall.sp,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }

  // BuildDescription: Display event description
  Widget _buildDescription(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium.w),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
        border: Border.all(
          color: AppColors.getBorder(isDark),
          width: AppSizes.borderWidthThin,
        ),
      ),
      child: Text(
        event.description,
        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
          fontSize: AppSizes.fontSmall.sp,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // BuildFooter: Display attendee info and view details button
  Widget _buildFooter(bool isDark, BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAttendeeInfo(isDark),
        _buildViewDetailsButton(isDark, context, ref),
      ],
    );
  }

  // BuildAttendeeInfo: Show current/max attendees
  Widget _buildAttendeeInfo(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium.w,
        vertical: AppSizes.paddingSmall.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
        border: Border.all(
          color: AppColors.getBorder(isDark).withOpacity(0.5),
          width: AppSizes.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            size: AppSizes.iconSmall.sp,
            color: AppColors.getTextSecondary(isDark),
          ),
          SizedBox(width: AppSizes.spacingSmall.w),
          Text(
            '${event.attendees.length}/${event.maxAttendees}',
            style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
              fontSize: AppSizes.fontSmall.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // BuildViewDetailsButton: Navigate to event details page
  Widget _buildViewDetailsButton(
    bool isDark,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
        onTap: () {
          context.push('/event-detail', extra: event);
          print('EventDetailCard: Navigated to details for ${event.title}');
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXl.w,
            vertical: AppSizes.paddingMedium.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.getPrimary(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(isDark),
                blurRadius: AppSizes.cardElevationLow * 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Details',
                style: AppTextStyles.labelLarge(isDark: false).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontMedium.sp,
                ),
              ),
              SizedBox(width: AppSizes.spacingSmall.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: AppSizes.iconSmall.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}