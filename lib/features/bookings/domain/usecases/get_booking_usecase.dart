import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class GetBookingUseCase implements UseCase<BookingEntity, String> {
  final BookingRepository repository;

  GetBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(String bookingId) async {
    return await repository.getBooking(bookingId);
  }
}