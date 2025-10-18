// ignore_for_file: deprecated_member_use

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
  final bool isServiceDisabled;

  LocationState({
    this.position,
    this.isDenied = false,
    this.isLoading = true,
    this.isServiceDisabled = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isDenied,
    bool? isLoading,
    bool? isServiceDisabled,
  }) {
    return LocationState(
      position: position ?? this.position,
      isDenied: isDenied ?? this.isDenied,
      isLoading: isLoading ?? this.isLoading,
      isServiceDisabled: isServiceDisabled ?? this.isServiceDisabled,
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
      state = state.copyWith(
        isServiceDisabled: true,
        isDenied: false,
        isLoading: false,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isDenied: true,
        isServiceDisabled: false,
        isLoading: false,
      );
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = state.copyWith(
        position: pos,
        isDenied: false,
        isServiceDisabled: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isDenied: true, isLoading: false);
    }
  }

  void retry() {
    state = LocationState();
    _checkLocationPermission();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSizes.spacingXxl),

        // ------- POPULAR EVENTS SECTION -------
        _SectionHeader(title: 'Upcoming Popular events', isDark: isDark),

        SizedBox(height: AppSizes.spacingLarge),

        eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return _EmptyState(
                message: 'No events available',
                icon: Icons.event_busy_rounded,
                isDark: isDark,
              );
            }

            return Column(
              children: [
                _EventHorizontalList(
                  events: events.take(10).toList(),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.spacingXxxl),
              ],
            );
          },
          loading: () => _EventListShimmer(isDark: isDark),
          error: (error, _) => _ErrorState(
            message: 'Failed to load events',
            onRetry: () => ref.refresh(approvedEventsStreamProvider),
            isDark: isDark,
          ),
        ),

        // ------- NEARBY EVENTS SECTION -------
        _SectionHeader(title: 'Popular Events Near You', isDark: isDark),

        SizedBox(height: AppSizes.spacingLarge),

        _NearbyEventsSection(eventsAsync: eventsAsync, isDark: isDark),

        SizedBox(height: AppSizes.spacingXxxl),
      ],
    );
  }
}

// ============================================
// Section Header Widget
// ============================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headingxSmall(isDark: isDark),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppSizes.iconMedium,
            color: AppColors.getTextPrimary(isDark),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Event Horizontal List with Smooth Transitions
// ============================================
class _EventHorizontalList extends StatefulWidget {
  final List events;
  final bool isDark;

  const _EventHorizontalList({required this.events, required this.isDark});

  @override
  State<_EventHorizontalList> createState() => _EventHorizontalListState();
}

