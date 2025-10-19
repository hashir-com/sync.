import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookingId, String paymentId) async {
    try {
      if (bookingId.isEmpty) {
        return Left(ServerFailure(message: 'Booking ID cannot be empty'));
      }
      if (paymentId.isEmpty) {
        return Left(ServerFailure(message: 'Payment ID cannot be empty'));
      }

      return await repository.cancelBooking(bookingId, paymentId);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to cancel booking: $e'));
    }
  }
}
