import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

// ============================================
// Location State Provider
// ============================================
final locationStateProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
      return LocationNotifier();
    });

class LocationState {
  final Position? position;
  final bool isDenied;
  final bool isLoading;

  LocationState({this.position, this.isDenied = false, this.isLoading = true});

  LocationState copyWith({
    Position? position,
    bool? isDenied,
    bool? isLoading,
  }) {
    return LocationState(
      position: position ?? this.position,
      isDenied: isDenied ?? this.isDenied,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isDenied: true, isLoading: false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(isDenied: true, isLoading: false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    state = state.copyWith(position: pos, isDenied: false, isLoading: false);
  }

  void retry() {
    state = LocationState();
    _checkLocationPermission();
  }
}

// ============================================
// Main Event Section Widget
// ============================================
class EventSection extends ConsumerWidget {
  const EventSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(approvedEventsStreamProvider);
    final isDark = ThemeUtils.isDark(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: AppSizes.spacingLarge),

        // ------- UPCOMING EVENTS SECTION -------
        _SectionHeader(
          title: 'Upcoming Events',
          onSeeAllPressed: () => context.push('/events'),
          isDark: isDark,
        ),

        SizedBox(height: AppSizes.spacingLarge),

        // ------- UPCOMING EVENTS LIST -------
        SizedBox(
          height: screenHeight * 0.42,
          child: eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return _EmptyState(
                  message: 'No upcoming events',
                  icon: Icons.event_busy_rounded,
                  isDark: isDark,
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPaddingHorizontal,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: EdgeInsets.only(right: AppSizes.spacingLarge),
                    child: _EventCard(
                      event: event,
                      isDark: isDark,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onTap: () => context.push('/event-detail', extra: event),
                    ),
                  );
                },
              );
            },
            loading: () => _EventCardShimmer(
              isDark: isDark,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
            error: (error, _) => _ErrorState(
              message: 'Failed to load events',
              onRetry: () => ref.refresh(approvedEventsStreamProvider),
              isDark: isDark,
            ),
          ),
        ),

        SizedBox(height: AppSizes.spacingXxxl),

        // ------- NEARBY YOU SECTION -------
        _SectionHeader(
          title: 'Nearby You',
          onSeeAllPressed: () {},
          isDark: isDark,
        ),

        SizedBox(height: AppSizes.spacingLarge),

        // ------- NEARBY EVENTS LIST -------
        _NearbyEventsSection(
          eventsAsync: eventsAsync,
          isDark: isDark,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),

        SizedBox(height: AppSizes.spacingXxl),
      ],
    );
  }
}

