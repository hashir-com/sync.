import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/usecases/book_tickets_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:sync_event/features/bookings/domain/usecases/refund_to_razorpay_usecase.dart';
import 'package:sync_event/features/email/services/email_services.dart';
import 'package:sync_event/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sync_event/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;

// Provider for single booking operations (book, cancel)
final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<BookingEntity?>>((ref) {
      return BookingNotifier(
        di.sl<BookTicketUseCase>(),
        di.sl<CancelBookingUseCase>(),
        di.sl<RefundToRazorpayUseCase>(),
        di.sl<UpdateWalletUseCase>(),
        di.sl<GetUserBookingsUseCase>(),
      );
    });

// NEW: Provider for user bookings list
final userBookingsProvider = FutureProvider.family<List<BookingEntity>, String>(
  (ref, userId) async {
    if (userId.isEmpty) {
      return <BookingEntity>[];
    }

    final notifier = ref.read(bookingNotifierProvider.notifier);
    return await notifier.getUserBookings(userId);
  },
);

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final GetUserBookingsUseCase getUserBookingsUseCase;

  BookingNotifier(
    this.bookTicketUseCase,
    this.cancelBookingUseCase,
    this.refundToRazorpayUseCase,
    this.updateWalletUseCase,
    this.getUserBookingsUseCase,
  ) : super(const AsyncValue.data(null));

  Future<void> bookTicket(BookingEntity booking) async {
    state = const AsyncValue.loading();
    final result = await bookTicketUseCase(booking);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (booked) async {
        state = AsyncValue.data(booked);
        await _sendInvoiceEmail(booked);
      },
    );
  }

  Future<void> cancelBooking(
    String bookingId,
    String paymentId,
    String eventId,
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
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (success) async {
        final currentBooking = state.value;
        if (currentBooking != null) {
          await refundToRazorpayUseCase(
            RefundParams(
              paymentId: paymentId,
              amount: currentBooking.totalAmount,
            ),
          );
          await updateWalletUseCase(
            WalletEntity(
              userId: currentBooking.userId,
              balance: currentBooking.totalAmount,
            ),
          );
          await _sendCancellationEmail(currentBooking);
          state = const AsyncValue.data(null); // Reset state
        }
      },
    );
  }

  Future<List<BookingEntity>> getUserBookings(String userId) async {
    final result = await getUserBookingsUseCase(Params(userId: userId));
    return result.fold((failure) => <BookingEntity>[], (bookings) => bookings);
  }

  Future<void> _sendInvoiceEmail(BookingEntity booking) async {
    await EmailService.sendInvoice(
      booking.userId,
      booking.id,
      booking.totalAmount,
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
