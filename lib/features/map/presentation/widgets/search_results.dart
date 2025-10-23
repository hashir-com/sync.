// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final isDark = ref.watch(themeProvider);

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
        constraints: BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl + 2),
          border: Border.all(
            color: AppColors.getBorder(isDark),
            width: AppSizes.borderWidthThin,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(isDark),
              blurRadius: AppSizes.cardElevationHigh,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(filteredEvents.length, isDark),
              Flexible(child: _buildResultsList(filteredEvents, isDark, ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getBorder(isDark),
            width: AppSizes.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.getTextSecondary(isDark),
            size: AppSizes.iconSmall - 2,
          ),
          SizedBox(width: AppSizes.spacingSmall),
          Text(
            '$count result${count != 1 ? 's' : ''} found',
            style: AppTextStyles.labelMedium(isDark: isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    List<EventEntity> events,
    bool isDark,
    WidgetRef ref,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildResultItem(event, index, events.length, isDark, ref);
      },
    );
  }

  Widget _buildResultItem(
    EventEntity event,
    int index,
    int totalCount,
    bool isDark,
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
          splashColor: AppColors.getSurface(isDark),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
            decoration: BoxDecoration(
              border: index != totalCount - 1
                  ? Border(
                      bottom: BorderSide(
                        color: AppColors.getBorder(isDark),
                        width: AppSizes.borderWidthThin,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                _buildEventImage(event, isDark),
                SizedBox(width: AppSizes.spacingMedium),
                Expanded(child: _buildEventInfo(event, isDark)),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.fontSmall,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(EventEntity event, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: AppTextStyles.labelLarge(isDark: isDark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSizes.spacingXs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: AppSizes.paddingXs - 1,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.getPrimary(isDark).withOpacity(0.1),
                AppColors.getPrimary(isDark).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            event.category,
            style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
              color: AppColors.getPrimary(isDark),
              fontSize: AppSizes.fontXs,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventImage(EventEntity event, bool isDark) {
    return Hero(
      tag: 'search_${event.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(isDark),
              blurRadius: AppSizes.cardElevationLow + 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge + 2),
          child: Image.network(
            event.imageUrl ?? 'https://via.placeholder.com/50',
            width: AppSizes.avatarLarge,
            height: AppSizes.avatarLarge,
            fit: BoxFit.cover,
            errorBuilder: (_, __, _) => Container(
              width: AppSizes.avatarLarge,
              height: AppSizes.avatarLarge,
              color: AppColors.getSurface(isDark),
              child: Icon(
                Icons.event,
                size: AppSizes.iconMedium,
                color: AppColors.getTextSecondary(isDark),
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
