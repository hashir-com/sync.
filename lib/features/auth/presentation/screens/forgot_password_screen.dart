import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_providers.dart';

final emailProvider = StateProvider<TextEditingController>(
  (ref) => TextEditingController(),
);

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final sendResetUseCase = ref.watch(sendPasswordResetUseCaseProvider);

    void showSnackBar(String message, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium(
              isError ? Colors.white : AppColors.backgroundLight,
            ),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    Future<void> resetPassword() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        showSnackBar("Please enter your email", isError: true);
        return;
      }
      ref.read(isLoadingProvider.notifier).state = true;
      try {
        await sendResetUseCase.call(email);
        showSnackBar(
          "Password reset link has been sent to your email. Check inbox.",
        );
      } catch (e) {
        showSnackBar("Error: $e", isError: true);
      } finally {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Forgot your password?",
              style: AppTextStyles.headingMedium(AppColors.textPrimaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Enter your email below and we’ll send you a link to reset your password.",
              style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Your Email",
                labelStyle: AppTextStyles.bodyMedium(
                  AppColors.textSecondaryDark,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textSecondaryDark,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: AppTextStyles.bodyLarge(AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Send Reset Link",
                        style: AppTextStyles.button(AppColors.backgroundLight),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
