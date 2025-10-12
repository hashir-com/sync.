import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sync_event/features/auth/presentation/providers/login_notifier.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font_size.dart';
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
    final theme = Theme.of(context);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final loginState = ref.watch(loginNotifierProvider);
    final autoValidate = ref.watch(autoValidateProvider);
    final formKey = GlobalKey<FormState>();

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        print('Login error: ${next.errorMessage}'); // Debug print
        showSnackBar(next.errorMessage!);
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

    final isDarkMode = theme.brightness == Brightness.dark;
    final syncColor = isDarkMode
        ? const Color.fromARGB(255, 199, 210, 255)
        : AppColors.splash;
    final forgotPasswordColor = isDarkMode ? Colors.white : AppColors.primary;

    Future<void> login() async {
      ref.read(autoValidateProvider.notifier).state = true;

      if (!formKey.currentState!.validate()) {
        print('Form validation failed'); // Debug print
        return;
      }

      print('Attempting login with email: ${emailController.text}'); // Debug print
      await ref.read(loginNotifierProvider.notifier).loginWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
              fieldType: AuthFieldType.email,
              autoValidate: autoValidate,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: passwordController,
              label: "Your Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              visibilityProvider: passwordVisibilityProvider,
              fieldType: AuthFieldType.password,
              autoValidate: autoValidate,
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
                onPressed: loginState.isLoading ? null : login,
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
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
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