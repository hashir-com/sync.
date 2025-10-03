
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';

class LoginState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  LoginState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;

  LoginNotifier(this._loginWithEmailUseCase) : super(LoginState());

  Future<UserEntity?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _loginWithEmailUseCase.call(email, password);
      state = state.copyWith(isLoading: false, user: user);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final loginWithEmailUseCase = ref.watch(loginWithEmailUseCaseProvider);
  return LoginNotifier(loginWithEmailUseCase);
});

final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>(
  (ref) => LoginWithEmailUseCase(ref.read(authRepositoryProvider)),
);
