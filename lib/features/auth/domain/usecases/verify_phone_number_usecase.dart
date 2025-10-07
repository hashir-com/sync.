import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/usecases/usecase.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class VerifyPhoneNumberUseCase implements UseCase<void, VerifyPhoneParams> {
  final AuthRepository repository;

  VerifyPhoneNumberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyPhoneParams params) async {
    return await repository.verifyPhoneNumber(
      params.phoneNumber,
      params.codeSent,
      params.codeAutoRetrievalTimeout,
      params.verificationCompleted,
      params.verificationFailed,
    );
  }
}

class VerifyPhoneParams extends Equatable {
  final String phoneNumber;
  final Function(String, int?) codeSent;
  final Function(String) codeAutoRetrievalTimeout;
  final Function(UserEntity) verificationCompleted;
  final Function(String) verificationFailed;

  const VerifyPhoneParams({
    required this.phoneNumber,
    required this.codeSent,
    required this.codeAutoRetrievalTimeout,
    required this.verificationCompleted,
    required this.verificationFailed,
  });

  @override
  List<Object> get props => [phoneNumber];
}
