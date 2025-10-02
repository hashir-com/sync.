import 'package:flutter/material.dart';
import 'package:sync_event/features/auth/presentation/widgets/login_text.dart';
import 'package:sync_event/features/auth/presentation/widgets/signup_form.dart';
import 'package:sync_event/features/auth/presentation/widgets/social_buttons.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 20),
                  SignupForm(),
                  SizedBox(height: 30),
                  SocialButtons(),
                  Spacer(),
                  LoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
