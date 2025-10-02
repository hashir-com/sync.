import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';

// Providers
final nameControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);
final emailControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);
final passwordControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);
final confirmPasswordControllerProvider = Provider.autoDispose(
  (ref) => TextEditingController(),
);

final profileImageProvider = StateProvider<File?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => true);

class SignupForm extends ConsumerWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.watch(nameControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final confirmPasswordController = ref.watch(
      confirmPasswordControllerProvider,
    );
    final profileImage = ref.watch(profileImageProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null)
        ref.read(profileImageProvider.notifier).state = File(image.path);
    }

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium(AppColors.warning),
          ),
        ),
      );
    }

    Future<void> signup() async {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        showSnackBar("Please fill all fields");
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        showSnackBar("Passwords do not match");
        return;
      }

      ref.read(isLoadingProvider.notifier).state = true;

      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await userCredential.user?.updateDisplayName(
          nameController.text.trim(),
        );
        showSnackBar("Signup successful!");
        if (!context.mounted) return;
        context.go('/login');
      } on FirebaseAuthException catch (e) {
        showSnackBar("Error: ${e.message}");
      } catch (e) {
        showSnackBar("Unexpected error: $e");
      } finally {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }

    Widget buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      StateProvider<bool>? visibilityProvider,
    }) {
      return TextField(
        controller: controller,
        obscureText: visibilityProvider != null
            ? ref.watch(visibilityProvider)
            : obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
          prefixIcon: Icon(icon, color: AppColors.textSecondaryDark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          suffixIcon: visibilityProvider != null
              ? IconButton(
                  icon: Icon(
                    ref.watch(visibilityProvider)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondaryDark,
                  ),
                  onPressed: () => ref.read(visibilityProvider.notifier).state =
                      !ref.read(visibilityProvider),
                )
              : null,
        ),
        style: AppTextStyles.bodyLarge(AppColors.textPrimaryLight),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Profile Picture
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage)
                    : null,
                child: profileImage == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: AppColors.textSecondaryDark,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),

          /// Header
          Text(
            'Sign up',
            style: AppTextStyles.headingMedium(AppColors.textPrimaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          /// Form Fields
          buildTextField(
            controller: nameController,
            label: "Full Name",
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock,
            obscureText: true,
            visibilityProvider: passwordVisibilityProvider,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.lock_outline,
            obscureText: true,
            visibilityProvider: confirmPasswordVisibilityProvider,
          ),
          const SizedBox(height: 24),

          /// Signup Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.backgroundLight,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign Up",
                          style: AppTextStyles.button(
                            AppColors.backgroundLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.backgroundLight,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
