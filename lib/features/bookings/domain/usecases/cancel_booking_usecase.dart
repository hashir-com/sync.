import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class CancelBookingUseCase implements UseCase<void, CancelParams> {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelParams params) async {
    return await repository.cancelBooking(params.bookingId, params.paymentId);
  }
}

class CancelParams extends Equatable {
  final String bookingId;
  final String paymentId;
  final String eventId;

  const CancelParams({
    required this.bookingId,
    required this.paymentId,
    required this.eventId,
  });

  @override
  List<Object> get props => [bookingId, paymentId, eventId];
}