import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class TopCitySmallEventCard extends StatelessWidget {
  final dynamic event;
  final bool isDark;
  final String rating;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const TopCitySmallEventCard({
    super.key,
    required this.event,
    required this.isDark,
    required this.rating,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = event.startTime ?? DateTime.now();
    final dateFormat = DateFormat('MMM d');
    final formattedDate = dateFormat.format(startTime);
    final attendeesCount = (event.attendees?.length ?? 0).clamp(0, 999);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ResponsiveUtil.isMobile(context) ? 140.w : 180.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: ResponsiveUtil.isMobile(context) ? 160.h : 200.h,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.getSurface(isDark),
                      child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                          ? Image.network(
                              event.imageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.event_rounded,
                                    color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.event_rounded,
                                color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: AppSizes.paddingXs,
                    left: AppSizes.paddingXs,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall,
                        vertical: AppSizes.paddingXs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        formattedDate,
                        style: AppTextStyles.labelSmall(isDark: false).copyWith(fontWeight: FontWeight.w600),
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
                  Positioned(
                    bottom: AppSizes.paddingXs,
                    right: AppSizes.paddingXs,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingXs,
                        vertical: AppSizes.paddingXs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getWarning(isDark),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 2),
                          Text(
                            rating,
                            style: AppTextStyles.labelSmall(isDark: false).copyWith(
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
            ),
            SizedBox(height: AppSizes.spacingXs),
            Text(
              event.title ?? 'Event',
              style: AppTextStyles.titleSmall(isDark: isDark).copyWith(fontWeight: FontWeight.w700),
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
                  Icons.people_rounded,
                  size: 12,
                  color: AppColors.getPrimary(isDark),
                ),
                SizedBox(width: AppSizes.spacingXs / 2),
                Expanded(
                  child: Text(
                    '$attendeesCount going',
                    style: AppTextStyles.labelSmall(isDark: isDark).copyWith(color: AppColors.getPrimary(isDark)),
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