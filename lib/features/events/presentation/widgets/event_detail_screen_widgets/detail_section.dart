import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const DetailSection({super.key, required this.event, required this.isOrganizer});

  @override
  Widget build(BuildContext context) {
    // Build detail section with padding
    return Container(
      color: AppColors.getBackground(false),
      child: Padding(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GoingSection(),
            SizedBox(height: AppSizes.spacingLarge.h),
            Text(event.title, style: AppTextStyles.headingLarge(isDark: false)),
            SizedBox(height: AppSizes.spacingXxl.h),
            DetailTile(icon: Icons.calendar_today_rounded, title: event.formattedDate, subtitle: event.formattedDayTime),
            SizedBox(height: AppSizes.spacingMedium.h),
            DetailTile(icon: Icons.access_time_rounded, title: 'Duration', subtitle: event.formattedDuration),
            SizedBox(height: AppSizes.spacingMedium.h),
            DetailTile(icon: Icons.location_on_rounded, title: event.location, subtitle: event.locationSubtitle),
            SizedBox(height: AppSizes.spacingMedium.h),
            OrganizerTile( organizerName: event.organizerName),
            SizedBox(height: AppSizes.spacingMedium.h),
            ShareTile(),
            SizedBox(height: AppSizes.spacingXxl.h),
            Text('About Event', style: AppTextStyles.titleMedium(isDark: false)),
            SizedBox(height: AppSizes.spacingMedium.h),
            Text(event.description, style: AppTextStyles.bodyMedium(isDark: false)),
            SizedBox(height: AppSizes.spacingXxl.h),
            BookingButton(eventId: event.id, isOrganizer: isOrganizer),
            SizedBox(height: AppSizes.spacingLarge.h),
          ],
        ),
      ),
    );
  }
}