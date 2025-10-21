import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/favorites/providers/favorites_provider.dart';
import 'package:sync_event/features/home/presentation/utils/snackbar_helper.dart';
import 'package:sync_event/features/home/presentation/widgets/section_widgets/small_event_card.dart';
import 'package:go_router/go_router.dart';

class SmallEventCardList extends ConsumerWidget {
  final List events;
  final bool isDark;

  const SmallEventCardList({
    super.key,
    required this.events,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final height = ResponsiveUtil.isMobile(context) ? 240.h : 280.h;

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: ResponsiveUtil.getResponsiveHorizontalPadding(context),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          if (event == null) return const SizedBox(width: 10);

          final isFavorite = favorites.contains(event.id ?? '');

          return Padding(
            padding: EdgeInsets.only(
              right: index == events.length - 1 ? 0 : AppSizes.spacingMedium,
            ),
            child: SmallEventCard(
              event: event,
              isDark: isDark,
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
  }
}