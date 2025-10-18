import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/login_notifier.dart';
import 'auth_text_field.dart';

final emailControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);
final passwordControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final autoValidateProvider = StateProvider<bool>((ref) => false);

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final loginState = ref.watch(loginNotifierProvider);
    final autoValidate = ref.watch(autoValidateProvider);
    final formKey = GlobalKey<FormState>();
    final isDark = ThemeUtils.isDark(context);

    void showSnackBar(String message, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium(
              isDark: true,
            ).copyWith(color: Colors.white),
          ),
          backgroundColor: isError
              ? AppColors.getError(isDark)
              : AppColors.getSuccess(isDark),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          margin:  EdgeInsets.all(AppSizes.paddingLarge),
        ),
      );
    }

    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        print('Login error: ${next.errorMessage}'); // Debug print
        showSnackBar(next.errorMessage!, isError: true);
        ref.read(loginNotifierProvider.notifier).clearError();
      }
      if (next.user != null && previous?.user == null) {
        print('Login successful for user: ${next.user!.email}'); // Debug print
        showSnackBar("Login successful!");
        if (context.mounted) {
          context.go('/root');
        }
      }
    });

    Future<void> login() async {
      ref.read(autoValidateProvider.notifier).state = true;

      if (!formKey.currentState!.validate()) {
        print('Form validation failed'); // Debug print
        return;
      }

      print(
        'Attempting login with email: ${emailController.text}',
      ); // Debug print
      await ref
          .read(loginNotifierProvider.notifier)
          .loginWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }

    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
        vertical: AppSizes.paddingXxxl,
      ),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Logo/Title
            Text(
              "SYNC.",
              style: GoogleFonts.quicksand(
                fontSize: AppSizes.fontDisplay1 + 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getPrimary(isDark),
                letterSpacing: AppSizes.letterSpacingWide,
              ),
              textAlign: TextAlign.center,
            ),
             SizedBox(
              height: AppSizes.spacingXxxl + AppSizes.spacingSmall,
            ),

            // Sign in heading
            Text('Sign in', style: AppTextStyles.headingSmall(isDark: isDark)),
             SizedBox(height: AppSizes.spacingMedium),

            // Email field
            AuthTextField(
              controller: emailController,
              label: "abc@gmail.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              fieldType: AuthFieldType.email,
              autoValidate: autoValidate,
            ),
             SizedBox(height: AppSizes.spacingLarge),

            // Password field
            AuthTextField(
              controller: passwordController,
              label: "Your Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              visibilityProvider: passwordVisibilityProvider,
              fieldType: AuthFieldType.password,
              autoValidate: autoValidate,
            ),

            // Forgot password button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                ),
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                    color: AppColors.getPrimary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
             SizedBox(height: AppSizes.spacingSmall),

            // Login button
            SizedBox(
              height: AppSizes.buttonHeightMedium,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                ),
                onPressed: loginState.isLoading ? null : login,
                child: loginState.isLoading
                    ? SizedBox(
                        height: AppSizes.iconMedium,
                        width: AppSizes.iconMedium,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login",
                            style: AppTextStyles.button(
                              isDark: isDark,
                            ).copyWith(color: Colors.white),
                          ),
                           SizedBox(width: AppSizes.spacingSmall),
                           Icon(
                            Icons.arrow_forward,
                            size: AppSizes.iconSmall,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
