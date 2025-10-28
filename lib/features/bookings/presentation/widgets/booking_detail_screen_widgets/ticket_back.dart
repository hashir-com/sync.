// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

// Widget for the back side of the ticket card
class TicketBack extends StatelessWidget {
  final BookingEntity booking;
  final EventEntity event;

  const TicketBack({super.key, required this.booking, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtils.isDark(context);

    // Build ticket back with details
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(isDark).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        child: Stack(
          children: [
            // Decorative header strip
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2E)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
            // Ticket details
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'BOOKING DETAILS',
                      style: _textStyle(
                        isDark,
                        10,
                        FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem(
                      'Time',
                      DateFormat('h:mm a').format(booking.startTime),
                      isDark,
                      makeValueWhite: true,
                    ),
                    SizedBox(height: 8),
                    _buildDetailItem(
                      'Location',
                      event.location.isNotEmpty
                          ? event.location.split(',').first
                          : 'Unknown',
                      isDark,
                    ),
                    SizedBox(height: 8),
                    _buildDetailItem(
                      'Amount',
                      '₹${booking.totalAmount.toStringAsFixed(0)}',
                      isDark,
                      highlight: true,
                    ),
                    SizedBox(height: 8),
                    _buildDetailItem(
                      'Status',
                      booking.status.isNotEmpty
                          ? booking.status.toUpperCase()
                          : 'N/A',
                      isDark,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tap to return →',
                      style: _textStyle(isDark, 9, null, italic: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for detail items
  Widget _buildDetailItem(
    String label,
    String value,
    bool isDark, {
    bool highlight = false,
    bool makeValueWhite = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: _textStyle(isDark, 9, FontWeight.w500, letterSpacing: 0.5),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: makeValueWhite
                ? Colors.white
                : highlight
                ? AppColors.getPrimary(isDark)
                : (isDark ? Colors.white : Colors.black87),
            fontSize: highlight ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Helper for consistent text styling
  TextStyle _textStyle(
    bool isDark,
    double fontSize,
    FontWeight? fontWeight, {
    double? letterSpacing,
    bool italic = false,
  }) {
    return TextStyle(
      color: isDark ? Colors.grey[400] : Colors.grey[600],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: italic ? FontStyle.italic : null,
    );
  }
}
