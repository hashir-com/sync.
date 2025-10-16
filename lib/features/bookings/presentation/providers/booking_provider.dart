// lib/features/bookings/presentation/providers/booking_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/usecases/book_tickets_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/refund_to_razorpay_usecase.dart';
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
    ref,
  );
});

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final StateNotifierProviderRef<BookingNotifier, AsyncValue<BookingEntity?>> ref;

  BookingNotifier(
    this.bookTicketUseCase,
    this.cancelBookingUseCase,
    this.refundToRazorpayUseCase,
    this.updateWalletUseCase,
    this.ref,
  ) : super(const AsyncValue.data(null));

  Future<void> bookTicket(BookingEntity booking, String paymentId) async {
    state = const AsyncValue.loading();

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
        await _sendInvoiceEmail(booked);
      },
    );
  }

  Future<void> cancelBooking(String bookingId, String paymentId, String eventId) async {
    state = const AsyncValue.loading();
    final result = await cancelBookingUseCase(CancelParams(
      bookingId: bookingId,
      paymentId: paymentId,
      eventId: eventId,
    ));

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        print('Cancellation failed: $failure');
      },
      (success) async {
        final currentBooking = state.value;
        if (currentBooking != null) {
          await refundToRazorpayUseCase(RefundParams(
            paymentId: paymentId,
            amount: currentBooking.totalAmount,
          ));

          await updateWalletUseCase(WalletEntity(
            userId: currentBooking.userId,
            balance: currentBooking.totalAmount,
          ));

          await _sendCancellationEmail(currentBooking);

          ref.invalidate(userBookingsProvider(currentBooking.userId)); // Refresh bookings
          state = const AsyncValue.data(null);
        }
      },
    );
  }

  Future<void> _sendInvoiceEmail(BookingEntity booking) async {
    await EmailService.sendInvoice(
      booking.userId, // Should be updated to use email
      booking.id,
      booking.totalAmount,
    );
  }

  Future<void> _sendCancellationEmail(BookingEntity booking) async {
    await EmailService.sendCancellationNotice(
      booking.userId, // Should be updated to use email
      booking.id,
      booking.totalAmount,
    );
  }
}


final userBookingsProvider =
    FutureProvider.family<List<BookingEntity>, String>((ref, userId) async {
  final useCase = di.sl<GetUserBookingsUseCase>();
  final result = await useCase(Params(userId: userId));

  return result.fold(
    (failure) {
      print('Failed to fetch bookings: $failure');
      return <BookingEntity>[];
    },
    (bookings) => bookings,
  );
});