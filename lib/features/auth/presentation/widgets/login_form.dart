import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';
import '../../../../core/constants/app_font_size.dart';
import 'package:google_fonts/google_fonts.dart';

/// Password visibility providers
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Splash text
          Text(
            "SYNC.",
            style: GoogleFonts.quicksand(
              textStyle: AppTextStyles.headingLarge(AppColors.splash),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          /// Sign in heading
          Text(
            'Sign in',
            style: AppTextStyles.headingMedium(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          /// Email field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "abc@gmail.com",
              labelStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// Password field
          Consumer(
            builder: (context, ref, _) {
              final isPasswordVisible = ref.watch(passwordVisibilityProvider);
              return TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Your Password",
                  labelStyle: const TextStyle(fontSize: 14),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.textSecondaryDark,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondaryDark,
                    ),
                    onPressed: () {
                      ref.read(passwordVisibilityProvider.notifier).state =
                          !isPasswordVisible;
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 0),

          /// Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                context.push('/forgot-password');
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          /// Login button
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
