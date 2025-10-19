import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class RefundToRazorpayUseCase implements UseCase<void, RefundToRazorpayParams> {
  final BookingRepository repository;

  RefundToRazorpayUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RefundToRazorpayParams params) async {
    return await repository.refundToRazorpay(params.paymentId, params.amount);
  }
}

class RefundToRazorpayParams extends Equatable {
  final String paymentId;
  final double amount;

  const RefundToRazorpayParams({
    required this.paymentId,
    required this.amount,
  });

  @override
  List<Object> get props => [paymentId, amount];
}