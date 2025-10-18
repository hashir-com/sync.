import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/usecases/book_tickets_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/process_refund_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/refund_to_razorpay_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/request_refund_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<BookingEntity?>>((ref) {
  return BookingNotifier(
    di.sl<BookTicketUseCase>(),
    di.sl<CancelBookingUseCase>(),
    di.sl<RefundToRazorpayUseCase>(),
    di.sl<RequestRefundUseCase>(),
    ref,
  );
});

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final RequestRefundUseCase requestRefundUseCase;
  final StateNotifierProviderRef<BookingNotifier, AsyncValue<BookingEntity?>> ref;

  BookingNotifier(
    this.bookTicketUseCase,
    this.cancelBookingUseCase,
    this.refundToRazorpayUseCase,
    this.requestRefundUseCase,
    this.ref,
  ) : super(const AsyncValue.data(null));

  Future<void> bookTicket(BookingEntity booking, String paymentId) async {
    state = const AsyncValue.loading();

    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email;

    if (email == null) {
      state = AsyncValue.error('User email not available', StackTrace.current);
      return;
    }

    final bookingWithPayment = BookingEntity(
      id: booking.id,
      userId: booking.userId,
      eventId: booking.eventId,
      ticketType: booking.ticketType,
      ticketQuantity: booking.ticketQuantity,
      totalAmount: booking.totalAmount,
      paymentId: paymentId,
      seatNumbers: booking.seatNumbers,
      bookingDate: booking.bookingDate,
      startTime: booking.startTime,
      endTime: booking.endTime,
      status: 'confirmed',
      userEmail: email,
    );

    final result = await bookTicketUseCase(bookingWithPayment);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        print('Booking failed: $failure');
      },
      (booked) {
        state = AsyncValue.data(booked);
        ref.invalidate(userBookingsProvider(booked.userId));
      },
    );
  }

  Future<void> cancelBooking(
    String bookingId,
    String paymentId,
    String eventId, {
    String refundType = 'wallet',
  }) async {
    state = const AsyncValue.loading();

    try {
      // Step 1: Get booking details
      final getBookingUseCase = di.sl<GetBookingUseCase>();
      final bookingResult = await getBookingUseCase(bookingId);

      final booking = bookingResult.fold(
        (failure) => throw failure,
        (bookingEntity) => bookingEntity,
      );

      // Enforce 48-hour cancellation policy
      final now = DateTime.now();
      final hoursUntilStart = booking.startTime.difference(now).inHours;
      if (hoursUntilStart < 48) {
        throw Exception('Cannot cancel within 48 hours of event start');
      }

      // Step 2: Cancel the booking
      final cancelResult = await cancelBookingUseCase(
        CancelParams(
          bookingId: bookingId,
          paymentId: paymentId,
          eventId: eventId,
        ),
      );

      final cancelSuccess = cancelResult.fold(
        (failure) => throw failure,
        (_) => true,
      );

      if (!cancelSuccess) {
        throw Exception('Failed to cancel booking');
      }

      // Step 3: Process refund based on type
      final processRefundUseCase = di.sl<ProcessRefundUseCase>();
      final refundResult = await processRefundUseCase(
        ProcessRefundParams(
          userId: booking.userId,
          bookingId: bookingId,
          paymentId: paymentId,
          amount: booking.totalAmount,
          refundType: refundType,
        ),
      );

      refundResult.fold(
        (failure) => throw failure,
        (_) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            ref.invalidate(userBookingsProvider(currentUser.uid));
          }
          state = const AsyncValue.data(null);
          print('✓ Booking cancelled and refund processed: $refundType');
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print('Error in cancelBooking: $e');
    }
  }
}

final userBookingsProvider = FutureProvider.family<List<BookingEntity>, String>(
  (ref, userId) async {
    final useCase = di.sl<GetUserBookingsUseCase>();
    final result = await useCase(GetUserBookingsParams(userId: userId));

    return result.fold(
      (failure) {
        print('Failed to fetch bookings: $failure');
        return <BookingEntity>[];
      },
      (bookings) => bookings,
    );
  },
);