// lib/features/bookings/presentation/utils/booking_utils.dart

class BookingUtils {
  static bool isEligibleForCancellation(DateTime eventStartTime) {
    final now = DateTime.now();
    final difference = eventStartTime.difference(now);
    return difference.inHours >= 48;
  }

  static double calculateRefundAmount(double bookingAmount) {
    // Adjust fees here if needed. Currently full refund.
    return bookingAmount;
  }
}
