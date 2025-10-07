import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class VerifyOtpUseCase implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String otp;

  const VerifyOtpParams({required this.otp});

  @override
  List<Object> get props => [otp];
}
