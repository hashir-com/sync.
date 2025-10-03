import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  Future<UserEntity?> call(String email, String password, String name) async {
    return await repository.signUpWithEmail(email, password, name);
  }
}