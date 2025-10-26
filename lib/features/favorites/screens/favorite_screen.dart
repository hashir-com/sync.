// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/favorites/providers/favorites_provider.dart';
import 'package:sync_event/features/favorites/widgets/favorite_event_card_widget.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final favoriteEvents = ref.watch(favoriteEventsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: AppTextStyles.headingMedium(
            isDark: isDark,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.getSurface(isDark),
        elevation: 0,
        // ... your actions
      ),
      body: favoriteEvents.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                final isFavorite = favorites.contains(event.id);

                return FavoriteEventCard(
                  event: event,
                  isDark: isDark,
                  isFavorite: isFavorite,
                  onFavoriteTap: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(event.id);
                    _showFavoriteSnackbar(context, false, event.title, isDark);
                  },
                  onTap: () {
                    context.push('/event-detail', extra: event);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingXxl),
              decoration: BoxDecoration(
                color: AppColors.getPrimary(isDark).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: AppSizes.iconXxl * 2,
                color: AppColors.getPrimary(isDark),
              ),
            ),
            SizedBox(height: AppSizes.spacingXxl),
            Text(
              'No Favorites Yet',
              style: AppTextStyles.headingMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              'Start adding events to your favorites\nby tapping the heart icon',
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(color: AppColors.getTextSecondary(isDark)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spacingXxl),
            ElevatedButton.icon(
              onPressed: () => context.go('/root'),
              icon: Icon(Icons.explore_rounded),
              label: Text('Explore Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(isDark),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXxl,
                  vertical: AppSizes.paddingLarge,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoriteSnackbar(
    BuildContext context,
    bool wasAdded,
    String title,
    bool isDark,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              wasAdded ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: AppSizes.iconMedium,
            ),
            SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: Text(
                wasAdded ? 'Added to favorites' : 'Removed from favorites',
                style: AppTextStyles.bodyMedium(
                  isDark: true,
                ).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: wasAdded ? Colors.red : Colors.grey[700],
        margin: EdgeInsets.all(AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }
}
