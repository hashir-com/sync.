import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/bookings/domain/repositories/booking_repositories.dart';

class ProcessRefundUseCase implements UseCase<void, ProcessRefundParams> {
  final BookingRepository repository;

  ProcessRefundUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ProcessRefundParams params) async {
    return await repository.processRefund(
      params.userId,
      params.bookingId,
      params.paymentId,
      params.amount,
      params.refundType,
      params.reason,
    );
  }
}

class ProcessRefundParams extends Equatable {
  final String userId;
  final String bookingId;
  final String paymentId;
  final double amount;
  final String refundType;
  final String? reason;

  const ProcessRefundParams({
    required this.userId,
    required this.bookingId,
    required this.paymentId,
    required this.amount,
    required this.refundType,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, bookingId, paymentId, amount, refundType, reason];
}