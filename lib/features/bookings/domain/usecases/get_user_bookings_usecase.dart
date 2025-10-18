import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class GetUserBookingsUseCase extends UseCase<List<BookingEntity>, Params> {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(Params params) {
    return repository.getUserBookings(params.userId);
  }
}