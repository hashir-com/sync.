// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/core/theme/app_theme.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);

    if (query.isEmpty || filteredEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(filteredEvents.length),
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: 300.h),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: colors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(filteredEvents.length, colors),
              Flexible(child: _buildResultsList(filteredEvents, colors, ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count, AppColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colors.textSecondary, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            '$count result${count != 1 ? 's' : ''} found',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    List<EventEntity> events,
    AppColors colors,
    WidgetRef ref,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildResultItem(event, index, events.length, colors, ref);
      },
    );
  }

  Widget _buildResultItem(
    EventEntity event,
    int index,
    int totalCount,
    AppColors colors,
    WidgetRef ref,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - animValue), 0),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onResultTap(event, ref),
          splashColor: colors.surface,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: index != totalCount - 1
                  ? Border(bottom: BorderSide(color: colors.border, width: 1))
                  : null,
            ),
            child: Row(
              children: [
                _buildEventImage(event, colors),
                SizedBox(width: 12.w),
                Expanded(child: _buildEventInfo(event, colors)),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(EventEntity event, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: colors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
              color: colors.primary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventImage(EventEntity event, AppColors colors) {
    return Hero(
      tag: 'search_${event.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 6.r)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Image.network(
            event.imageUrl ?? 'https://via.placeholder.com/50',
            width: 50.w,
            height: 50.h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, _) => Container(
              width: 50.w,
              height: 50.h,
              color: colors.surface,
              child: Icon(
                Icons.event,
                size: 24.sp,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onResultTap(EventEntity event, WidgetRef ref) {
    ref.read(selectedEventProvider.notifier).state = event;
    ref.read(searchQueryProvider.notifier).state = '';

    if (event.latitude != null && event.longitude != null) {
      ref
          .read(mapControllerProvider.notifier)
          .state
          ?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(event.latitude!, event.longitude!),
                zoom: 18,
                tilt: 60,
              ),
            ),
          );
    }
  }
}
