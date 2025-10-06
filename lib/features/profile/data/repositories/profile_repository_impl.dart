import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sync_event/features/profile/domain/models/profile_model.dart';
import 'package:sync_event/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Stream<User?> getUserChanges() {
    return FirebaseAuth.instance.userChanges();
  }

  @override
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      String? photoURL = user.photoURL;
      if (profile.photoFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(user.uid);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': user.uid,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        );
        await storageRef.putFile(profile.photoFile!, metadata);
        photoURL = await storageRef.getDownloadURL();
      }

      await user.updateDisplayName(profile.displayName.trim());
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();
      return true;
    } catch (e) {
      return false;
    }
  }
}