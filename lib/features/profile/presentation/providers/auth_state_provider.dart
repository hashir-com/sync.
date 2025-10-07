// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import 'package:sync_event/features/profile/presentation/screens/profile_screen.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  sl<AuthRepository>();
  // Use userChanges instead of authStateChanges to capture profile updates
  return firebase_auth.FirebaseAuth.instance.userChanges().map((user) {
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  });
});
