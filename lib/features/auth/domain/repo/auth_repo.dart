import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';

abstract class AuthRepository {
  Future<UserEntity?> signUpWithEmail(String email, String password, String name);
  Future<UserEntity?> loginWithEmail(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> signInWithGoogle(bool forceAccountChooser);
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(UserEntity) verificationCompleted,
    Function(String) verificationFailed,
  );
  Future<UserEntity?> verifyOtp(String otp);
  Future<void> signOut();
}