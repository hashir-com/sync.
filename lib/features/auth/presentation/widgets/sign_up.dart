import 'package:flutter/material.dart';

class SignupText extends StatelessWidget {
  const SignupText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: navigate to SignupPage
        },
        child: const Text("Don’t have an account? Sign Up"),
      ),
    );
  }
}
