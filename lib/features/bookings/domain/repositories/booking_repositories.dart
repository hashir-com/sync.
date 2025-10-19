import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> bookTicket(BookingEntity booking);
  Future<Either<Failure, void>> cancelBooking(String bookingId, String paymentId);
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId);
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(String userId);
  Future<Either<Failure, void>> processRefund(
      String userId, String bookingId, String paymentId, double amount, String refundType, String? reason);
  Future<Either<Failure, void>> requestRefund(String bookingId, String refundType);
  Future<Either<Failure, void>> refundToRazorpay(String paymentId, double amount);
}