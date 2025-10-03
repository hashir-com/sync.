
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this.dataSource, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> signUpWithEmail(
    String email,
    String password,
    String name,
    String? imagePath,
  ) async {
    try {
      final user = await dataSource.signUpWithEmail(email, password);
      if (user != null) {
        await dataSource.updateUserName(name);
        String? imageUrl;
        if (imagePath != null) {
          final file = File(imagePath);
          final extension = imagePath.split('.').last;
          final storageRef = FirebaseStorage.instance.ref('users/${user.uid}/profile.$extension');
          await storageRef.putFile(file);
          imageUrl = await storageRef.getDownloadURL();
          await dataSource.updateProfilePhoto(imageUrl);
        }
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'image': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return UserModel.fromFirebase(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  @override
  Future<UserEntity?> loginWithEmail(String email, String password) async {
    try {
      final user = await dataSource.loginWithEmail(email, password);
      return user != null ? UserModel.fromFirebase(user) : null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Login failed: ${e.message ?? "An error occurred"}';
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await dataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while sending password reset email.');
    }
  }

  @override
  Future<bool> signInWithGoogle(bool forceAccountChooser) async {
    try {
      return await dataSource.signInWithGoogle(forceAccountChooser);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during Google sign-in.');
    }
  }

  @override
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(UserEntity) verificationCompleted,
    Function(String) verificationFailed,
  ) async {
    try {
      await dataSource.verifyPhoneNumber(
        phoneNumber,
        codeSent,
        codeAutoRetrievalTimeout,
        (credential) async {
          final user = await dataSource.signInWithCredential(credential);
          if (user != null) {
            verificationCompleted(UserModel.fromFirebase(user));
          } else {
            verificationFailed('Failed to sign in with credential');
          }
        },
        (e) => verificationFailed(_mapFirebaseAuthException(e)),
      );
    } catch (e) {
      verificationFailed('An unexpected error occurred during phone verification.');
    }
  }

  @override
  Future<UserEntity?> verifyOtp(String otp) async {
    try {
      final user = await dataSource.verifyOtp(otp);
      return user != null ? UserModel.fromFirebase(user) : null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during OTP verification.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dataSource.signOut();
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out.');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching user data.');
    }
  }
}