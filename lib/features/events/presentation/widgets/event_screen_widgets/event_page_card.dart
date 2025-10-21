import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class EventCard extends StatelessWidget {
  final dynamic event;
  final bool isAttending;
  final bool isFull;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const EventCard({
    super.key,
    required this.event,
    required this.isAttending,
    required this.isFull,
    required this.isDark,
    required this.onTap,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(event.startTime);
    final formattedTime = timeFormat.format(event.startTime);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getCard(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image with overlay gradient
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusXl),
                      ),
                      child: event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusXl),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: AppSizes.paddingMedium,
                      left: AppSizes.paddingMedium,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event.category ?? 'Event',
                          style: AppTextStyles.labelSmall(isDark: false).copyWith(
                            color: AppColors.getPrimary(false),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Status badge (if attending or full)
                    if (isAttending || isFull)
                      Positioned(
                        top: AppSizes.paddingMedium,
                        right: AppSizes.paddingMedium,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: isAttending
                                ? AppColors.success
                                : AppColors.getError(isDark),
                            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                            boxShadow: [
                              BoxShadow(
                                color: (isAttending
                                        ? AppColors.success
                                        : AppColors.getError(isDark))
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAttending
                                    ? Icons.check_circle_rounded
                                    : Icons.block_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAttending ? 'Joined' : 'Full',
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
                // Event Details
                Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: AppTextStyles.titleLarge(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.spacingLarge),
                      // Date and Time
                      Container(
                        padding: EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.getPrimary(isDark).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSizes.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.getPrimary(isDark),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: AppSizes.spacingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingMedium),
                      // Location
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSizes.paddingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.getSurface(isDark),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: AppColors.getPrimary(isDark),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: Text(
                              event.location,
                              style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                color: AppColors.getTextSecondary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingLarge),
                      // Attendees and Join Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: isFull
                                  ? AppColors.getError(isDark).withOpacity(0.1)
                                  : AppColors.getPrimary(isDark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                              border: Border.all(
                                color: isFull
                                    ? AppColors.getError(isDark).withOpacity(0.3)
                                    : AppColors.getPrimary(isDark).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 18,
                                  color: isFull
                                      ? AppColors.getError(isDark)
                                      : AppColors.getPrimary(isDark),
                                ),
                                SizedBox(width: AppSizes.spacingXs),
                                Text(
                                  event.maxAttendees == 0
                                      ? '${event.attendees.length} going'
                                      : '${event.attendees.length}/${event.maxAttendees}',
                                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isFull
                                        ? AppColors.getError(isDark)
                                        : AppColors.getPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isAttending || isFull ? null : onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAttending
                                  ? AppColors.success
                                  : AppColors.getPrimary(isDark),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.getTextSecondary(isDark).withOpacity(0.3),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingXl,
                                vertical: AppSizes.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isAttending
                                  ? 'Joined'
                                  : isFull
                                  ? 'Full'
                                  : 'Join Event',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
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
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark).withOpacity(0.3),
            AppColors.getPrimary(isDark).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 64,
          color: AppColors.getTextSecondary(isDark).withOpacity(0.5),
        ),
      ),
    );
  }
}