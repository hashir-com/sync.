import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/data/repositories/auth_repository.dart';
import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import 'package:sync_event/features/auth/domain/usecases/signup_with_email_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthRemoteDataSource()),
);

final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>(
  (ref) => LoginWithEmailUseCase(ref.read(authRepositoryProvider)),
);

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.read(authRepositoryProvider)),
);

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>(
  (ref) => SignUpWithEmailUseCase(ref.read(authRepositoryProvider)),
);

class LoginState {
  final bool isLoading;
  final String? errorMessage;

  LoginState({this.isLoading = false, this.errorMessage});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<LoginState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;

  AuthController(this._loginWithEmailUseCase) : super(LoginState());

  Future<UserEntity?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: "Please enter email and password");
      return null;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _loginWithEmailUseCase.call(
        email.trim(),
        password.trim(),
      );
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      print(e);

      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, LoginState>(
      (ref) => AuthController(ref.read(loginWithEmailUseCaseProvider)),
    );
