import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class RequestRefundUseCase implements UseCase<Unit, RequestRefundParams> {
  final BookingRepository repository;

  RequestRefundUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RequestRefundParams params) {
    return repository.requestRefund(params.bookingId, params.refundType);
  }
}

class RequestRefundParams {
  final String bookingId;
  final String refundType; // 'wallet' or 'bank'

  RequestRefundParams({required this.bookingId, required this.refundType});
}
