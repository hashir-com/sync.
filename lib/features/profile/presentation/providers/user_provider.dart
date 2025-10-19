// ignore_for_file: unnecessary_underscores

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stream provider that listens to auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for current user (synchronous access)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => FirebaseAuth.instance.currentUser,
    error: (_, __) => null,
  );
});

// State notifier for profile updates
class ProfileState {
  final bool isLoading;
  final String? error;
  final bool updateSuccess;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? updateSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  Future<bool> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, error: null, updateSuccess: false);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No user logged in',
        );
        return false;
      }

      // Update display name
      await user.updateDisplayName(displayName.trim());
      
      // Update photo URL if provided
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload user to get fresh data
      await user.reload();

      state = state.copyWith(
        isLoading: false,
        updateSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void resetState() {
    state = ProfileState();
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});