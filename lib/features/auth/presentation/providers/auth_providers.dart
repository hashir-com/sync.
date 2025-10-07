import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sync_event/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sync_event/features/auth/data/repositories/auth_repository.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import 'package:sync_event/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/signup_with_email_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_phone_number_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/send_password_reset_usecase.dart';

// Dependency providers
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => sl<SharedPreferences>(),
);

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => sl<NetworkInfo>(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
  ),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSourceImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use case providers
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>(
  (ref) => sl<LoginWithEmailUseCase>(),
);

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>(
  (ref) => sl<SignUpWithEmailUseCase>(),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => sl<SignOutUseCase>(),
);

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
  (ref) => sl<SignInWithGoogleUseCase>(),
);

final verifyPhoneNumberUseCaseProvider = Provider<VerifyPhoneNumberUseCase>(
  (ref) => sl<VerifyPhoneNumberUseCase>(),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => sl<VerifyOtpUseCase>(),
);

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => sl<SendPasswordResetUseCase>(),
);