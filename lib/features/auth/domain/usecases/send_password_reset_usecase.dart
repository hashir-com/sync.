import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class SendPasswordResetUseCase {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<void> call(String email) async {
    await repository.sendPasswordResetEmail(email);
  }
}