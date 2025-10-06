// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  PhoneAuthNotifier(this._verifyPhoneNumberUseCase, this._verifyOtpUseCase)
    : super(PhoneAuthState());

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
        (verificationId, resendToken) {
          if (!mounted) return; // prevent calling context if widget disposed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: state.phone,
                phoneAuthNotifier: this,
              ),
            ),
          );
        },
        (verificationId) {},
        (user) {
          if (!mounted) return;
          context.go('/home');
        },
        (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    }

    state = state.copyWith(loading: false);
  }

  Future<void> verifyOtp(String otp, BuildContext context) async {
    try {
      // Call your use case that internally calls AuthRemoteDataSource.verifyOtp
      final user = await _verifyOtpUseCase.call(otp);

      if (user != null) {
        // OTP is correct, navigate to home
        context.go('/home');
      } else {
        // OTP null case (safety)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } on Exception catch (e) {
      // Catch the exception thrown from verifyOtp in AuthRemoteDataSource
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
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
