// lib/features/bookings/presentation/screens/booking_details_screen.dart
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
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:printing/printing.dart';
import 'package:sync_event/features/bookings/presentation/utils/invoice_generator.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final BookingEntity booking;
  final EventEntity event;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: AppTextStyles.headingMedium(isDark: isDark),
        ),
        backgroundColor: AppColors.getPrimary(isDark),
        elevation: 0,
        actions: [
          if (booking.status == 'confirmed')
            IconButton(
              tooltip: 'Cancel & Refund',
              icon: Icon(
                Icons.cancel_outlined,
                color: AppColors.getError(isDark),
              ),
              onPressed: () async {
                final choice = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) {
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.account_balance_wallet_outlined),
                              title: const Text('Refund to Wallet'),
                              onTap: () => Navigator.pop(context, 'wallet'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.account_balance_outlined),
                              title: const Text('Refund to Bank'),
                              onTap: () => Navigator.pop(context, 'bank'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (choice == null) return;
                try {
                  await ref.read(bookingNotifierProvider.notifier).cancelBooking(
                        booking.id,
                        booking.paymentId,
                        booking.eventId,
                        refundType: choice,
                      );
                  ref.invalidate(userBookingsProvider(booking.userId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cancellation requested. Refund will be processed shortly.',
                          style: AppTextStyles.bodyMedium(isDark: true)
                              .copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.getSuccess(isDark),
                      ),
                    );
                  }
                  if (context.canPop()) context.pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error cancelling booking: $e',
                          style: AppTextStyles.bodyMedium(isDark: true)
                              .copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.getError(isDark),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium.w),
        child: Column(
          children: [
            // Event Card
            Card(
              color: AppColors.getCard(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
              ),
              elevation: AppSizes.cardElevationMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusMedium.r),
                    ),
                    child: event.imageUrl != null
                        ? Image.network(
                            event.imageUrl!,
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200.h,
                              color: AppColors.getSurface(isDark),
                              child: Icon(
                                Icons.event,
                                size: AppSizes.iconXxl.sp,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          )
                        : Container(
                            height: 200.h,
                            color: AppColors.getSurface(isDark),
                            child: Icon(
                              Icons.event,
                              size: AppSizes.iconXxl.sp,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: AppTextStyles.titleLarge(isDark: isDark),
                        ),
                        SizedBox(height: AppSizes.spacingSmall.h),
                        Text(
                          'Organized by: ${event.organizerName}',
                          style: AppTextStyles.bodyMedium(isDark: isDark),
                        ),
                        SizedBox(height: AppSizes.spacingSmall.h),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: DateFormat('EEEE, MMMM d, y').format(booking.startTime),
                          isDark: isDark,
                        ),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value:
                              '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                          isDark: isDark,
                        ),
                        _buildDetailRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: event.location,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium.h),
            // Booking Details Card
            Card(
              color: AppColors.getCard(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
              ),
              elevation: AppSizes.cardElevationMedium,
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: AppTextStyles.headingSmall(isDark: isDark),
                    ),
                    SizedBox(height: AppSizes.spacingMedium.h),
                    _buildDetailRow(
                      icon: Icons.confirmation_number,
                      label: 'Booking ID',
                      value: booking.id,
                      isDark: isDark,
                    ),
                    _buildDetailRow(
                      icon: Icons.event_seat,
                      label: 'Ticket Type',
                      value: '${booking.ticketType.toUpperCase()} (x${booking.ticketQuantity})',
                      isDark: isDark,
                    ),
                    _buildDetailRow(
                      icon: Icons.chair,
                      label: 'Seat Numbers',
                      value: booking.seatNumbers.isNotEmpty
                          ? booking.seatNumbers.join(', ')
                          : 'Not assigned',
                      isDark: isDark,
                    ),
                    _buildDetailRow(
                      icon: Icons.payment,
                      label: 'Amount Paid',
                      value: '₹${booking.totalAmount.toStringAsFixed(2)}',
                      isDark: isDark,
                    ),
                    _buildDetailRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: booking.status.toUpperCase(),
                      isDark: isDark,
                    ),
                    _buildDetailRow(
                      icon: Icons.date_range,
                      label: 'Booking Date',
                      value: DateFormat('MMM d, y h:mm a').format(booking.bookingDate),
                      isDark: isDark,
                    ),
                    if (booking.cancellationDate != null)
                      _buildDetailRow(
                        icon: Icons.cancel,
                        label: 'Cancellation Date',
                        value: DateFormat('MMM d, y h:mm a').format(booking.cancellationDate!),
                        isDark: isDark,
                      ),
                    if (booking.refundAmount != null)
                      _buildDetailRow(
                        icon: Icons.money,
                        label: 'Refund Amount',
                        value: '₹${booking.refundAmount!.toStringAsFixed(2)}',
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSizes.spacingLarge.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightLarge.h,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final bytes = await InvoiceGenerator.generate(booking, event);
                        await Printing.layoutPdf(
                          onLayout: (_) async => bytes,
                          name: 'Invoice_${booking.id}.pdf',
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Download Invoice'),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.spacingMedium.w),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightLarge.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getPrimary(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: AppTextStyles.labelMedium(isDark: isDark)
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingSmall.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconMedium.sp,
            color: AppColors.getPrimary(isDark),
          ),
          SizedBox(width: AppSizes.spacingMedium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(isDark: isDark)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}