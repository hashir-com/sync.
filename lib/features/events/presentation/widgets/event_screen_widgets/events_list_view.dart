// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_helper.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/events/presentation/widgets/event_screen_widgets/event_page_card.dart';
import 'package:sync_event/features/home/presentation/screen/filter_bottom_sheet.dart';

class EventsListView extends ConsumerWidget {
  final List<dynamic> events;
  final String currentUserId;
  final EventFilter filter;
  final bool isDark;

  const EventsListView({
    super.key,
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
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
                              color: AppColors.getPrimary(isDark).withOpacity(0.1),
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
                  duration: const Duration(milliseconds: 600),
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
                        style: AppTextStyles.titleMedium(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSizes.spacingSmall),
                      Text(
                        filter.hasActiveFilters
                            ? 'Try adjusting your filter criteria'
                            : 'Check back soon for new events',
                        style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
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
                              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = ResponsiveHelper.isDesktop(context);
        final isTablet = ResponsiveHelper.isTablet(context);
        
        if (isDesktop || isTablet) {
          // Use grid layout for tablet and desktop
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.getResponsiveGridColumns(
                      context,
                      mobileColumns: 1,
                      tabletColumns: 2,
                      desktopColumns: 3,
                    ),
                    crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    childAspectRatio: ResponsiveHelper.getAspectRatio(
                      context,
                      mobileRatio: 1.2,
                      tabletRatio: 1.1,
                      desktopRatio: 1.0,
                    ),
                  ),
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
                        child: EventCard(
                          event: event,
                          isAttending: isAttending,
                          isFull: isFull,
                          isDark: isDark,
                          onTap: () => context.push('/event-detail', extra: event),
                          onJoin: () => _joinEvent(context, ref, event.id, currentUserId),
                        ),
                      );
                    },
                    childCount: events.length,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Use list layout for mobile
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: ResponsiveHelper.getResponsivePadding(context),
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
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 16,
                              tablet: 20,
                              desktop: 24,
                            ),
                          ),
                          child: EventCard(
                            event: event,
                            isAttending: isAttending,
                            isFull: isFull,
                            isDark: isDark,
                            onTap: () => context.push('/event-detail', extra: event),
                            onJoin: () => _joinEvent(context, ref, event.id, currentUserId),
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
      },
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
                Icon(
                  Icons.check_circle_rounded, 
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Successfully joined the event!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
              ),
            ),
            margin: ResponsiveHelper.getResponsivePadding(context),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_rounded, 
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Failed to join: ${e.toString()}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.getError(isDark),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
              ),
            ),
            margin: ResponsiveHelper.getResponsivePadding(context),
          ),
        );
      }
    }
  }
}