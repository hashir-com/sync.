// lib/features/bookings/presentation/providers/booking_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/usecases/book_tickets_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/refund_to_razorpay_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/request_refund_usecase.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sync_event/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<BookingEntity?>>((ref) {
      return BookingNotifier(
        di.sl<BookTicketUseCase>(),
        di.sl<CancelBookingUseCase>(),
        di.sl<RefundToRazorpayUseCase>(),
        di.sl<UpdateWalletUseCase>(),
        di.sl<RequestRefundUseCase>(),
        ref,
      );
    });

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final RequestRefundUseCase requestRefundUseCase;
  // ignore: deprecated_member_use
  final StateNotifierProviderRef<BookingNotifier, AsyncValue<BookingEntity?>>
  ref;

  BookingNotifier(
    this.bookTicketUseCase,
    this.cancelBookingUseCase,
    this.refundToRazorpayUseCase,
    this.updateWalletUseCase,
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

    // Include email in booking
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
      userEmail: email, // Save email in booking
    );

    final result = await bookTicketUseCase(bookingWithPayment);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        print('Booking failed: $failure');
      },
      (booked) async {
        state = AsyncValue.data(booked);
        ref.invalidate(userBookingsProvider(booked.userId)); // Refresh bookings
        // Confirmation email is sent by Cloud Function on booking creation
      },
    );
  }

  Future<void> cancelBooking(
    String bookingId,
    String paymentId,
    String eventId,
    {String refundType = 'wallet'},
  ) async {
    state = const AsyncValue.loading();
    final result = await cancelBookingUseCase(
      CancelParams(
        bookingId: bookingId,
        paymentId: paymentId,
        eventId: eventId,
      ),
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        print('Cancellation failed: $failure');
      },
      (success) async {
        // Defer refund processing to backend via refund request
        await requestRefundUseCase(
          RequestRefundParams(bookingId: bookingId, refundType: refundType),
        );
        // Note: backend Cloud Function will process refund and send emails
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          ref.invalidate(userBookingsProvider(currentUser.uid));
        }
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> _sendInvoiceEmail(BookingEntity booking) async {
    await EmailService.sendInvoice(
      booking.userId,
      booking.id,
      booking.totalAmount,
      booking.userEmail,
    );
  }

  Future<void> _sendCancellationEmail(BookingEntity booking) async {
    await EmailService.sendCancellationNotice(
      booking.userId,
      booking.id,
      booking.totalAmount,
    );
  }
}

// lib/features/bookings/presentation/providers/booking_provider.dart

final userBookingsProvider = FutureProvider.family<List<BookingEntity>, String>(
  (ref, userId) async {
    final useCase = di.sl<GetUserBookingsUseCase>();
    final result = await useCase(Params(userId: userId));

    return result.fold((failure) {
      print('Failed to fetch bookings: $failure');
      return <BookingEntity>[];
    }, (bookings) => bookings);
  },
);
