import 'package:flutter/material.dart';
import 'package:sync_event/features/auth/presentation/widgets/login_form.dart';
import 'package:sync_event/features/auth/presentation/widgets/sign_up.dart';
import 'package:sync_event/features/auth/presentation/widgets/social_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              LoginForm(),
              SizedBox(height: 30),
              SocialButtons(),
              Spacer(),
              SignupText(),
            ],
          ),
        ),
      ),
    );
  }
}
