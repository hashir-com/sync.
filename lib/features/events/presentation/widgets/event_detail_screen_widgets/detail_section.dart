import 'package:flutter/material.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/widgets/event_detail_screen_widgets/booking_button.dart';
import 'package:sync_event/features/events/presentation/widgets/event_detail_screen_widgets/going_section.dart';
import 'package:sync_event/features/events/presentation/widgets/event_detail_screen_widgets/organizer_tile.dart';
import 'package:sync_event/features/events/presentation/widgets/event_detail_screen_widgets/share_tile.dart';
import 'package:sync_event/features/events/presentation/widgets/event_detail_screen_widgets/detail_tile.dart';

// Widget for the white card section with event details
class DetailSection extends StatelessWidget {
  final EventEntity event;
  final bool isOrganizer;
  final bool isDark;

  const DetailSection({
    super.key,
    required this.event,
    required this.isOrganizer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Build detail section with padding
    return Container(
      color: AppColors.getCard(isDark),
      child: Padding(
        padding: ResponsiveUtil.getResponsivePadding(
          context,
        ).copyWith(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GoingSection(isDark: isDark),
            // SizedBox(height: AppSizes.spacingLarge),
            Text(
              event.title,
              style: AppTextStyles.headingLarge(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingXxl),
            DetailTile(
              icon: Icons.calendar_today_rounded,
              title: event.formattedDate,
              subtitle: event.formattedDayTime,
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            DetailTile(
              icon: Icons.access_time_rounded,
              title: 'Duration',
              subtitle: event.formattedDuration,
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            DetailTile(
              icon: Icons.location_on_rounded,
              title: event.location,
              subtitle: event.locationSubtitle,
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            OrganizerTile(
              organizerName: event.organizerName,
              organizerImageUrl: '',
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            ShareTile(isDark: isDark),
            SizedBox(height: AppSizes.spacingXxl),
            Text(
              'About Event',
              style: AppTextStyles.titleMedium(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              event.description,
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
            SizedBox(height: AppSizes.spacingXxl),
            BookingButton(
              eventId: event.id,
              isOrganizer: isOrganizer,
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.spacingLarge),
          ],
        ),
      ),
    );
  }
}
