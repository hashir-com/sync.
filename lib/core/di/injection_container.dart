import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_event/core/network/network_info.dart';
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
import 'package:sync_event/features/events/data/datasources/event_local_datasource.dart';
import 'package:sync_event/features/events/data/datasources/event_remote_datasource.dart';
import 'package:sync_event/features/events/data/repositories/event_repository_impl.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';
import 'package:sync_event/features/events/domain/usecases/create_event_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/get_events_usecase.dart';
import 'package:sync_event/features/events/domain/usecases/join_event_usecase.dart';
import 'package:sync_event/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:sync_event/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:sync_event/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';
import 'package:sync_event/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:sync_event/features/profile/domain/usecases/update_user_profile_usecase.dart';

// import 'core/network/network_info.dart';
// import 'core/error/failures.dart';

// // Auth feature
// import 'features/auth/data/datasources/auth_remote_datasource.dart';
// import 'features/auth/data/datasources/auth_local_datasource.dart';
// import 'features/auth/data/repositories/auth_repository.dart';
// import 'features/auth/domain/repo/auth_repo.dart';
// import 'features/auth/domain/usecases/login_with_email_usecase.dart';
// import 'features/auth/domain/usecases/signup_with_email_usecase.dart';
// import 'features/auth/domain/usecases/sign_out_usecase.dart';
// import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
// import 'features/auth/domain/usecases/verify_phone_number_usecase.dart';
// import 'features/auth/domain/usecases/verify_otp_usecase.dart';
// import 'features/auth/domain/usecases/send_password_reset_usecase.dart';

// // Profile feature
// import 'features/profile/data/datasources/profile_remote_datasource.dart';
// import 'features/profile/data/datasources/profile_local_datasource.dart';
// import 'features/profile/data/repositories/profile_repository_impl.dart';
// import 'features/profile/domain/repositories/profile_repository.dart';
// import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
// import 'features/profile/domain/usecases/update_user_profile_usecase.dart';

// // Events feature
// import 'features/events/data/datasources/event_remote_datasource.dart';
// import 'features/events/data/datasources/event_local_datasource.dart';
// import 'features/events/data/repositories/event_repository_impl.dart';
// import 'features/events/domain/repositories/event_repository.dart';
// import 'features/events/domain/usecases/get_events_usecase.dart';
// import 'features/events/domain/usecases/create_event_usecase.dart';
// import 'features/events/domain/usecases/join_event_usecase.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Auth feature
  _initAuth();

  // Profile feature
  _initProfile();

  // Events feature
  _initEvents();
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firebaseFirestore: sl(),
      firebaseStorage: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPhoneNumberUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
}

void _initProfile() {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firebaseFirestore: sl(),
      firebaseStorage: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
}

void _initEvents() {
  // Data sources
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(
      firebaseFirestore: sl(),
      firebaseStorage: sl(),
    ),
  );

  sl.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl()));
  sl.registerLazySingleton(() => JoinEventUseCase(sl()));
}
