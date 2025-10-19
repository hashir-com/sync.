import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/widgets/filter_bottom_sheet.dart';

// ============================================
// Filtered Events Provider
// ============================================
final filteredEventsProvider = Provider<List<dynamic>>((ref) {
  final eventsAsync = ref.watch(approvedEventsStreamProvider);
  final filter = ref.watch(eventFilterProvider);

  return eventsAsync.when(
    data: (events) {
      var filtered = events;

      // Filter by categories
      if (filter.selectedCategories.isNotEmpty) {
        filtered = filtered
            .where((event) =>
                filter.selectedCategories.contains(event.category))
            .toList();
      }

      // Filter by location
      if (filter.selectedLocation != null) {
        filtered = filtered
            .where((event) =>
                event.location
                    .toLowerCase()
                    .contains(filter.selectedLocation!.toLowerCase()))
            .toList();
      }

      // Filter by price range
      filtered = filtered
          .where((event) =>
              event.ticketPrice! >= filter.priceRange.min &&
              event.ticketPrice! <= filter.priceRange.max)
          .toList();

      // Filter by date range
      if (filter.dateRange != null) {
        filtered = filtered
            .where((event) =>
                event.startTime.isAfter(filter.dateRange!.start) &&
                event.startTime.isBefore(filter.dateRange!.end))
            .toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================
// Events Screen with Filter Support
// ============================================
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final filter = ref.watch(eventFilterProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Discover Events',
          style: AppTextStyles.titleLarge(isDark: isDark).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.getBackground(isDark),
        actions: [
          // Filter button with badge
          Padding(
            padding: EdgeInsets.only(right: AppSizes.paddingXs),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(AppSizes.paddingXs),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(isDark),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: filter.hasActiveFilters
                          ? AppColors.getPrimary(isDark).withOpacity(0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: filter.hasActiveFilters
                          ? AppColors.getPrimary(isDark)
                          : AppColors.getTextSecondary(isDark),
                    ),
                    onPressed: () {
                      showFilterBottomSheet(
                        context,
                        onApplyFilters: () {
                          print("Filters applied on events screen");
                        },
                      );
                    },
                  ),
                ),
                if (filter.hasActiveFilters)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.getError(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getError(isDark).withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '${_getActiveFilterCount(filter)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Reset filters button
          if (filter.hasActiveFilters)
            Padding(
              padding: EdgeInsets.only(right: AppSizes.paddingSmall),
              child: Container(
                margin: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: AppColors.getError(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.getError(isDark),
                  ),
                  onPressed: () {
                    ref.read(eventFilterProvider.notifier).reset();
                  },
                  tooltip: 'Clear filters',
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(approvedEventsStreamProvider);
        },
        color: AppColors.getPrimary(isDark),
        child: _EventsListView(
          events: filteredEvents,
          currentUserId: currentUserId,
          filter: filter,
          isDark: isDark,
        ),
      ),
    );
  }

  int _getActiveFilterCount(EventFilter filter) {
    int count = 0;
    if (filter.selectedCategories.isNotEmpty) count++;
    if (filter.selectedLocation != null) count++;
    if (filter.dateRange != null) count++;
    if (filter.priceRange.min > 0 || filter.priceRange.max < double.infinity) {
      count++;
    }
    return count;
  }
}

// ============================================
// Events List View
// ============================================
class _EventsListView extends ConsumerWidget {
  final List<dynamic> events;
  final String currentUserId;
  final EventFilter filter;
  final bool isDark;

  const _EventsListView({
    required this.events,
    required this.currentUserId,
    required this.filter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.paddingXl),
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(isDark),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getPrimary(isDark)
                                  .withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          filter.hasActiveFilters
                              ? Icons.filter_list_off_rounded
                              : Icons.event_busy_rounded,
                          size: 64,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSizes.spacingXl),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        filter.hasActiveFilters
                            ? 'No events match your filters'
                            : 'No events available yet',
                        style: AppTextStyles.titleMedium(isDark: isDark)
                            .copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSizes.spacingSmall),
                      Text(
                        filter.hasActiveFilters
                            ? 'Try adjusting your filter criteria'
                            : 'Check back soon for new events',
                        style: AppTextStyles.bodyMedium(isDark: isDark)
                            .copyWith(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (filter.hasActiveFilters) ...[
                        SizedBox(height: AppSizes.spacingXl),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(eventFilterProvider.notifier).reset();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Clear All Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getPrimary(isDark),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingXl,
                              vertical: AppSizes.paddingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLarge),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingMedium,
            AppSizes.paddingSmall,
            AppSizes.paddingMedium,
            AppSizes.paddingMedium,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final event = events[index];
                final isAttending = event.attendees.contains(currentUserId);
                final isFull = event.attendees.length >= event.maxAttendees;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _EventCard(
                    event: event,
                    isAttending: isAttending,
                    isFull: isFull,
                    isDark: isDark,
                    onTap: () => context.push('/event-detail', extra: event),
                    onJoin: () => _joinEvent(
                      context,
                      ref,
                      event.id,
                      currentUserId,
                    ),
                  ),
                );
              },
              childCount: events.length,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _joinEvent(
    BuildContext context,
    WidgetRef ref,
    String eventId,
    String userId,
  ) async {
    try {
      await ref.read(joinEventUseCaseProvider).call(eventId, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: AppSizes.spacingSmall),
                Text('Successfully joined the event!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            margin: EdgeInsets.all(AppSizes.paddingMedium),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: AppSizes.spacingSmall),
                Expanded(child: Text('Failed to join: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.getError(isDark),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            margin: EdgeInsets.all(AppSizes.paddingMedium),
          ),
        );
      }
    }
  }
}

// ============================================
// Event Card Widget
// ============================================
class _EventCard extends StatelessWidget {
  final dynamic event;
  final bool isAttending;
  final bool isFull;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const _EventCard({
    required this.event,
    required this.isAttending,
    required this.isFull,
    required this.isDark,
    required this.onTap,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(event.startTime);
    final formattedTime = timeFormat.format(event.startTime);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getCard(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image with overlay gradient
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusXl),
                      ),
                      child: event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusXl),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: AppSizes.paddingMedium,
                      left: AppSizes.paddingMedium,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusRound),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event.category ?? 'Event',
                          style: AppTextStyles.labelSmall(isDark: false)
                              .copyWith(
                            color: AppColors.getPrimary(false),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Status badge (if attending or full)
                    if (isAttending || isFull)
                      Positioned(
                        top: AppSizes.paddingMedium,
                        right: AppSizes.paddingMedium,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: isAttending
                                ? AppColors.success
                                : AppColors.getError(isDark),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusRound),
                            boxShadow: [
                              BoxShadow(
                                color: (isAttending
                                        ? AppColors.success
                                        : AppColors.getError(isDark))
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAttending
                                    ? Icons.check_circle_rounded
                                    : Icons.block_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                isAttending ? 'Joined' : 'Full',
                                style:
                                    AppTextStyles.labelSmall(isDark: false)
                                        .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Event Details
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: AppTextStyles.titleLarge(isDark: isDark)
                            .copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: AppSizes.spacingLarge),

                      // Date and Time
                      Container(
                        padding: EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.getPrimary(isDark).withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSizes.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.getPrimary(isDark),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: AppSizes.spacingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: AppTextStyles.bodyMedium(
                                            isDark: isDark)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style:
                                        AppTextStyles.bodySmall(isDark: isDark)
                                            .copyWith(
                                      color:
                                          AppColors.getTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSizes.spacingMedium),

                      // Location
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(isDark),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: AppColors.getPrimary(isDark),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: Text(
                              event.location,
                              style:
                                  AppTextStyles.bodyMedium(isDark: isDark)
                                      .copyWith(
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSizes.spacingLarge),

                      // Attendees and Join Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isFull
                                  ? AppColors.getError(isDark).withOpacity(0.1)
                                  : AppColors.getPrimary(isDark)
                                      .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusRound),
                              border: Border.all(
                                color: isFull
                                    ? AppColors.getError(isDark)
                                        .withOpacity(0.3)
                                    : AppColors.getPrimary(isDark)
                                        .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 18,
                                  color: isFull
                                      ? AppColors.getError(isDark)
                                      : AppColors.getPrimary(isDark),
                                ),
                                SizedBox(width: AppSizes.spacingXs),
                                Text(
                                  event.maxAttendees == 0
                                      ? '${event.attendees.length} going'
                                      : '${event.attendees.length}/${event.maxAttendees}',
                                  style: AppTextStyles.bodySmall(isDark: isDark)
                                      .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isFull
                                        ? AppColors.getError(isDark)
                                        : AppColors.getPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isAttending || isFull ? null : onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAttending
                                  ? AppColors.success
                                  : AppColors.getPrimary(isDark),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.getTextSecondary(isDark)
                                      .withOpacity(0.3),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingXl,
                                vertical: AppSizes.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusRound),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isAttending
                                  ? 'Joined'
                                  : isFull
                                      ? 'Full'
                                      : 'Join Event',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark).withOpacity(0.3),
            AppColors.getPrimary(isDark).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 64,
          color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
        ),
      ),
    );
  }
}