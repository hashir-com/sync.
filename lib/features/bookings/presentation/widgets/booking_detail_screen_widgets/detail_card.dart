// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/widgets/booking_detail_screen_widgets/detail_item.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Widget for detail sections (Booking, Event, Cancellation)
class DetailCard extends StatelessWidget {
  final BookingEntity booking;
  final EventEntity event;

  const DetailCard({super.key, required this.booking, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    // Build detail sections
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.getPrimary(isDark), borderRadius: BorderRadius.circular(2))),
            SizedBox(width: AppSizes.spacingMedium),
            Text('Full Details', style: AppTextStyles.headingSmall(isDark: isDark).copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        SizedBox(height: AppSizes.spacingLarge),
        // Booking information
        _buildCard('Booking Information', isDark, [
          DetailItem(icon: Icons.confirmation_number_outlined, label: 'Booking ID', value: booking.id.isNotEmpty ? booking.id : 'N/A', isDark: isDark),
          DetailItem(
            icon: Icons.event_seat_outlined,
            label: 'Ticket Type',
            value: booking.ticketType.isNotEmpty ? '${booking.ticketType.toUpperCase()} (x${booking.ticketQuantity})' : 'N/A',
            isDark: isDark,
          ),
          DetailItem(icon: Icons.payment_outlined, label: 'Total Amount', value: '₹${booking.totalAmount.toStringAsFixed(2)}', isDark: isDark),
          DetailItem(icon: Icons.calendar_month_outlined, label: 'Booking Date', value: DateFormat('MMM d, y h:mm a').format(booking.bookingDate), isDark: isDark),
        ]),
        SizedBox(height: AppSizes.spacingLarge),
        // Event information
        _buildCard('Event Information', isDark, [
          DetailItem(icon: Icons.location_on_outlined, label: 'Location', value: event.location.isNotEmpty ? event.location : 'Unknown', isDark: isDark),
          DetailItem(icon: Icons.access_time_outlined, label: 'Start Time', value: DateFormat('h:mm a').format(booking.startTime), isDark: isDark),
          DetailItem(icon: Icons.timelapse_rounded, label: 'End Time', value: DateFormat('h:mm a').format(booking.endTime), isDark: isDark),
        ]),
        // Cancellation details (if applicable)
        if (booking.status == 'cancelled') ...[
          SizedBox(height: AppSizes.spacingLarge),
          _buildCard('Cancellation Details', isDark, [
            if (booking.cancellationDate != null)
              DetailItem(
                icon: Icons.cancel_outlined,
                label: 'Cancelled On',
                value: DateFormat('MMM d, y h:mm a').format(booking.cancellationDate!),
                isDark: isDark,
              ),
            if (booking.refundAmount != null)
              DetailItem(
                icon: Icons.money_outlined,
                label: 'Refund Amount',
                value: '₹${booking.refundAmount!.toStringAsFixed(2)}',
                isDark: isDark,
              ),
          ]),
        ],
      ],
    );
  }

  // Helper to build detail card
  Widget _buildCard(String title, bool isDark, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.getPrimary(isDark).withOpacity(0.15)),
        boxShadow: [BoxShadow(color: AppColors.getPrimary(isDark).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: AppSizes.spacingMedium),
          ...List.generate(children.length, (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
                      child: Divider(color: AppColors.getBorder(isDark).withOpacity(0.2)),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}