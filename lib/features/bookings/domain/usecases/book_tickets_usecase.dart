import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookTicketUseCase {
  final BookingRepository repository;
  final FirebaseAuth? auth;

  BookTicketUseCase(this.repository, this.auth);

  Future<Either<Failure, BookingEntity>> call(BookingEntity booking) async {
    if (auth == null) {
      print('BookTicketUseCase: FirebaseAuth is null');
      return Left(ServerFailure(message: 'FirebaseAuth not initialized'));
    }
    final userId = auth!.currentUser?.uid;
    if (userId == null) {
      print('BookTicketUseCase: User not authenticated');
      return Left(ServerFailure(message: 'User not authenticated'));
    }
    if (booking.userId != userId) {
      print('BookTicketUseCase: User ID mismatch - input=${booking.userId}, auth=$userId');
    }

    final bookingWithUserId = BookingEntity(
      id: booking.id,
      userId: userId,
      eventId: booking.eventId,
      ticketType: booking.ticketType,
      ticketQuantity: booking.ticketQuantity,
      totalAmount: booking.totalAmount,
      paymentId: booking.paymentId,
      seatNumbers: booking.seatNumbers,
      status: booking.status,
      bookingDate: booking.bookingDate,
      cancellationDate: booking.cancellationDate,
      refundAmount: booking.refundAmount,
      startTime: booking.startTime,
      endTime: booking.endTime,
      userEmail: booking.userEmail,
    );

    print('BookTicketUseCase: Booking with id=${booking.id}, userId=$userId');
    return await repository.bookTicket(bookingWithUserId);
  }
}