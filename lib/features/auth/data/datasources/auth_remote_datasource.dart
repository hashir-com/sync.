import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sync_event/core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<User?> signUpWithEmail(String email, String password);
  Future<User?> loginWithEmail(String email, String password);
  Future<void> updateUserName(String name);
  Future<void> updateProfilePhoto(String imageUrl);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> signInWithGoogle(bool forceAccountChooser);
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(User) verificationCompleted,
    Function(String) verificationFailed,
  );
  Future<User?> signInWithCredential(PhoneAuthCredential credential);
  Future<User?> verifyOtp(String otp);
  Future<void> signOut();
  Future<String> uploadProfileImage(File imageFile, String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  String? _verificationId; // Store verificationId for OTP verification

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<void> updateUserName(String name) async {
    await firebaseAuth.currentUser?.updateDisplayName(name);
  }

  @override
  Future<void> updateProfilePhoto(String imageUrl) async {
    await firebaseAuth.currentUser?.updatePhotoURL(imageUrl);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<bool> signInWithGoogle(bool forceAccountChooser) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (forceAccountChooser) {
      await googleSignIn.signOut(); // Forces account chooser
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return false; // User cancelled sign-in
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
    return userCredential.user != null;
  }

  @override
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(User) verificationCompleted,
    Function(String) verificationFailed,
  ) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final user = await signInWithCredential(credential);
        if (user != null) {
          verificationCompleted(user);
        }
      },
      verificationFailed: (e) => verificationFailed(e.message ?? 'Verification failed'),
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId; // Store verificationId
        codeSent(verificationId, forceResendingToken);
      },
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<User?> signInWithCredential(PhoneAuthCredential credential) async {
    final credentialResult = await firebaseAuth.signInWithCredential(credential);
    return credentialResult.user;
  }

  @override
  Future<User?> verifyOtp(String otp) async {
    if (_verificationId == null) {
      throw const ServerException(message: 'Verification ID not found');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut(); // Ensure Google Sign-In session clears
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    final ref = firebaseStorage.ref().child('users/$userId/profile.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}