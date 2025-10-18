import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class BookTicketUseCase implements UseCase<BookingEntity, BookingEntity> {
  final BookingRepository repository;

  BookTicketUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(BookingEntity params) async {
    return await repository.bookTicket(params);
  }
}