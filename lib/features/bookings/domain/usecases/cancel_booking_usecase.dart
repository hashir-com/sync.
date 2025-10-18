import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class CancelBookingUseCase implements UseCase<Unit, CancelParams> {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CancelParams params) async {
    final bookingResult = await repository.getBooking(params.bookingId);
    if (bookingResult.isLeft()) return Left(bookingResult.fold((l) => l, (r) => null)!);

    final booking = bookingResult.getOrElse(() => throw UnknownFailure(message: 'Booking not found'));
    final eventResult = await repository.getEvent(params.eventId);
    if (eventResult.isLeft()) return Left(eventResult.fold((l) => l, (r) => null)!);

    final event = eventResult.getOrElse(() => throw UnknownFailure(message: 'Event not found'));
    // Allow cancellation only if more than 48 hours remain before event start
    final hoursUntilStart = booking.startTime.difference(DateTime.now()).inHours;
    if (hoursUntilStart < 48) {
      return Left(ValidationFailure(message: 'Cancellation not allowed within 48 hours of event start'));
    }
    // Additional validation (e.g., event status)
    if (event.status != 'approved') {
      return Left(ValidationFailure(message: 'Cannot cancel booking for an unapproved or cancelled event'));
    }
    return await repository.cancelBooking(params.bookingId, params.paymentId);
  }
}

class CancelParams {
  final String bookingId;
  final String paymentId;
  final String eventId;

  CancelParams({
    required this.bookingId,
    required this.paymentId,
    required this.eventId,
  });
}