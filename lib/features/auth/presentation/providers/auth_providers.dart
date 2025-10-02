import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// State for login
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

/// Login controller
class AuthController extends StateNotifier<LoginState> {
  AuthController() : super(LoginState());

  /// Email/password login
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: "Please enter email and password");
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: e.message ?? "Login failed");
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, LoginState>((ref) {
  return AuthController();
});
