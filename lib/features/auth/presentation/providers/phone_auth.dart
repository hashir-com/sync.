// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Step 1: Send OTP
  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) {
  _verificationId = verificationId;
  _resendToken = resendToken;

  // Navigate to OTP screen using phoneNumber and this AuthService instance
  context.go(
    '/otp',
    extra: {
      'phoneNumber': phoneNumber, // use the argument
      'authService': this,        // the current AuthService instance
    },
  );
},

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
    }
  }

  // Step 2: Verify OTP
  Future<UserCredential?> verifyOtp(String otp) async {
    if (_verificationId == null) return null;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      return await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('OTP Verification failed: ${e.message}');
      return null;
    }
  }

  Future<UserCredential> _signInWithCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }
}
