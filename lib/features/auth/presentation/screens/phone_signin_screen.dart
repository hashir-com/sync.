import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/presentation/providers/phone_auth.dart';

/// State class to hold phone input info
class PhoneAuthState {
  final String phone; // 10-digit number
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

/// Riverpod StateNotifier to manage phone auth state
class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  final AuthService _authService;

  PhoneAuthNotifier(this._authService) : super(PhoneAuthState());

  void updatePhone(String value) {
    // Remove any non-digit characters
    String digits = value.replaceAll(RegExp(r'\D'), '');

    // Remove leading 91 if pasted
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }

    // Limit to 10 digits
    if (digits.length > 10) digits = digits.substring(0, 10);

    state = state.copyWith(phone: digits, autoValidate: true);
  }

  Future<void> sendOtp(BuildContext context) async {
    state = state.copyWith(autoValidate: true);
    if (state.phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      return;
    }

    state = state.copyWith(loading: true);
    await _authService.verifyPhoneNumber('+91${state.phone}', context);
    state = state.copyWith(loading: false);
  }
}

/// Riverpod provider
final phoneAuthProvider =
    StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>(
      (ref) => PhoneAuthNotifier(AuthService()),
    );

/// Phone Sign-In Screen
class PhoneSignInScreen extends ConsumerWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(phoneAuthProvider);
    final authNotifier = ref.read(phoneAuthProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign in with Phone'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your phone number',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We will send you a One Time Password (OTP)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                autovalidateMode: authState.autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.w500),
                  hintText: 'Enter 10-digit phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  counterText: '',
                ),
                onChanged: authNotifier.updatePhone,
                initialValue: authState.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (authState.phone.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.loading
                      ? null
                      : () => authNotifier.sendOtp(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    backgroundColor: theme.primaryColor,
                  ),
                  child: authState.loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
