import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login to continue using Sync Event',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 40),

        /// Email field
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),

        /// Password field
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 20),

        /// Login button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: call Riverpod authNotifier.login(email, password)
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
