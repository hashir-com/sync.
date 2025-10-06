// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/phone_auth.dart';

class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current phone number from provider
    final authState = ref.read(phoneAuthProvider);
    _phoneController.text = authState.phone;
    // Pass controller to PhoneAuthNotifier for sign-out clearing
    ref.read(phoneAuthProvider.notifier).setPhoneController(_phoneController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to provider changes to keep controller in sync
    final authState = ref.watch(phoneAuthProvider);
    if (_phoneController.text != authState.phone) {
      _phoneController.text = authState.phone;
    }
  }

  @override
  void dispose() {
    // Dispose controller only when widget is permanently removed
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _phoneController,
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
                      ? Shimmer.fromColors(
                          baseColor: theme.primaryColor.withOpacity(0.5),
                          highlightColor: theme.primaryColor.withOpacity(0.2),
                          period: const Duration(milliseconds: 1000),
                          child: Text(
                            'Sending OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
