import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart' show UserEntity;
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<UserEntity?> call(String otp) async {
    return await repository.verifyOtp(otp);
  }
}