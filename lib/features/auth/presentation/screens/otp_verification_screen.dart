import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/auth/presentation/providers/phone_auth.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final AuthService authService;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.authService,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  void _submitOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final user = await widget.authService.verifyOtp(otp);

    if (user != null) {
      if (context.mounted) {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(counterText: ''),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (val.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
