import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart' as di;
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

// Add to your providers file (booking_providers.dart)
final bookingsFilterProvider = StateNotifierProvider<BookingsFilterNotifier, BookingsFilterState>((ref) {
  return BookingsFilterNotifier();
});

class BookingsFilterState {
  final String searchQuery;
  final String statusFilter;
  final DateTimeRange? dateFilter;
  
  const BookingsFilterState({
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.dateFilter,
  });
  
  BookingsFilterState copyWith({
    String? searchQuery,
    String? statusFilter,
    DateTimeRange? dateFilter,
  }) {
    return BookingsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }
  
  bool get hasActiveFilters => searchQuery.isNotEmpty || statusFilter != 'all' || dateFilter != null;
}

class BookingsFilterNotifier extends StateNotifier<BookingsFilterState> {
  BookingsFilterNotifier() : super(const BookingsFilterState());
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
  
  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
  }
  
  void setDateFilter(DateTimeRange? range) {
    state = state.copyWith(dateFilter: range);
  }
  
  void clearFilters() {
    state = const BookingsFilterState();
  }
  
  void clearDateFilter() {
    state = state.copyWith(dateFilter: null);
  }
}

// Add this to your providers file (booking_providers.dart or similar)
final cancellationProvider = StateNotifierProvider<CancellationNotifier, CancellationState>((ref) {
  return CancellationNotifier();
});

class CancellationState {
  final String? reason;
  final String? refundType;
  final String notes;
  
  const CancellationState({
    this.reason,
    this.refundType,
    this.notes = '',
  });
  
  CancellationState copyWith({
    String? reason,
    String? refundType,
    String? notes,
  }) {
    return CancellationState(
      reason: reason ?? this.reason,
      refundType: refundType ?? this.refundType,
      notes: notes ?? this.notes,
    );
  }
}


class CancellationNotifier extends StateNotifier<CancellationState> {
  CancellationNotifier() : super(const CancellationState());
  
  void setReason(String? reason) {
    state = state.copyWith(reason: reason);
  }
  
  void setRefundType(String? refundType) {
    state = state.copyWith(refundType: refundType);
  }
  
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }
  
  void clear() {
    state = const CancellationState();
  }
}

class BookingNotifier extends StateNotifier<AsyncValue<BookingEntity?>> {
  final BookTicketUseCase bookTicketUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final RefundToRazorpayUseCase refundToRazorpayUseCase;
  final RequestRefundUseCase requestRefundUseCase;
  final GetBookingUseCase getBookingUseCase;
  final ProcessRefundUseCase processRefundUseCase;
  final StateNotifierProviderRef<BookingNotifier, AsyncValue<BookingEntity?>>
      ref;

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

  /// Unified cancellation method with proper refund handling
  Future<void> cancelBooking({
    required String bookingId,
    required String paymentId,
    required String eventId,
    required String userId,
    required String refundType, // 'wallet' or 'bank'
    required String cancellationReason,
  }) async {
    state = const AsyncValue.loading();

    try {
      print('BookingNotifier: Starting cancellation process');
      print('  Booking ID: $bookingId');
      print('  User ID: $userId');
      print('  Refund Type: $refundType');
      print('  Reason: $cancellationReason');

      // Step 1: Get booking details
      final bookingResult = await getBookingUseCase(bookingId);
      final booking = bookingResult.fold(
        (failure) => throw failure,
        (bookingEntity) => bookingEntity,
      );
      print('✓ Retrieved booking details');

      // Step 2: Cancel the booking (update status to cancelled, return tickets)
      final cancelResult = await cancelBookingUseCase(bookingId, paymentId);
      cancelResult.fold(
        (failure) => throw failure,
        (_) => null,
      );
      print('✓ Booking cancelled in Firestore');

      // Step 3: Process refund based on type
      final refundResult = await processRefundUseCase(
        ProcessRefundParams(
          userId: userId,
          bookingId: bookingId,
          paymentId: paymentId,
          amount: booking.totalAmount,
          refundType: refundType,
          reason: cancellationReason,
        ),
      );

      refundResult.fold(
        (failure) => throw failure,
        (_) {
          print('✓ Refund processed: $refundType');

          // Step 4: Refresh providers
          if (refundType == 'wallet') {
            print('  Invalidating wallet provider...');
            ref.invalidate(walletNotifierProvider);
          } else if (refundType == 'bank') {
            print('  Razorpay refund initiated (manual processing required)');
          }

          print('  Invalidating bookings provider...');
          ref.invalidate(userBookingsProvider(userId));

          state = const AsyncValue.data(null);
          print('✓ Cancellation completed successfully');
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      print('✗ Error in cancelBooking: $e');
      rethrow;
    }
  }
}

final userBookingsProvider =
    FutureProvider.family<List<BookingEntity>, String>(
  (ref, userId) async {
    final useCase = di.sl<GetUserBookingsUseCase>();
    final result = await useCase(GetUserBookingsParams(userId: userId));

    return result.fold(
      (failure) {
        print('Failed to fetch bookings: $failure');
        return <BookingEntity>[];
      },
      (bookings) {
        print('✓ Fetched ${bookings.length} bookings for user: $userId');
        return bookings;
      },
    );
  },
);