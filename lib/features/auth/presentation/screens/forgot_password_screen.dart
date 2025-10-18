import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/domain/usecases/send_password_reset_usecase.dart';
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
    final isDark = ThemeUtils.isDark(context);

    void showSnackBar(String message, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium(isDark: true)
                .copyWith(color: Colors.white),
          ),
          backgroundColor: isError
              ? AppColors.getError(isDark)
              : AppColors.getPrimary(isDark),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          margin:  EdgeInsets.all(AppSizes.paddingLarge),
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
        final result = await sendResetUseCase.call(
          SendPasswordResetParams(email: email),
        );
        result.fold(
          (failure) => showSnackBar("Error: ${failure.message}", isError: true),
          (success) => showSnackBar(
            "Password reset link has been sent to your email. Check inbox.",
          ),
        );
      } finally {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingHorizontal,
            vertical: AppSizes.paddingXxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon illustration
              Icon(
                Icons.lock_reset_rounded,
                size: AppSizes.iconXxl * 2,
                color: AppColors.getPrimary(isDark),
              ),
               SizedBox(height: AppSizes.spacingXxl),

              // Heading
              Text(
                "Forgot your password?",
                style: AppTextStyles.headingMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
               SizedBox(height: AppSizes.spacingLarge),

              // Description
              Text(
                "Enter your email below and we'll send you a link to reset your password.",
                style: AppTextStyles.bodyMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
               SizedBox(height: AppSizes.spacingXxxl),

              // Email input field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLarge(isDark: isDark),
                decoration: InputDecoration(
                  labelText: "Your Email",
                  hintText: "Enter your email address",
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
               SizedBox(height: AppSizes.spacingXxxl),

              // Send reset link button
              SizedBox(
                height: AppSizes.buttonHeightMedium,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  child: isLoading
                      ? SizedBox(
                          height: AppSizes.iconMedium,
                          width: AppSizes.iconMedium,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Send Reset Link"),
                ),
              ),
               SizedBox(height: AppSizes.spacingLarge),

              // Back to login
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Back to Login",
                  style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                    color: AppColors.getPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}