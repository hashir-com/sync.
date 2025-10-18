import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class RefundToRazorpayUseCase implements UseCase<Unit, RefundParams> {
  final BookingRepository repository;

  RefundToRazorpayUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RefundParams params) async {
    return await repository.refundToRazorpay(params.paymentId, params.amount);
  }
}

class RefundParams {
  final String paymentId;
  final double amount;

  RefundParams({
    required this.paymentId,
    required this.amount,
  });
}