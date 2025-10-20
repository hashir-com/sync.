import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/widgets/event_section.dart';

// ============================================
// Favorites Page
// ============================================
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final favoriteIds = ref.watch(favoritesProvider);
    final eventsAsync = ref.watch(approvedEventsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: AppTextStyles.headingSmall(isDark: isDark),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.getBackground(isDark),
        foregroundColor: AppColors.getTextPrimary(isDark),
      ),
      backgroundColor: AppColors.getBackground(isDark),
      body: eventsAsync.when(
        data: (allEvents) {
          // Filter events that are in favorites
          final favoriteEvents = (allEvents ?? [])
              .where(
                (event) =>
                    event != null && favoriteIds.contains(event.id ?? ''),
              )
              .toList();

          if (favoriteEvents.isEmpty) {
            return _EmptyFavoritesState(isDark: isDark);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizes.spacingLarge),
                  Text(
                    '${favoriteEvents.length} Saved Event${favoriteEvents.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(color: AppColors.getTextSecondary(isDark)),
                  ),
                  SizedBox(height: AppSizes.spacingLarge),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favoriteEvents.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppSizes.spacingMedium),
                    itemBuilder: (context, index) {
                      final event = favoriteEvents[index];
                      return _FavoriteEventCard(
                        event: event,
                        isDark: isDark,
                        onRemove: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .removeFavorite(event.id ?? '');
                          _showRemoveSnackbar(context, isDark);
                        },
                        onTap: () {
                          try {
                            context.push('/event-detail', extra: event);
                          } catch (e) {
                            // Handle error
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.spacingXxl),
                ],
              ),
            ),
          );
        },
        loading: () => _FavoritesShimmer(isDark: isDark),
        error: (error, _) => _FavoritesErrorState(
          isDark: isDark,
          onRetry: () => ref.refresh(approvedEventsStreamProvider),
        ),
      ),
    );
  }
}

// ============================================
// Favorite Event Card (Full Width)
// ============================================
class _FavoriteEventCard extends StatelessWidget {
  final EventEntity event;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteEventCard({
    required this.event,
    required this.isDark,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    DateTime startTime = event.startTime ?? DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(startTime);
    final formattedTime = timeFormat.format(startTime);
    final attendeesCount = (event.attendees?.length ?? 0).clamp(0, 999999);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCard(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.getBorder(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Remove Button
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusLarge),
                      topRight: Radius.circular(AppSizes.radiusLarge),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.getSurface(isDark),
                      child:
                          event.imageUrl != null && event.imageUrl!.isNotEmpty
                          ? Image.network(
                              event.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
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
                  // Gradient overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: AppSizes.paddingMedium,
                    right: AppSizes.paddingMedium,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: AppSizes.iconMedium,
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  if (event.category != null && event.category!.isNotEmpty)
                    Positioned(
                      top: AppSizes.paddingMedium,
                      left: AppSizes.paddingMedium,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSmall,
                          vertical: AppSizes.paddingXs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: Text(
                          event.category ?? 'Event',
                          style: AppTextStyles.labelSmall(isDark: false)
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title ?? 'Event',
                    style: AppTextStyles.titleMedium(
                      isDark: isDark,
                    ).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.spacingMedium),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: AppSizes.iconSmall,
                        color: AppColors.getPrimary(isDark),
                      ),
                      SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: Text(
                          event.location ?? 'Unknown location',
                          style: AppTextStyles.bodySmall(isDark: isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium),
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: AppSizes.iconSmall,
                        color: AppColors.getPrimary(isDark),
                      ),
                      SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: AppTextStyles.bodySmall(
                                isDark: isDark,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              formattedTime,
                              style: AppTextStyles.labelSmall(isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium),
                  // Attendees and Price
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: AppSizes.iconSmall,
                              color: AppColors.getPrimary(isDark),
                            ),
                            SizedBox(width: AppSizes.spacingSmall),
                            Expanded(
                              child: Text(
                                '$attendeesCount going',
                                style: AppTextStyles.bodySmall(isDark: isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingMedium),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSmall,
                          vertical: AppSizes.paddingXs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriceColor(event.ticketPrice ?? 0, isDark),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: Text(
                          _formatPrice(event.ticketPrice),
                          style: AppTextStyles.labelSmall(isDark: false)
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
    );
  }

  String _formatPrice(double? price) {
    if (price == null || price <= 0) return 'Free';

    // Format with 2 decimals, add comma separators
    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(price);

    return formatted;
  }

  /// Color coding based on price ranges
  Color _getPriceColor(double? price, bool isDark) {
    if (price == null || price <= 0) return Colors.green;
    if (price < 500) return Colors.blue;
    if (price < 1000) return Colors.orange;
    return Colors.red;
  }
}

// ============================================
// Empty Favorites State
// ============================================
class _EmptyFavoritesState extends StatelessWidget {
  final bool isDark;

  const _EmptyFavoritesState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: AppColors.getTextSecondary(isDark).withOpacity(0.3),
            ),
            SizedBox(height: AppSizes.spacingXl),
            Text(
              'No Favorites Yet',
              style: AppTextStyles.headingSmall(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Save events to your favorites to view them later',
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextSecondary(isDark)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXxl),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, size: AppSizes.iconSmall),
              label: const Text('Browse Events'),
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
      ),
    );
  }
}

// ============================================
// Favorites Shimmer Loader
// ============================================
class _FavoritesShimmer extends StatelessWidget {
  final bool isDark;

  const _FavoritesShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.screenPaddingHorizontal),
        child: Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
              child: Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDark),
                highlightColor: AppColors.getShimmerHighlight(isDark),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.getCard(isDark),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ============================================
// Favorites Error State
// ============================================
class _FavoritesErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _FavoritesErrorState({required this.isDark, required this.onRetry});

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
              size: 80,
              color: AppColors.getError(isDark),
            ),
            SizedBox(height: AppSizes.spacingXl),
            Text(
              'Something Went Wrong',
              style: AppTextStyles.headingSmall(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Failed to load your favorite events',
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextSecondary(isDark)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXxl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: AppSizes.iconSmall),
              label: const Text('Try Again'),
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
      ),
    );
  }
}

// ============================================
// Snackbar Helper
// ============================================
void _showRemoveSnackbar(BuildContext context, bool isDark) {
  if (!context.mounted) return;

  try {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.favorite_border, color: Colors.white, size: 20),
          SizedBox(width: 12),
          const Text('Removed from favorites'),
        ],
      ),
      duration: const Duration(milliseconds: 2000),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[700],
      margin: const EdgeInsets.all(16),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  } catch (e) {
    // Fail silently
  }
}
