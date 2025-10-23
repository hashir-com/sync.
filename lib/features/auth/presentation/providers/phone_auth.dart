// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/error/failures.dart';
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
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) digits = digits.substring(0, 10);
    state = state.copyWith(phone: digits, autoValidate: true);
  }

  Future<void> sendOtp(BuildContext context) async {
    state = state.copyWith(autoValidate: true, loading: true);
    if (kDebugMode) {
      print('Sending OTP for phone: +91${state.phone}');
    } // Debug print

    if (state.phone.length != 10) {
      if (kDebugMode) {
        print('Invalid phone number length: ${state.phone.length}');
      } // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      state = state.copyWith(loading: false);
      return;
    }

    try {
      final result = await _verifyPhoneNumberUseCase.call(
        VerifyPhoneParams(
          phoneNumber: '+91${state.phone}',
          codeSent: (verificationId, resendToken) async {
            print('Code sent, verificationId: $verificationId'); // Debug print
            // Store verificationId
            if (!context.mounted) {
              print('Context not mounted, aborting navigation'); // Debug print
              return;
            }
            // Ensure shimmer is visible for at least 2 seconds

            if (context.mounted) {
              print('Navigating to OtpVerificationScreen'); // Debug print
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(
                    phoneNumber: state.phone,
                    phoneAuthNotifier: this,
                  ),
                ),
              );
              state = state.copyWith(loading: false);
            } else {
              print('Context not mounted after delay'); // Debug print
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {
            print(
              'Code auto-retrieval timeout: $verificationId',
            ); // Debug print
          },
          verificationCompleted: (user) {
            print('Verification completed, user: ${user.uid}'); // Debug print
            if (!context.mounted) return;
            state = state.copyWith(loading: false);
            context.go('/root');
          },
          verificationFailed: (error) {
            print('Verification failed: $error'); // Debug print
            if (!context.mounted) return;
            state = state.copyWith(loading: false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: $error')),
            );
          },
        ),
      );

      result.fold(
        (failure) {
          print(
            'VerifyPhoneNumberUseCase failed: ${failure.message}',
          ); // Debug print
          if (!context.mounted) return;
          state = state.copyWith(loading: false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (success) {
          print('VerifyPhoneNumberUseCase succeeded'); // Debug print
          // Success is handled in codeSent callback
        },
      );
    } catch (e) {
      print('Error in sendOtp: $e'); // Debug print
      if (!context.mounted) return;
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    }
  }

  Future<void> verifyOtp(String otp, BuildContext context) async {
    state = state.copyWith(loading: true);
    print('Verifying OTP: $otp'); // Debug print
    try {
      final result = await _verifyOtpUseCase.call(VerifyOtpParams(otp: otp));
      result.fold(
        (failure) {
          print('VerifyOtpUseCase failed: ${failure.message}'); // Debug print
          String errorMessage;
          switch (failure.runtimeType) {
            case const (AuthFailure):
              errorMessage = 'Authentication failed. Please try again.';
              break;
            case const (ServerFailure):
              errorMessage = 'Server error. Please try again later.';
              break;
            case NetworkFailure _:
              errorMessage =
                  'No internet connection. Please check your network.';
              break;
            default:
              errorMessage = 'An unexpected error occurred. Please try again.';
          }
          state = state.copyWith(loading: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        (user) {
          print('OTP verified, user: ${user.uid}'); // Debug print
          _phoneController?.clear();
          state = state.copyWith(
            loading: false,
            phone: '',
            autoValidate: false,
          );
          context.go('/root');
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP. Please enter the correct OTP.';
          break;
        case 'session-expired':
          errorMessage = 'The OTP has expired. Please request a new one.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification ID. Please request a new OTP.';
          break;
        case 'credential-already-in-use':
          errorMessage =
              'This phone number is already linked to another account.';
          break;
        default:
          errorMessage = 'Failed to verify OTP. Please try again.';
      }
      print(
        'FirebaseAuthException in verifyOtp: $errorMessage (code: ${e.code})',
      ); // Debug print
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } on PlatformException catch (e) {
      String errorMessage;
      if (e.code == 'ERROR_INVALID_VERIFICATION_CODE' ||
          e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP. Please enter the correct OTP.';
      } else if (e.code == 'ERROR_SESSION_EXPIRED') {
        errorMessage = 'The OTP has expired. Please request a new one.';
      } else {
        errorMessage = 'Failed to verify OTP. Please try again.';
      }
      print(
        'PlatformException in verifyOtp: $errorMessage (code: ${e.code})',
      ); // Debug print
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Unexpected error in verifyOtp: $e'); // Debug print
      state = state.copyWith(loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$e",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signOut() async {
    print('Signing out'); // Debug print
    try {
      await FirebaseAuth.instance.signOut();
      state = state.copyWith(phone: '', autoValidate: false);
      _phoneController?.clear();
    } catch (e) {
      print('Error in signOut: $e'); // Debug print
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
