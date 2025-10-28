import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class NearbySmallEventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  final String distanceKm;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const NearbySmallEventCard({
    super.key,
    required this.event,
    required this.isDark,
    required this.distanceKm,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = event.startTime ?? DateTime.now();
    final dateFormat = DateFormat('MMM d');
    final formattedDate = dateFormat.format(startTime);
    final distance = double.tryParse(distanceKm) ?? 0;
    final Color distanceColor = distance <= 40
        ? AppColors.getSuccess(isDark)
        : AppColors.getWarning(isDark);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ResponsiveUtil.isMobile(context) ? 140 : 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: ResponsiveUtil.isMobile(context) ? 160 : 200,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
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
                                color: AppColors.getTextSecondary(
                                  isDark,
                                ).withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: AppSizes.paddingSmall,
                    left: AppSizes.paddingMedium,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall,
                        vertical: AppSizes.paddingXs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
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
                  Positioned(
                    top: AppSizes.paddingXs,
                    right: AppSizes.paddingXs,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.paddingXs),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: AppSizes.iconSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingXs),
            Text(
              event.title ?? 'Event',
              style: AppTextStyles.titleSmall(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.spacingXs / 2),
            Text(
              event.location ?? 'Unknown',
              style: AppTextStyles.bodySmall(isDark: isDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.spacingXs),
            Row(
              children: [
                Icon(
                  distance < 40
                      ? Icons.telegram_sharp
                      : Icons.location_on_rounded,
                  size: 12,
                  color: distanceColor,
                ),
                SizedBox(width: AppSizes.spacingXs / 2),
                Expanded(
                  child: Text(
                    '$distanceKm km away',
                    style: AppTextStyles.labelSmall(
                      isDark: isDark,
                    ).copyWith(color: distanceColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
