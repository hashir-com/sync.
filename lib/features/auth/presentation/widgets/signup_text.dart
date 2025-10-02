import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupText extends StatelessWidget {
  const SignupText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.push('/signup');
        },
        child: const Text("Don’t have an account? Sign Up"),
      ),
    );
  }
}
