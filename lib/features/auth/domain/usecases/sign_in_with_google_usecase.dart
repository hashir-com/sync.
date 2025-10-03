import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<bool> call(bool forceAccountChooser) async {
    return await repository.signInWithGoogle(forceAccountChooser);
  }
}