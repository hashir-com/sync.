// lib/features/auth/presentation/providers/auth_state_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:sync_event/features/profile/presentation/providers/profile_providers.dart';

// Auth state provider that clears cache on logout
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return firebase_auth.FirebaseAuth.instance.userChanges().asyncMap((
    user,
  ) async {
    if (user == null) {
      // User logged out - clear cached profile data
      try {
        final localDataSource = sl<ProfileLocalDataSource>();
        await localDataSource.clearProfileData();
      } catch (e) {
        print('Error clearing profile cache: $e');
      }
      return null;
    }

    try {
      // Fetch full profile from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return UserModel.fromFirebaseUser(user);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return UserModel.fromFirebaseUser(user);
    }
  });
});

// Provider for current user (synchronous access)
final currentUserProvider = Provider<firebase_auth.User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => firebase_auth.FirebaseAuth.instance.currentUser,
    loading: () => firebase_auth.FirebaseAuth.instance.currentUser,
    error: (_, __) => null,
  );
});
