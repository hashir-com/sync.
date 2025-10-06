// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:sync_event/features/auth/domain/usecases/verify_phone_number_usecase.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';
import 'package:sync_event/features/auth/presentation/screens/otp_verification_screen.dart';

class PhoneAuthState {
  final String phone;
  final bool loading;
  final bool autoValidate;

  PhoneAuthState({
    this.phone = '',
    this.loading = false,
    this.autoValidate = false,
  });

  PhoneAuthState copyWith({String? phone, bool? loading, bool? autoValidate}) {
    return PhoneAuthState(
      phone: phone ?? this.phone,
      loading: loading ?? this.loading,
      autoValidate: autoValidate ?? this.autoValidate,
    );
  }
}

class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  final VerifyPhoneNumberUseCase _verifyPhoneNumberUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  TextEditingController? _phoneController; // Store controller reference

  PhoneAuthNotifier(this._verifyPhoneNumberUseCase, this._verifyOtpUseCase)
      : super(PhoneAuthState());

  // Set controller from PhoneSignInScreen
  void setPhoneController(TextEditingController controller) {
    _phoneController = controller;
  }

  void updatePhone(String value) {
    String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length > 10)
      digits = digits.substring(2);
    if (digits.length > 10) digits = digits.substring(0, 10);
    state = state.copyWith(phone: digits, autoValidate: true);
  }

  Future<void> sendOtp(BuildContext context) async {
    state = state.copyWith(autoValidate: true, loading: true);

    if (state.phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      state = state.copyWith(loading: false);
      return;
    }

    try {
      await _verifyPhoneNumberUseCase.call(
        '+91${state.phone}',
        (verificationId, resendToken) async {
          if (!context.mounted) return;
          // Ensure shimmer is visible for at least 2 seconds
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  phoneNumber: state.phone,
                  phoneAuthNotifier: this,
                ),
              ),
            );
            // Set loading to false after navigation
            state = state.copyWith(loading: false);
          }
        },
        (verificationId) {},
        (user) {
          if (!context.mounted) return;
          state = state.copyWith(loading: false);
          context.go('/home');
        },
        (error) {
          if (!context.mounted) return;
          state = state.copyWith(loading: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  Future<void> verifyOtp(String otp, BuildContext context) async {
    state = state.copyWith(loading: true);
    try {
      final user = await _verifyOtpUseCase.call(otp);
      if (user != null) {
        _phoneController?.clear(); // Clear phone number before navigating to home
        state = state.copyWith(loading: false, phone: '', autoValidate: false);
        context.go('/home');
      } else {
        state = state.copyWith(loading: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP. Please enter the correct OTP.';
          break;
        case 'session-expired':
          errorMessage = 'The OTP has expired. Please request a new one.';
          break;
        default:
          errorMessage = 'OTP verification failed: ${e.message ?? "An error occurred"}';
      }
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } on PlatformException catch (e) {
      String errorMessage;
      if (e.code == 'ERROR_INVALID_VERIFICATION_CODE' || e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP. Please enter the correct OTP.';
      } else {
        errorMessage = 'OTP verification failed: ${e.message ?? "An error occurred"}';
      }
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred during OTP verification.')),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      state = state.copyWith(phone: '', autoValidate: false);
      _phoneController?.clear(); // Clear phone number on sign-out
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}

final phoneAuthProvider =
    StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>(
      (ref) => PhoneAuthNotifier(
        ref.read(verifyPhoneNumberUseCaseProvider),
        ref.read(verifyOtpUseCaseProvider),
      ),
    );

final verifyPhoneNumberUseCaseProvider = Provider<VerifyPhoneNumberUseCase>(
  (ref) => VerifyPhoneNumberUseCase(ref.read(authRepositoryProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.read(authRepositoryProvider)),
);