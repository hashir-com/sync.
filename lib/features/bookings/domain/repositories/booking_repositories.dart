import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> bookTicket(BookingEntity booking);
  Future<Either<Failure, Unit>> cancelBooking(String bookingId, String paymentId);
  Future<Either<Failure, Unit>> refundToRazorpay(String paymentId, double amount);
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(String userId);
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId); // Added
  Future<Either<Failure, EventEntity>> getEvent(String eventId);
  Future<Either<Failure, Unit>> requestRefund(String bookingId, String refundType);
}