class _EventHorizontalListState extends State<_EventHorizontalList> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.45, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;

    return SizedBox(
      height: cardWidth * 1.7,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          // Calculate scale and opacity based on scroll position
          double scale = 1.0;
          double opacity = 1.0;

          if (_pageController.hasClients) {
            double diff = (index - _currentPage).abs();

            // Scale: cards get smaller as they move away from center
            scale = 1.0 - (diff * 0.15).clamp(0.0, 0.3);

            // Opacity: cards fade as they move away
            opacity = 1.0 - (diff * 0.3).clamp(0.0, 0.5);
          }

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: scale, end: scale),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: AppSizes.spacingMedium,
                    ),
                    child: _AirbnbEventCard(
                      event: widget.events[index],
                      isDark: widget.isDark,
                      onTap: () => context.push(
                        '/event-detail',
                        extra: widget.events[index],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================
// Airbnb-Style Event Card
// ============================================
class _AirbnbEventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  final String? distanceKm;
  final VoidCallback onTap;

  const _AirbnbEventCard({
    required this.event,
    required this.isDark,
    this.distanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final formattedDate = dateFormat.format(event.startTime);
    final attendeesCount = event.attendees.length;

    // Determine distance color and icon
    Color distanceColor = Colors.orange;
    IconData distanceIcon = Icons.location_on_rounded;

    if (distanceKm != null) {
      final distance = double.tryParse(distanceKm!) ?? 0;
      if (distance <= 40) {
        distanceColor = Colors.green;
        distanceIcon = Icons.near_me_rounded;
      } else {
        distanceColor = Colors.orange;
        distanceIcon = Icons.location_on_rounded;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with bookmark and date badge
          Expanded(
            child: Stack(
              children: [
                _EventImage(event: event, isDark: isDark),
                Positioned(
                  top: AppSizes.paddingSmall,
                  right: AppSizes.paddingSmall,
                  child: _HeartBookmark(isDark: isDark),
                ),
                Positioned(
                  top: AppSizes.paddingSmall,
                  left: AppSizes.paddingSmall,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusSemiRound,
                      ),
                    ),
                    child: Text(
                      formattedDate,
                      style: AppTextStyles.labelSmall(
                        isDark: false,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.spacingSmall),

          // Event title (bold and big)
          Text(
            event.title,
            style: AppTextStyles.titleSmall(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppSizes.spacingXs / 2),

          // Location
          Text(
            event.location,
            style: AppTextStyles.bodyMedium(isDark: isDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AppSizes.spacingXs),

          // Distance (if nearby) or Attendees count
          if (distanceKm != null)
            Row(
              children: [
                Icon(
                  distanceIcon,
                  size: AppSizes.iconSmall,
                  color: distanceColor,
                ),
                SizedBox(width: AppSizes.spacingXs / 2),
                Text(
                  '$distanceKm km away',
                  style: AppTextStyles.bodySmall(
                    isDark: isDark,
                  ).copyWith(fontWeight: FontWeight.w600, color: distanceColor),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: AppSizes.iconSmall,
                  color: AppColors.getPrimary(isDark),
                ),
                SizedBox(width: AppSizes.spacingXs / 2),
                Text(
                  '$attendeesCount going',
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getPrimary(isDark),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ============================================
// Event Image Widget
// ============================================
class _EventImage extends StatelessWidget {
  final dynamic event;
  final bool isDark;

  const _EventImage({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.getSurface(isDark),
          child: event.imageUrl != null
              ? Image.network(
                  event.imageUrl!,
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
                    color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================
// Heart Bookmark Button
// ============================================
class _HeartBookmark extends StatefulWidget {
  final bool isDark;

  const _HeartBookmark({required this.isDark});

  @override
  State<_HeartBookmark> createState() => _HeartBookmarkState();
}

class _HeartBookmarkState extends State<_HeartBookmark> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isBookmarked = !isBookmarked),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingSmall),
        child: Icon(
          isBookmarked ? Icons.favorite : Icons.favorite_border,
          size: AppSizes.iconMedium,
          color: isBookmarked ? Colors.red : Colors.white,
        ),
      ),
    );
  }
}

// ============================================
// Nearby Events Section with Smooth Transitions
// ============================================
class _NearbyEventsSection extends ConsumerStatefulWidget {
  final AsyncValue eventsAsync;
  final bool isDark;

  const _NearbyEventsSection({required this.eventsAsync, required this.isDark});

  @override
  ConsumerState<_NearbyEventsSection> createState() =>
      _NearbyEventsSectionState();
}

class _NearbyEventsSectionState extends ConsumerState<_NearbyEventsSection> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.45, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationStateProvider);

    if (locationState.isServiceDisabled) {
      return _LocationServiceDisabledState(
        isDark: widget.isDark,
        onEnableLocation: () async {
          final notifier = ref.read(locationStateProvider.notifier);
          await notifier.openLocationSettings();
          await Future.delayed(const Duration(seconds: 1));
          notifier.retry();
        },
      );
    }

    if (locationState.isDenied) {
      return _LocationDeniedState(
        isDark: widget.isDark,
        onRetry: () async {
          final notifier = ref.read(locationStateProvider.notifier);
          await notifier.openAppSettings();
          await Future.delayed(const Duration(seconds: 1));
          notifier.retry();
        },
      );
    }

    if (locationState.isLoading || locationState.position == null) {
      return _EventListShimmer(isDark: widget.isDark);
    }

    return widget.eventsAsync.when(
      data: (events) {
        final nearbyEvents = events.toList();

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
            isDark: widget.isDark,
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.42;

        return SizedBox(
          height: cardWidth * 1.7,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
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

              // Calculate scale and opacity based on scroll position
              double scale = 1.0;
              double opacity = 1.0;

              if (_pageController.hasClients) {
                double diff = (index - _currentPage).abs();
                scale = 1.0 - (diff * 0.15).clamp(0.0, 0.3);
                opacity = 1.0 - (diff * 0.3).clamp(0.0, 0.5);
              }

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: scale, end: scale),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingSmall,
                          vertical: AppSizes.spacingMedium,
                        ),
                        child: _AirbnbEventCard(
                          event: event,
                          isDark: widget.isDark,
                          distanceKm: distanceKm,
                          onTap: () =>
                              context.push('/event-detail', extra: event),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => _EventListShimmer(isDark: widget.isDark),
      error: (error, _) => _ErrorState(
        message: 'Failed to load nearby events',
        onRetry: () => ref.refresh(approvedEventsStreamProvider),
        isDark: widget.isDark,
      ),
    );
  }
}

// ============================================
// Event List Shimmer
// ============================================
class _EventListShimmer extends StatelessWidget {
  final bool isDark;

  const _EventListShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;

    return SizedBox(
      height: cardWidth * 1.65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingHorizontal,
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: AppSizes.spacingMedium),
            child: SizedBox(
              width: cardWidth,
              child: Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDark),
                highlightColor: AppColors.getShimmerHighlight(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(isDark),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSmall),
                    Container(
                      width: double.infinity,
                      height: AppSizes.fontLarge,
                      color: AppColors.getSurface(isDark),
                    ),
                    SizedBox(height: AppSizes.spacingXs),
                    Container(
                      width: cardWidth * 0.7,
                      height: AppSizes.fontMedium,
                      color: AppColors.getSurface(isDark),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
// Location Service Disabled State
// ============================================
class _LocationServiceDisabledState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEnableLocation;

  const _LocationServiceDisabledState({
    required this.isDark,
    required this.onEnableLocation,
  });

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
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: AppSizes.iconXxl,
            color: AppColors.getWarning(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Location Service Disabled',
            style: AppTextStyles.titleMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Please turn on location services to discover events near you',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingXl),
          ElevatedButton.icon(
            onPressed: onEnableLocation,
            icon: Icon(Icons.location_on_rounded, size: AppSizes.iconSmall),
            label: Text('Turn On Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXxl,
                vertical: AppSizes.paddingMedium,
              ),
            ),
          ),
        ],
      ),
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
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: AppSizes.iconXxl,
            color: AppColors.getError(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            'Location Permission Denied',
            style: AppTextStyles.titleMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Grant location permission in settings to find nearby events',
            style: AppTextStyles.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.spacingXl),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.settings_rounded, size: AppSizes.iconSmall),
            label: Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXxl,
                vertical: AppSizes.paddingMedium,
              ),
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
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconXxl,
              color: AppColors.getTextSecondary(isDark),
            ),
            SizedBox(height: AppSizes.spacingLarge),
            Text(message, style: AppTextStyles.bodyMedium(isDark: isDark)),
          ],
        ),
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
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconXxl,
              color: AppColors.getError(isDark),
            ),
            SizedBox(height: AppSizes.spacingLarge),
            Text(
              message,
              style: AppTextStyles.bodyMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingLarge),
            TextButton(onPressed: onRetry, child: Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
