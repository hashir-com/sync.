import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import '../../domain/entities/event_entity.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventEntity event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.getBackground(isDark),
            leading: Container(
              margin: EdgeInsets.all(AppSizes.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(AppSizes.paddingSmall),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.imageUrl != null)
                    Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.getSurface(isDark),
                        child: Icon(
                          Icons.event_rounded,
                          size: AppSizes.iconXxl * 2,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.getSurface(isDark),
                      child: Icon(
                        Icons.event_rounded,
                        size: AppSizes.iconXxl * 2,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: AppTextStyles.headingMedium(isDark: isDark)
                              .copyWith(
                            fontSize: AppSizes.fontDisplay3,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getPrimary(isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXl,
                          ),
                        ),
                        child: Text(
                          event.category,
                          style: AppTextStyles.labelSmall(isDark: isDark)
                              .copyWith(
                            color: AppColors.getPrimary(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingLarge),

                  // Organizer Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.avatarSmall / 2,
                        backgroundColor:
                            AppColors.getPrimary(isDark).withOpacity(0.1),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.getPrimary(isDark),
                          size: AppSizes.iconSmall,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organized by',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                          Text(
                            event.organizerName,
                            style: AppTextStyles.titleMedium(isDark: isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingXxl),

                  // Event Details Cards
                  _buildDetailCard(
                    context,
                    isDark,
                    Icons.schedule_rounded,
                    'Date & Time',
                    '${DateFormat('EEEE, MMMM d, y').format(event.startTime)}\n${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                  ),
                  SizedBox(height: AppSizes.spacingLarge),

                  _buildDetailCard(
                    context,
                    isDark,
                    Icons.location_on_rounded,
                    'Location',
                    event.location,
                  ),
                  SizedBox(height: AppSizes.spacingLarge),

                  _buildDetailCard(
                    context,
                    isDark,
                    Icons.people_rounded,
                    'Attendees',
                    '${event.attendees.length} / ${event.maxAttendees == 0 ? '∞' : event.maxAttendees}',
                  ),
                  SizedBox(height: AppSizes.spacingLarge),

                  if (event.ticketPrice != null && event.ticketPrice! > 0) ...[
                    _buildDetailCard(
                      context,
                      isDark,
                      Icons.confirmation_number_rounded,
                      'Price',
                      'Starting From ₹${event.ticketPrice!.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: AppSizes.spacingLarge),
                  ],

                  // Description
                  Text(
                    'About this event',
                    style: AppTextStyles.headingSmall(isDark: isDark).copyWith(
                      fontSize: AppSizes.fontHeadline2,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingMedium),
                  Text(
                    event.description,
                    style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXxxl),

                  // Join Event Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement join event functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Join event functionality coming soon!',
                              style: AppTextStyles.bodyMedium(isDark: true)
                                  .copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppColors.getInfo(isDark),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                            margin: EdgeInsets.all(AppSizes.paddingLarge),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getPrimary(isDark),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLarge,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'JOIN EVENT',
                        style: AppTextStyles.button(isDark: isDark).copyWith(
                          color: Colors.white,
                          fontSize: AppSizes.fontLarge,
                          letterSpacing: AppSizes.letterSpacingExtraWide,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.getBorder(isDark).withOpacity(0.3),
          width: AppSizes.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppColors.getPrimary(isDark),
              size: AppSizes.iconMedium,
            ),
          ),
          SizedBox(width: AppSizes.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSizes.spacingXs),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}