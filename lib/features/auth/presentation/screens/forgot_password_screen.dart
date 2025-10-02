import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';

/// Riverpod providers
final emailProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailProvider);
    final isLoading = ref.watch(isLoadingProvider);

    /// Show snackbar
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

    /// Send password reset email
    Future<void> resetPassword() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        showSnackBar("Please enter your email", isError: true);
        return;
      }

      ref.read(isLoadingProvider.notifier).state = true;

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showSnackBar(
          "Password reset link has been sent to your email. Check inbox.",
        );
      } on FirebaseAuthException catch (e) {
        showSnackBar("Error: ${e.message}", isError: true);
      } catch (e) {
        showSnackBar("Unexpected error: $e", isError: true);
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

            /// Email field
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

            /// Reset Button
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
