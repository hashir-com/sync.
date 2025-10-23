// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/presentation/utils/booking_utils.dart';
import 'package:sync_event/features/bookings/presentation/widgets/my_booking_screen_widgets/my_bookings_dialogs.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/bookings/presentation/providers/booking_provider.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_notifier.dart';

class CancelButton extends ConsumerWidget {
  final BookingEntity booking;
  final EventEntity event;
  final String userId;

  const CancelButton({
    super.key,
    required this.booking,
    required this.event,
    required this.userId,
  });

  Future<void> _showCancellationFlow(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) async {
    final eligible = BookingUtils.isEligibleForCancellation(booking.startTime);
    if (!eligible) {
      _showIneligibleSnackBar(context, isDark);
      return;
    }

    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CancellationReasonDialog(isDark: isDark),
    );
    if (reason == null) return;

    final refundType = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RefundMethodDialog(isDark: isDark),
    );
    if (refundType == null) return;

    await _processCancellation(context, ref, refundType, reason);
  }

  Future<void> _processCancellation(
    BuildContext context,
    WidgetRef ref,
    String refundType,
    String reason,
  ) async {
    try {
      await ref
          .read(bookingNotifierProvider.notifier)
          .cancelBooking(
            bookingId: booking.id,
            paymentId: booking.paymentId,
            eventId: booking.eventId,
            userId: userId,
            refundType: refundType,
            cancellationReason: reason,
          );

      await EmailService.sendDetailedCancellationEmail(
        userId: userId,
        bookingId: booking.id,
        eventTitle: event.title,
        refundAmount: booking.totalAmount,
        refundType: refundType,
        cancellationReason: reason,
      );

      ref.invalidate(userBookingsProvider(userId));
      ref.invalidate(walletNotifierProvider);

      if (context.mounted) {
        _showSuccessSnackBar(context, booking.totalAmount, refundType);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  void _showSuccessSnackBar(
    BuildContext context,
    double amount,
    String refundType,
  ) {
    final message = refundType == 'wallet'
        ? '✓ Booking cancelled!\n₹${amount.toStringAsFixed(0)} added to your wallet'
        : '✓ Booking cancelled!\nRefund will be processed to your bank account in 5-7 business days';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getSuccess(ThemeUtils.isDark(context)),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error cancelling booking: $error',
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getError(ThemeUtils.isDark(context)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }

  void _showIneligibleSnackBar(BuildContext context, bool isDark) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cannot cancel within 48 hours of event start.',
          style: AppTextStyles.bodyMedium(
            isDark: true,
          ).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.getError(isDark),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showCancellationFlow(context, ref, isDark),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.getError(isDark)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        ),
        child: Text(
          'Cancel Booking',
          style: AppTextStyles.labelMedium(
            isDark: isDark,
          ).copyWith(color: AppColors.getError(isDark)),
        ),
      ),
    );
  }
}
