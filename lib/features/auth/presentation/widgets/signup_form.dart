// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/auth/presentation/providers/signup_notifier.dart';
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
    final isDark = ThemeUtils.isDark(context);

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ref.read(profileImageProvider.notifier).state = File(image.path);
        ref.read(autoValidateProvider.notifier).state = true;
      }
    }

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
      if (kDebugMode) {
        print(message);
      }
    }

    ref.listen<SignupState>(signupNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        showSnackBar(next.errorMessage!, isError: true);
        signupNotifier.clearError();
      }
      if (kDebugMode) {
        print(next.errorMessage);
      }
    });

    Future<void> signup() async {
      ref.read(autoValidateProvider.notifier).state = true;

      // Validate form fields and profile image
      bool isValid = formKey.currentState!.validate();
      if (profileImage == null) {
        showSnackBar("Please select a profile picture", isError: true);
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
      padding:  EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingHorizontal,
        vertical: AppSizes.paddingXxl,
      ),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Picker
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: AppSizes.avatarLarge,
                      backgroundColor: AppColors.getShimmerBase(isDark),
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage)
                          : null,
                      child: profileImage == null
                          ? Icon(
                              Icons.camera_alt_rounded,
                              size: AppSizes.iconXl,
                              color: AppColors.getTextSecondary(isDark),
                            )
                          : null,
                    ),
                  ),
                  if (profileImage == null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding:  EdgeInsets.all(AppSizes.paddingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.getPrimary(isDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.getBackground(isDark),
                            width: AppSizes.borderWidthMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: AppSizes.iconSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
             SizedBox(height: AppSizes.spacingXxl),

            // Sign up heading
            Text(
              'Sign up',
              style: AppTextStyles.headingMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
             SizedBox(height: AppSizes.spacingXxl),

            // Full Name field
            AuthTextField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person_outline_rounded,
              fieldType: AuthFieldType.name,
              autoValidate: autoValidate,
            ),
             SizedBox(height: AppSizes.spacingLarge),

            // Email field
            AuthTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              fieldType: AuthFieldType.email,
              autoValidate: autoValidate,
            ),
             SizedBox(height: AppSizes.spacingLarge),

            // Password field
            AuthTextField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              visibilityProvider: passwordVisibilityProvider,
              fieldType: AuthFieldType.password,
              autoValidate: autoValidate,
            ),
             SizedBox(height: AppSizes.spacingLarge),

            // Confirm Password field
            AuthTextField(
              controller: confirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_clock_outlined,
              obscureText: true,
              visibilityProvider: confirmPasswordVisibilityProvider,
              fieldType: AuthFieldType.confirmPassword,
              matchController: passwordController,
              autoValidate: autoValidate,
            ),
             SizedBox(height: AppSizes.spacingXxl),

            // Sign Up button
            SizedBox(
              height: AppSizes.buttonHeightMedium,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(isDark),
                ),
                onPressed: signupState.isLoading ? null : signup,
                child: signupState.isLoading
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
                            "Sign Up",
                            style: AppTextStyles.button(
                              isDark: isDark,
                            ).copyWith(color: Colors.white),
                          ),
                           SizedBox(width: AppSizes.spacingSmall),
                           Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: AppSizes.iconSmall,
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
