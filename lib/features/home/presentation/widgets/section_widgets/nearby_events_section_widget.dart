import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/favorites/providers/favorites_provider.dart';
import 'package:sync_event/features/home/presentation/providers/location_provider.dart';
import 'package:sync_event/features/home/presentation/utils/snackbar_helper.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/empty_state_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/error_state_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/location_denied_state_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/location_service_disabled_state_widget.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/nearby_event_card.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/small_card_shimmer_widget.dart';
import 'package:go_router/go_router.dart';

class NearbyEventsSection extends ConsumerWidget {
  final AsyncValue eventsAsync;
  final bool isDark;

  const NearbyEventsSection({
    super.key,
    required this.eventsAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationStateProvider);
    final favorites = ref.watch(favoritesProvider);

    if (locationState.isServiceDisabled) {
      return LocationServiceDisabledState(
        isDark: isDark,
        onEnableLocation: () async {
          final notifier = ref.read(locationStateProvider.notifier);
          await notifier.openLocationSettings();
          await Future.delayed(const Duration(seconds: 1));
          notifier.retry();
        },
      );
    }

    if (locationState.isDenied) {
      return LocationDeniedState(
        isDark: isDark,
        onRetry: () async {
          final notifier = ref.read(locationStateProvider.notifier);
          await notifier.openAppSettings();
          await Future.delayed(const Duration(seconds: 1));
          notifier.retry();
        },
      );
    }

    if (locationState.isLoading || locationState.position == null) {
      return SmallCardShimmer(isDark: isDark);
    }

    return eventsAsync.when(
      data: (events) {
        final nearbyEvents = (events ?? []).where((e) => e != null).toList();

        if (nearbyEvents.isEmpty) {
          return EmptyState(
            message: 'No nearby events found',
            icon: Icons.location_off_rounded,
            isDark: isDark,
          );
        }

        nearbyEvents.sort((a, b) {
          try {
            final distA = Geolocator.distanceBetween(
              locationState.position!.latitude,
              locationState.position!.longitude,
              (a?.latitude ?? 0.0),
              (a?.longitude ?? 0.0),
            );
            final distB = Geolocator.distanceBetween(
              locationState.position!.latitude,
              locationState.position!.longitude,
              (b?.latitude ?? 0.0),
              (b?.longitude ?? 0.0),
            );
            return distA.compareTo(distB);
          } catch (e) {
            return 0;
          }
        });

        final height = ResponsiveUtil.isMobile(context) ? 240.h : 280.h;

        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveUtil.getResponsiveHorizontalPadding(context),
            itemCount: nearbyEvents.length,
            itemBuilder: (context, index) {
              final event = nearbyEvents[index];
              if (event == null) return const SizedBox(width: 10);

              final isFavorite = favorites.contains(event.id ?? '');

              try {
                final distanceMeters = Geolocator.distanceBetween(
                  locationState.position!.latitude,
                  locationState.position!.longitude,
                  event.latitude ?? 0.0,
                  event.longitude ?? 0.0,
                );
                final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == nearbyEvents.length - 1 ? 0 : AppSizes.spacingMedium,
                  ),
                  child: NearbySmallEventCard(
                    event: event,
                    isDark: isDark,
                    distanceKm: distanceKm,
                    isFavorite: isFavorite,
                    onFavoriteTap: () {
                      ref.read(favoritesProvider.notifier).toggleFavorite(event.id ?? '');
                      showFavoriteSnackbarSafe(context, isFavorite, event.title ?? 'Event');
                    },
                    onTap: () => context.push('/event-detail', extra: event),
                  ),
                );
              } catch (e) {
                return const SizedBox(width: 10);
              }
            },
          ),
        );
      },
      loading: () => SmallCardShimmer(isDark: isDark),
      error: (_, __) => ErrorState(
        message: 'Failed to load nearby events',
        onRetry: () => ref.refresh(approvedEventsStreamProvider),
        isDark: isDark,
      ),
    );
  }
}