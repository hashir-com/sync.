// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sync_event/features/auth/presentation/providers/signup_notifier.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font_size.dart';
import 'auth_text_field.dart';

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
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => true);
final autoValidateProvider = StateProvider<bool>((ref) => false);

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
    final signupState = ref.watch(signupNotifierProvider);
    final signupNotifier = ref.read(signupNotifierProvider.notifier);
    final autoValidate = ref.watch(autoValidateProvider);
    final picker = ImagePicker();
    final formKey = GlobalKey<FormState>();

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ref.read(profileImageProvider.notifier).state = File(image.path);
        ref.read(autoValidateProvider.notifier).state =
            true; 
      }
    }

    void showSnackBar(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (kDebugMode) {
        print(message);
      }
    }

    ref.listen<SignupState>(signupNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        showSnackBar(
          next.errorMessage!,
        ); // Show Firebase or non-validation errors
        signupNotifier.clearError();
      }
      if (kDebugMode) {
        print(next.errorMessage);
      }
    });

    Future<void> signup() async {
      ref.read(autoValidateProvider.notifier).state =
          true; // Enable autovalidation on submit

      // Validate form fields and profile image
      bool isValid = formKey.currentState!.validate();
      if (profileImage == null) {
        showSnackBar("Please select a profile picture");
        isValid = false;
      }

      // Only proceed with signup if all validations pass
      if (!isValid) {
        return;
      }

      final user = await signupNotifier.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        imagePath: profileImage!.path,
      );
      if (user != null) {
        showSnackBar("Signup successful!");
        ref.read(profileImageProvider.notifier).state = null;
        if (context.mounted) context.go('/login');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              fieldType: AuthFieldType.name,
              autoValidate: autoValidate,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              fieldType: AuthFieldType.email,
              autoValidate: autoValidate,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock,
              obscureText: true,
              visibilityProvider: passwordVisibilityProvider,
              fieldType: AuthFieldType.password,
              autoValidate: autoValidate,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: confirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
              visibilityProvider: confirmPasswordVisibilityProvider,
              fieldType: AuthFieldType.confirmPassword,
              matchController: passwordController,
              autoValidate: autoValidate,
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: signupState.isLoading ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: signupState.isLoading
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
      ),
    );
  }
}
