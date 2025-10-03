import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/usecases/signup_with_email_usecase.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';


class SignupState {
  final bool isLoading;
  final String? errorMessage;

  SignupState({this.isLoading = false, this.errorMessage});

  SignupState copyWith({bool? isLoading, String? errorMessage}) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SignupNotifier extends StateNotifier<SignupState> {
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;

  SignupNotifier(this._signUpWithEmailUseCase) : super(SignupState());

  Future<UserEntity?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match");
      return null;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _signUpWithEmailUseCase.call(email, password, name);
      return user;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final signupNotifierProvider = StateNotifierProvider<SignupNotifier, SignupState>(
  (ref) => SignupNotifier(ref.read(signUpWithEmailUseCaseProvider)),
);