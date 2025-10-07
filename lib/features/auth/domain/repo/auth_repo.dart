import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String name,
    String? imagePath,
  );

  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, UserEntity>> signInWithGoogle(
    bool forceAccountChooser,
  );

  Future<Either<Failure, void>> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(UserEntity) verificationCompleted,
    Function(String) verificationFailed,
  );

  Future<Either<Failure, UserEntity>> verifyOtp(String otp);

  Future<Either<Failure, void>> signOut();

  Stream<Either<Failure, UserEntity?>> get authStateChanges;
}
