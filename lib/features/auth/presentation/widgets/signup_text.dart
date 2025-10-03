import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';

class SignupText extends StatelessWidget {
  const SignupText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final SignupTextcolor = isDarkMode ? Colors.white : AppColors.primary;
    return Center(
      child: TextButton(
        onPressed: () => context.push('/signup'),
        child: Text(
          "Don’t have an account? Sign Up",
          style: TextStyle(color: SignupTextcolor, fontSize: 14),
        ),
      ),
    );
  }
}
