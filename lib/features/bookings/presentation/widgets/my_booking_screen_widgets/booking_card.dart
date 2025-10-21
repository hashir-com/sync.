// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/cancel_button.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/error_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/image_placeholder.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/info_row.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/loading_card.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/status_badge.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

class BookingCard extends ConsumerWidget {
  final BookingEntity booking;
  final String userId;

  const BookingCard({super.key, required this.booking, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final eventStream = ref.watch(approvedEventsStreamProvider);
    final placeholderEvent = EventEntity(
      id: booking.eventId,
      title: 'Event Not Found',
      description: 'Event details unavailable',
      location: 'Unknown',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      organizerId: 'unknown',
      organizerName: 'Unknown Organizer',
      maxAttendees: 0,
      category: 'unknown',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      availableTickets: 0,
    );

    return eventStream.when(
      data: (events) {
        final event = events.isNotEmpty
            ? events.firstWhere((e) => e.id == booking.eventId, orElse: () => placeholderEvent)
            : placeholderEvent;
        return Card(
          elevation: AppSizes.cardElevationLow,
          color: AppColors.getCard(isDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r)),
          margin: EdgeInsets.only(bottom: AppSizes.spacingMedium.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
            onTap: () => context.push('/booking-details', extra: {'booking': booking, 'event': event}),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                        child: event.imageUrl != null
                            ? Image.network(
                                event.imageUrl!,
                                width: AppSizes.getImageSize(context, mobileSize: 80, tabletSize: 100, desktopSize: 120),
                                height: AppSizes.getImageSize(context, mobileSize: 80, tabletSize: 100, desktopSize: 120),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => ImagePlaceholder(),
                              )
                            : ImagePlaceholder(),
                      ),
                      SizedBox(width: AppSizes.spacingMedium.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: AppTextStyles.titleMedium(isDark: isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizes.spacingXs.h),
                            Text(
                              event.organizerName,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizes.spacingSmall.h),
                            StatusBadge(status: booking.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingMedium.h),
                  InfoRow(icon: Icons.calendar_today, label: DateFormat('MMM d, y').format(booking.startTime)),
                  SizedBox(height: AppSizes.spacingSmall.h),
                  InfoRow(icon: Icons.access_time, label: DateFormat('h:mm a').format(booking.startTime)),
                  SizedBox(height: AppSizes.spacingSmall.h),
                  InfoRow(icon: Icons.location_on, label: event.location),
                  SizedBox(height: AppSizes.spacingMedium.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ticket Type', style: AppTextStyles.labelSmall(isDark: isDark)),
                          SizedBox(height: AppSizes.spacingXs.h),
                          Text(
                            '${booking.ticketType.toUpperCase()} × ${booking.ticketQuantity}',
                            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total Amount', style: AppTextStyles.labelSmall(isDark: isDark)),
                          SizedBox(height: AppSizes.spacingXs.h),
                          Text(
                            '₹${booking.totalAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (booking.seatNumbers.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spacingMedium.h),
                    Text('Seats', style: AppTextStyles.labelSmall(isDark: isDark)),
                    SizedBox(height: AppSizes.spacingXs.h),
                    Wrap(
                      spacing: AppSizes.spacingSmall.w,
                      runSpacing: AppSizes.spacingXs.h,
                      children: booking.seatNumbers
                          .map((seat) => Container(
                                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall.w, vertical: AppSizes.paddingXs.h),
                                decoration: BoxDecoration(
                                  color: AppColors.getPrimary(isDark).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
                                ),
                                child: Text(
                                  seat,
                                  style: AppTextStyles.labelSmall(isDark: isDark).copyWith(color: AppColors.getPrimary(isDark)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if (booking.status == 'confirmed') ...[
                    SizedBox(height: AppSizes.spacingMedium.h),
                    CancelButton(booking: booking, event: event, userId: userId),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => LoadingCard(),
      error: (error, stack) => ErrorCard(),
    );
  }
}