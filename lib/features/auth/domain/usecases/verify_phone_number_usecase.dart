import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class VerifyPhoneNumberUseCase {
  final AuthRepository repository;

  VerifyPhoneNumberUseCase(this.repository);

  Future<void> call(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(UserEntity) verificationCompleted,
    Function(String) verificationFailed,
  ) async {
    await repository.verifyPhoneNumber(
      phoneNumber,
      codeSent,
      codeAutoRetrievalTimeout,
      verificationCompleted,
      verificationFailed,
    );
  }
}