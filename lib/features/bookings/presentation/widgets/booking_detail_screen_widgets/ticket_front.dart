// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Widget for the front side of the ticket card
class TicketFront extends StatelessWidget {
  final BookingEntity booking;
  final EventEntity event;

  const TicketFront({super.key, required this.booking, required this.event});

  @override
  Widget build(BuildContext context) {
    // Build ticket card with gradient background
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(false).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.getPrimary(false),
                    AppColors.getPrimary(false).withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(top: -80, right: -80, child: _buildCircle(200)),
            Positioned(bottom: -60, left: -60, child: _buildCircle(180)),
            // Ticket content
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with ticket type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EVENT TICKET',
                        style: _textStyle(
                          12,
                          FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXxl,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          booking.ticketType.isNotEmpty
                              ? booking.ticketType.toUpperCase()
                              : 'N/A',
                          style: _textStyle(11, FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  // Event title and date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title.isNotEmpty ? event.title : 'Unknown Event',
                        style: _textStyle(24, FontWeight.w800, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, y').format(booking.startTime),
                        style: _textStyle(14, FontWeight.w500, opacity: 0.8),
                      ),
                    ],
                  ),
                  // Booking ID and quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.id.isNotEmpty
                            ? 'Booking ID: ${booking.id.substring(0, 8).toUpperCase()}'
                            : 'Booking ID: N/A',
                        style: _textStyle(
                          11,
                          FontWeight.w500,
                          opacity: 0.7,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty: ${booking.ticketQuantity}',
                            style: _textStyle(14, FontWeight.w700),
                          ),
                          Text(
                            'Tap to flip →',
                            style: _textStyle(
                              11,
                              null,
                              opacity: 0.6,
                              italic: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for decorative circles
  Widget _buildCircle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(size == 200 ? 0.1 : 0.08),
    ),
  );

  // Helper for consistent text styling
  TextStyle _textStyle(
    double fontSize,
    FontWeight? fontWeight, {
    double? opacity,
    double? letterSpacing,
    double? height,
    bool italic = false,
  }) {
    return TextStyle(
      color: Colors.white.withOpacity(opacity ?? 0.9),
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: italic ? FontStyle.italic : null,
    );
  }
}
