// Note: This alias seems unused; consider removing if not needed elsewhere.
// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/Map/presentation/provider/map_providers.dart'; // Note: Duplicate import path variation; use consistent one.

class EventDetailCard extends ConsumerWidget {
  final EventEntity event;

  const EventDetailCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

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
        padding: EdgeInsets.all(20.w),
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(colors, ref),
                SizedBox(height: 12.h),
                _buildDescription(colors),
                SizedBox(height: 12.h),
                _buildFooter(colors, context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors, WidgetRef ref) {
    return Row(
      children: [
        Hero(
          tag: event.id,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 6.r)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.r),
              child: Image.network(
                event.imageUrl ?? 'https://via.placeholder.com/80',
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.event, size: 80.sp, color: colors.textSecondary),
              ),
            ),
          ),
        ),
        SizedBox(width: 22.w),
        Expanded(child: _buildEventTitle(colors)),
        _buildCloseButton(colors, ref),
      ],
    );
  }

  Widget _buildEventTitle(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withOpacity(0.1),
                colors.primary.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            event.category,
            style: TextStyle(
              fontSize: 11.sp,
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(AppColors colors, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(selectedEventProvider.notifier).state = null,
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: Icon(Icons.close, size: 20.sp, color: colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDescription(AppColors colors) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      child: Text(
        event.description,
        style: TextStyle(
          fontSize: 12.sp,
          color: colors.textSecondary,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(AppColors colors, BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAttendeeInfo(colors),
        _buildViewDetailsButton(colors, context, ref),
      ],
    );
  }

  Widget _buildAttendeeInfo(AppColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.people, size: 16.sp, color: colors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            '${event.attendees.length}/${event.maxAttendees}',
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(
    AppColors colors,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          context.push('/event-detail', extra: event);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
