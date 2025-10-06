import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/features/profile/domain/models/profile_model.dart';

abstract class ProfileRepository {
  Stream<User?> getUserChanges();
  Future<bool> updateProfile(ProfileModel profile);
}