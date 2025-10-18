import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class GetUserBookingsUseCase implements UseCase<List<BookingEntity>, GetUserBookingsParams> {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(GetUserBookingsParams params) async {
    return await repository.getUserBookings(params.userId);
  }
}

class GetUserBookingsParams extends Equatable {
  final String userId;

  const GetUserBookingsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}