// ============================================
// Section Header Widget
// ============================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllPressed;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.onSeeAllPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          InkWell(
            onTap: onSeeAllPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: AppSizes.paddingXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                      color: AppColors.getPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingXs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: AppSizes.iconSmall,
                    color: AppColors.getPrimary(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Nearby Events Section
// ============================================
class _NearbyEventsSection extends ConsumerWidget {
  final AsyncValue eventsAsync;
  final bool isDark;
  final double screenWidth;
  final double screenHeight;

  const _NearbyEventsSection({
    required this.eventsAsync,
    required this.isDark,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationStateProvider);

    if (locationState.isDenied) {
      return _LocationDeniedState(
        isDark: isDark,
        onRetry: () => ref.read(locationStateProvider.notifier).retry(),
      );
    }

    if (locationState.isLoading || locationState.position == null) {
      return SizedBox(
        height: screenHeight * 0.35,
        child: _EventCardShimmer(
          isDark: isDark,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      );
    }

    return SizedBox(
      height: screenHeight * 0.35,
      child: eventsAsync.when(
        data: (events) {
          final nearbyEvents = events.toList();

          // Sort by distance
          nearbyEvents.sort((a, b) {
            double distA = Geolocator.distanceBetween(
              locationState.position!.latitude,
              locationState.position!.longitude,
              a.latitude ?? 0.0,
              a.longitude ?? 0.0,
            );
            double distB = Geolocator.distanceBetween(
              locationState.position!.latitude,
              locationState.position!.longitude,
              b.latitude ?? 0.0,
              b.longitude ?? 0.0,
            );
            return distA.compareTo(distB);
          });

          if (nearbyEvents.isEmpty) {
            return _EmptyState(
              message: 'No nearby events found',
              icon: Icons.location_off_rounded,
              isDark: isDark,
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingHorizontal,
            ),
            itemCount: nearbyEvents.length,
            itemBuilder: (context, index) {
              final event = nearbyEvents[index];

              final distanceMeters = Geolocator.distanceBetween(
                locationState.position!.latitude,
                locationState.position!.longitude,
                event.latitude ?? 0.0,
                event.longitude ?? 0.0,
              );
              final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);

              return Padding(
                padding: EdgeInsets.only(right: AppSizes.spacingLarge),
                child: _EventCard(
                  event: event,
                  isDark: isDark,
                  distanceKm: distanceKm,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () => context.push('/event-detail', extra: event),
                ),
              );
            },
          );
        },
        loading: () => _EventCardShimmer(
          isDark: isDark,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        error: (error, _) => _ErrorState(
          message: 'Failed to load nearby events',
          onRetry: () => ref.refresh(approvedEventsStreamProvider),
          isDark: isDark,
        ),
      ),
    );
  }
}

// ============================================
// Event Card Widget
// ============================================
class _EventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  final String? distanceKm;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.isDark,
    this.distanceKm,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd\nMMM');
    final formattedDate = dateFormat.format(event.startTime);
    final attendeesText = '${event.attendees.length} Going';

    // Responsive card dimensions
    final cardWidth = (screenWidth * 0.65).clamp(240.0, 300.0);
    final imageHeight = (screenHeight * 0.16).clamp(120.0, 160.0);
    final contentPadding = AppSizes.paddingMedium;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.getCard(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.getBorder(isDark), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image
                _EventImage(
                  event: event,
                  formattedDate: formattedDate,
                  isDark: isDark,
                  imageHeight: imageHeight,
                ),

                // Content Section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Flexible(
                          child: Text(
                            event.title,
                            style: AppTextStyles.titleMedium(
                              isDark: isDark,
                            ).copyWith(fontWeight: FontWeight.w900, height: .5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: AppSizes.spacingMedium),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: AppSizes.iconSmall,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                            SizedBox(width: AppSizes.spacingXs),
                            Expanded(
                              child: Text(
                                event.location,
                                style: AppTextStyles.bodySmall(isDark: isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Distance badge (if nearby)
                        if (distanceKm != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingSmall,
                              vertical: AppSizes.paddingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getSuccess(
                                isDark,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusXs,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me_rounded,
                                  size: AppSizes.iconXs,
                                  color: AppColors.getSuccess(isDark),
                                ),
                                SizedBox(width: AppSizes.spacingXs),
                                Text(
                                  '$distanceKm km away',
                                  style:
                                      AppTextStyles.labelSmall(
                                        isDark: isDark,
                                      ).copyWith(
                                        color: AppColors.getSuccess(isDark),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSizes.spacingSmall),
                        ],

                        // Attendees
                        Row(
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: AppSizes.iconSmall,
                              color: AppColors.getPrimary(isDark),
                            ),
                            SizedBox(width: AppSizes.spacingXs),
                            Text(
                              attendeesText,
                              style: AppTextStyles.labelMedium(isDark: isDark)
                                  .copyWith(
                                    color: AppColors.getPrimary(isDark),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// Event Image Widget
// ============================================
class _EventImage extends StatelessWidget {
  final dynamic event;
  final String formattedDate;
  final bool isDark;
  final double imageHeight;

  const _EventImage({
    required this.event,
    required this.formattedDate,
    required this.isDark,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLarge),
          ),
          child: Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primaryVariant.withOpacity(0.3),
                        AppColors.secondary.withOpacity(0.2),
                      ]
                    : [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.15),
                      ],
              ),
            ),
            child: event.imageUrl != null
                ? Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _ImageShimmer(isDark: isDark);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.event_rounded,
                          size: AppSizes.iconXxl,
                          color: AppColors.getTextSecondary(
                            isDark,
                          ).withOpacity(0.5),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.event_rounded,
                      size: AppSizes.iconXxl,
                      color: AppColors.getTextSecondary(
                        isDark,
                      ).withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: AppSizes.paddingSmall,
          left: AppSizes.paddingSmall,
          child: _DateTag(date: formattedDate, isDark: isDark),
        ),
        Positioned(
          top: AppSizes.paddingSmall,
          right: AppSizes.paddingSmall,
          child: _BookmarkButton(isDark: isDark),
        ),
      ],
    );
  }
}

// ============================================
// Date Tag Widget
// ============================================
class _DateTag extends StatelessWidget {
  final String date;
  final bool isDark;

  const _DateTag({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppSizes.fontMedium,
          fontWeight: FontWeight.w800,
          color: AppColors.error,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ============================================
// Bookmark Button Widget
// ============================================
class _BookmarkButton extends StatefulWidget {
  final bool isDark;

  const _BookmarkButton({required this.isDark});

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => isBookmarked = !isBookmarked),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: AppSizes.iconSmall,
            color: isBookmarked
                ? AppColors.error
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

// ============================================
// Event Card Shimmer
// ============================================
class _EventCardShimmer extends StatelessWidget {
  final bool isDark;
  final double screenWidth;
  final double screenHeight;

  const _EventCardShimmer({
    required this.isDark,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (screenWidth * 0.65).clamp(240.0, 300.0);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: AppSizes.spacingLarge),
          child: Shimmer.fromColors(
            baseColor: AppColors.getShimmerBase(isDark),
            highlightColor: AppColors.getShimmerHighlight(isDark),
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// Image Shimmer
// ============================================
class _ImageShimmer extends StatelessWidget {
  final bool isDark;

  const _ImageShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.getShimmerBase(isDark),
      highlightColor: AppColors.getShimmerHighlight(isDark),
      child: Container(color: AppColors.getSurface(isDark)),
    );
  }
}

// ============================================
// Location Denied State
// ============================================
class _LocationDeniedState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _LocationDeniedState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
      ),
      padding: EdgeInsets.all(AppSizes.paddingXxl),
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.getBorder(isDark), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.getWarning(isDark).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: AppSizes.iconXxl,
              color: AppColors.getWarning(isDark),
            ),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Location Access Required',
            style: AppTextStyles.titleMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Enable location services to discover amazing events happening near you',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingXl),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.location_on_rounded,
              size: AppSizes.iconSmall,
            ),
            label: Text(
              'Enable Location',
              style: AppTextStyles.button(
                isDark: isDark,
              ).copyWith(color: Colors.white, fontSize: AppSizes.fontMedium),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXxl,
                vertical: AppSizes.paddingLarge,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Empty State Widget
// ============================================
class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const _EmptyState({
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingXl),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppSizes.iconXxl,
              color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
            ),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(message, style: AppTextStyles.bodyMedium(isDark: isDark)),
        ],
      ),
    );
  }
}

// ============================================
// Error State Widget
// ============================================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.getError(isDark).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconXxl,
              color: AppColors.getError(isDark),
            ),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            message,
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingLarge),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconSmall),
            label: Text(
              'Try Again',
              style: AppTextStyles.labelLarge(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getPrimary(isDark),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.paddingMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
