import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sync_event/features/auth/presentation/providers/signup_notifier.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font_size.dart';
import 'auth_text_field.dart';

final nameControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final emailControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final passwordControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final confirmPasswordControllerProvider = Provider.autoDispose((ref) => TextEditingController());

final profileImageProvider = StateProvider<File?>((ref) => null);
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => true);

class SignupForm extends ConsumerWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.watch(nameControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final confirmPasswordController = ref.watch(confirmPasswordControllerProvider);
    final profileImage = ref.watch(profileImageProvider);
    final signupState = ref.watch(signupNotifierProvider);
    final signupNotifier = ref.read(signupNotifierProvider.notifier);
    final picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) ref.read(profileImageProvider.notifier).state = File(image.path);
    }

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    ref.listen<SignupState>(signupNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        showSnackBar(next.errorMessage!);
        signupNotifier.clearError();
      }
    });

    Future<void> signup() async {
      if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
        showSnackBar("Please fill all fields");
        return;
      }
      final user = await signupNotifier.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );
      if (user != null) {
        showSnackBar("Signup successful!");
        if (context.mounted) context.go('/login');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage != null ? FileImage(profileImage) : null,
                child: profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: AppColors.textSecondaryDark)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign up',
            style: AppTextStyles.headingMedium(AppColors.textPrimaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AuthTextField(
            controller: nameController,
            label: "Full Name",
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock,
            obscureText: true,
            visibilityProvider: passwordVisibilityProvider,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.lock_outline,
            obscureText: true,
            visibilityProvider: confirmPasswordVisibilityProvider,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: signupState.isLoading ? null : signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: signupState.isLoading
                  ? const CircularProgressIndicator(color: AppColors.backgroundLight)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sign Up", style: AppTextStyles.button(AppColors.backgroundLight)),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, color: AppColors.backgroundLight, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}