import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';
import 'package:sync_event/features/auth/presentation/widgets/login_form.dart';
import 'package:sync_event/features/auth/presentation/widgets/signup_text.dart';
import 'package:sync_event/features/auth/presentation/widgets/social_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacer to center content vertically if enough space
                    const Spacer(flex: 2),

                    // Login form
                    const LoginForm(),
                    const SizedBox(height: 0),

                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.textSecondaryLight.withOpacity(
                              0.3,
                            ),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "OR",
                            style: AppTextStyles.bodyMedium(AppColors.splash),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.textSecondaryLight.withOpacity(
                              0.3,
                            ),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Social buttons
                    const SocialButtons(),

                    // Spacer to push signup text to bottom
                    const Spacer(flex: 1),

                    // Signup text at bottom
                    Center(child: SignupText()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
