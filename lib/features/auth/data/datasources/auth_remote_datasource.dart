import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  String? _verificationId;
  int? _resendToken;

  Future<User?> signUpWithEmail(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<User?> loginWithEmail(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> signInWithGoogle(bool forceAccountChooser) async {
    try {
      final GoogleSignInAccount? googleUser = forceAccountChooser
          ? await _googleSignIn.signIn()
          : await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: _resendToken,
    );
  }

  Future<User?> verifyOtp(String otp) async {
  if (_verificationId == null) return null;

  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-verification-code') {
      // Handle invalid OTP
      throw Exception('Invalid OTP. Please try again.');
    } else {
      throw Exception(e.message ?? 'An error occurred.');
    }
  } on PlatformException catch (e) {
    // Catch the native invalid OTP error
    if (e.code == 'ERROR_INVALID_VERIFICATION_CODE' ||
        e.code == 'invalid-verification-code') {
      throw Exception('Invalid OTP. Please try again.');
    } else {
      throw Exception(e.message ?? 'An unexpected error occurred.');
    }
  } catch (e) {
    throw Exception('An unexpected error occurred.');
  }
}


  Future<User?> signInWithCredential(PhoneAuthCredential credential) async {
    final userCred = await _auth.signInWithCredential(credential);
    return userCred.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> updateUserName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> updateProfilePhoto(String? url) async {
    await _auth.currentUser?.updatePhotoURL(url);
  }
}