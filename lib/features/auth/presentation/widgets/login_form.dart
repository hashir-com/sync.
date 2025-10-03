import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font_size.dart';
import 'auth_text_field.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final loginState = ref.watch(authControllerProvider);

    ref.listen<LoginState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    final isDarkMode = theme.brightness == Brightness.dark;
    final syncColor = isDarkMode
        ? const Color.fromARGB(255, 199, 210, 255)
        : AppColors.splash;
    final forgotPasswordColor = isDarkMode ? Colors.white : AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "SYNC.",
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: syncColor,
              ).merge(AppTextStyles.headingLarge(syncColor)),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Sign in',
            style: AppTextStyles.headingMedium(theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          AuthTextField(
            controller: emailController,
            label: "abc@gmail.com",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: passwordController,
            label: "Your Password",
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            visibilityProvider: passwordVisibilityProvider,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 14,
                  color: forgotPasswordColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: loginState.isLoading
                  ? null
                  : () async {
                      final user = await ref
                          .read(authControllerProvider.notifier)
                          .loginWithEmail(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                      if (user != null && context.mounted) {
                        context.go('/home');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: loginState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
