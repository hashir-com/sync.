import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class RequestRefundUseCase implements UseCase<void, RequestRefundParams> {
  final BookingRepository repository;

  RequestRefundUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestRefundParams params) async {
    return await repository.requestRefund(params.bookingId, params.refundType);
  }
}

class RequestRefundParams extends Equatable {
  final String bookingId;
  final String refundType;

  const RequestRefundParams({
    required this.bookingId,
    required this.refundType,
  });

  @override
  List<Object> get props => [bookingId, refundType];
}