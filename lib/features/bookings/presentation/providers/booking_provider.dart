import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/usecases/book_tickets_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/process_refund_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/refund_to_razorpay_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/request_refund_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:sync_event/features/wallet/presentation/provider/wallet_provider.dart';
import 'package:uuid/uuid.dart';

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<BookingEntity?>>((ref) {
  return BookingNotifier(
    di.sl<BookTicketUseCase>(),
    di.sl<CancelBookingUseCase>(),
    di.sl<RefundToRazorpayUseCase>(),
    di.sl<RequestRefundUseCase>(),
    di.sl<GetBookingUseCase>(),
    di.sl<ProcessRefundUseCase>(),
    ref,
  );
});

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final RequestRefundUseCase requestRefundUseCase;
  final GetBookingUseCase getBookingUseCase;
  final ProcessRefundUseCase processRefundUseCase;
  final StateNotifierProviderRef<BookingNotifier, AsyncValue<BookingEntity?>> ref;

  BookingNotifier(
    this.bookTicketUseCase,
    this.cancelBookingUseCase,
    this.refundToRazorpayUseCase,
    this.requestRefundUseCase,
    this.getBookingUseCase,
    this.processRefundUseCase,
    this.ref,
  ) : super(const AsyncValue.data(null));

  Future<void> bookTicket({
    required String eventId,
    required String userId,
    required String ticketType,
    required int ticketQuantity,
    required double totalAmount,
    required String paymentId,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> seatNumbers,
    required String userEmail,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Validate inputs
      if (eventId.isEmpty) {
        throw 'Event ID cannot be empty';
      }
      if (userId.isEmpty) {
        throw 'User ID cannot be empty';
      }
      if (paymentId.isEmpty) {
        throw 'Payment ID cannot be empty';
      }
      if (ticketType.isEmpty) {
        throw 'Ticket type cannot be empty';
      }
      if (ticketQuantity <= 0) {
        throw 'Ticket quantity must be positive';
      }
      if (userEmail.isEmpty) {
        throw 'User email cannot be empty';
      }

      // Generate unique booking ID
      const uuid = Uuid();
      final bookingId = uuid.v4();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.email != userEmail) {
        throw 'User not authenticated or email mismatch';
      }

      final booking = BookingEntity(
        id: bookingId,
        userId: userId,
        eventId: eventId,
        ticketType: ticketType,
        ticketQuantity: ticketQuantity,
        totalAmount: totalAmount,
        paymentId: paymentId,
        seatNumbers: seatNumbers,
        status: 'confirmed',
        bookingDate: DateTime.now(),
        startTime: startTime,
        endTime: endTime,
        userEmail: userEmail,
      );

      final result = await bookTicketUseCase(booking);
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
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print('Booking failed: $e');
    }
  }

  Future<void> cancelBooking(
  String bookingId,
  String paymentId,
  String eventId, {
  String refundType = 'wallet',
  String? reason,
}) async {
  state = const AsyncValue.loading();

  try {
    final bookingResult = await getBookingUseCase(bookingId);

    final booking = bookingResult.fold(
      (failure) => throw failure,
      (bookingEntity) => bookingEntity,
    );

    final now = DateTime.now();
    final hoursUntilStart = booking.startTime.difference(now).inHours;
    if (hoursUntilStart < 48) {
      throw Exception('Cannot cancel within 48 hours of event start');
    }

    // Use updated method signature
    final cancelResult = await cancelBookingUseCase(bookingId, paymentId);

    final cancelSuccess = cancelResult.fold(
      (failure) => throw failure,
      (_) => true,
    );

    if (!cancelSuccess) {
      throw Exception('Failed to cancel booking');
    }

    final refundResult = await processRefundUseCase(
      ProcessRefundParams(
        userId: booking.userId,
        bookingId: bookingId,
        paymentId: paymentId,
        amount: booking.totalAmount,
        refundType: refundType,
        reason: reason,
      ),
    );

    refundResult.fold(
      (failure) => throw failure,
      (_) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          ref.invalidate(userBookingsProvider(currentUser.uid));
          if (refundType == 'wallet') {
            ref.read(walletNotifierProvider.notifier).addRefund(
              userId: booking.userId,
              amount: booking.totalAmount,
              bookingId: bookingId,
              reason: reason ?? 'No reason provided',
            );
          }
          ref.invalidate(walletNotifierProvider);
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