// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:sync_event/core/network/network_info.dart';

// Auth
import 'package:sync_event/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sync_event/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sync_event/features/auth/data/repositories/auth_repository.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import 'package:sync_event/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/signup_with_email_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_phone_number_usecase.dart';

// Events
import 'package:sync_event/features/events/data/datasources/event_local_datasource.dart';
import 'package:sync_event/features/events/data/datasources/event_remote_datasource.dart';
import 'package:sync_event/features/events/data/repositories/event_repository_impl.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/approved_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/join_event_usecase.dart';

// Profile
import 'package:sync_event/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:sync_event/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sync_event/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';
import 'package:sync_event/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/update_user_profile_usecase.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Features
  _initAuth();
  _initProfile();
  _initEvents();
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firebaseFirestore: sl<FirebaseFirestore>(),
      firebaseStorage: sl<FirebaseStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<LoginWithEmailUseCase>(
    () => LoginWithEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyPhoneNumberUseCase>(
    () => VerifyPhoneNumberUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendPasswordResetUseCase>(
    () => SendPasswordResetUseCase(sl<AuthRepository>()),
  );
}

void _initProfile() {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firebaseFirestore: sl<FirebaseFirestore>(),
      firebaseStorage: sl<FirebaseStorage>(),
    ),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () =>
        ProfileLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
      localDataSource: sl<ProfileLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl<ProfileRepository>()),
  );
}

void _initEvents() {
  // Data sources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(
      firebaseFirestore: sl<FirebaseFirestore>(),
      firebaseStorage: sl<FirebaseStorage>(),
    ),
  );

  sl.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl<EventRemoteDataSource>(),
      localDataSource: sl<EventLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<CreateEventUseCase>(
    () => CreateEventUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton<GetApprovedEventsUseCase>(
    () => GetApprovedEventsUseCase(sl<EventRepository>()),
  );
  sl.registerLazySingleton<JoinEventUseCase>(
    () => JoinEventUseCase(sl<EventRepository>()),
  );
}
