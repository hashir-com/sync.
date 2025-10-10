import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/entities/user_entity.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserEntity? user;

  AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, UserEntity? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthNotifier(this._signInWithGoogleUseCase, this._signOutUseCase)
    : super(AuthState());

  Future<bool> signInWithGoogle({bool forceAccountChooser = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final params = GoogleSignInParams(
        forceAccountChooser: forceAccountChooser,
      );
      final result = await _signInWithGoogleUseCase.call(params);
      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
          return false;
        },
        (userEntity) {
          state = state.copyWith(isLoading: false, user: userEntity);
          return true;
        },
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapFirebaseAuthException(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase.call();
    state = AuthState();
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Account exists with different credentials.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'User account is disabled.';
      case 'user-not-found':
        return 'User not found.';
      default:
        return 'Authentication failed: ${e.message ?? "An error occurred"}';
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.read(signInWithGoogleUseCaseProvider),
    ref.read(signOutUseCaseProvider),
  ),
);
