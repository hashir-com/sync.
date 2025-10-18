import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';

class LoginState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  LoginState({this.isLoading = false, this.user, this.errorMessage});

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
      final result = await _loginWithEmailUseCase.call(
        LoginParams(email: email, password: password),
      );
      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return null;
        },
        (user) {
          state = state.copyWith(isLoading: false, user: user);
          return null; // Return null here to avoid duplicate navigation
        },
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message ?? e.toString()}';
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) {
    final loginWithEmailUseCase = ref.watch(loginWithEmailUseCaseProvider);
    return LoginNotifier(loginWithEmailUseCase);
  },
);