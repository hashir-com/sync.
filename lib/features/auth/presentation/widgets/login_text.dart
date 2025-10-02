import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.push("/login");
        },
        child: const Text("Already have account? Login"),
      ),
    );
  }
}
