import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/favorites/providers/favorites_provider.dart';
import 'package:sync_event/features/home/presentation/utils/snackbar_helper.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/empty_state_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/small_card_shimmer_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/top_in_city_card.dart';
import 'package:go_router/go_router.dart';

class TopCityEventsSection extends ConsumerWidget {
  final AsyncValue eventsAsync;
  final bool isDark;
  final String cityName;

  const TopCityEventsSection({
    super.key,
    required this.eventsAsync,
    required this.isDark,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return eventsAsync.when(
      data: (events) {
        final allEvents = events ?? [];
        List<dynamic> cityEvents = allEvents
            .where(
              (event) =>
                  event != null &&
                  event.location?.toLowerCase().contains(cityName.toLowerCase()) == true,
            )
            .toList();

        if (cityEvents.isEmpty) {
          return EmptyState(
            message: 'No events in $cityName',
            icon: Icons.location_off_rounded,
            isDark: isDark,
          );
        }

        try {
          cityEvents.sort(
            (a, b) => (b?.attendees?.length ?? 0).compareTo(a?.attendees?.length ?? 0),
          );
        } catch (e) {}

        final topEvents = cityEvents.take(10).toList();

        final height = ResponsiveUtil.isMobile(context) ? 240.h : 280.h;

        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveUtil.getResponsiveHorizontalPadding(context),
            itemCount: topEvents.length,
            itemBuilder: (context, index) {
              final event = topEvents[index];
              if (event == null) return const SizedBox(width: 10);

              final isFavorite = favorites.contains(event.id ?? '');
              final attendeesCount = (event.attendees?.length ?? 0).clamp(0, 999);

              return Padding(
                padding: EdgeInsets.only(
                  right: index == topEvents.length - 1 ? 0 : AppSizes.spacingMedium,
                ),
                child: TopCitySmallEventCard(
                  event: event,
                  isDark: isDark,
                  rating: (4.5 + (attendeesCount % 5) * 0.1).toStringAsFixed(1),
                  isFavorite: isFavorite,
                  onFavoriteTap: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(event.id ?? '');
                    showFavoriteSnackbarSafe(context, isFavorite, event.title ?? 'Event');
                  },
                  onTap: () => context.push('/event-detail', extra: event),
                ),
              );
            },
          ),
        );
      },
      loading: () => SmallCardShimmer(isDark: isDark),
      error: (_, __) => EmptyState(
        message: 'Failed to load events',
        icon: Icons.error_outline_rounded,
        isDark: isDark,
      ),
    );
  }
}