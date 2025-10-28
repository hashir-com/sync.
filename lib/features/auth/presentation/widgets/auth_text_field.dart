// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

enum AuthFieldType { name, email, password, confirmPassword }

class AuthTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final StateProvider<bool>? visibilityProvider;
  final AuthFieldType fieldType;
  final TextEditingController? matchController;
  final bool autoValidate;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.visibilityProvider,
    required this.fieldType,
    this.matchController,
    this.autoValidate = false,
  });

  String? _validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    switch (fieldType) {
      case AuthFieldType.name:
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
          return 'Name can only contain letters and spaces';
        }
        break;
      case AuthFieldType.email:
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value.trim())) {
          return 'Enter a valid email address';
        }
        break;
      case AuthFieldType.password:
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (!RegExp(
          r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]+$',
        ).hasMatch(value)) {
          return 'Password must contain uppercase, lowercase, and number';
        }
        break;
      case AuthFieldType.confirmPassword:
        if (matchController != null && value != matchController!.text) {
          return 'Passwords do not match';
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final isObscure = visibilityProvider != null
        ? ref.watch(visibilityProvider!)
        : obscureText;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscure,
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: _validateField,
      style: AppTextStyles.bodyLarge(
        isDark: isDark,
      ).copyWith(fontSize: AppSizes.fontMedium),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium(
          isDark: isDark,
        ).copyWith(fontSize: AppSizes.fontMedium),
        hintText: label,
        hintStyle: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
          fontSize: AppSizes.fontMedium,
          color: AppColors.getTextSecondary(isDark).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.getTextSecondary(isDark),
          size: AppSizes.iconMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.getBorder(isDark),
            width: AppSizes.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.getBorder(isDark),
            width: AppSizes.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.getPrimary(isDark),
            width: AppSizes.inputBorderWidthFocused,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.getError(isDark),
            width: AppSizes.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.getError(isDark),
            width: AppSizes.inputBorderWidthFocused,
          ),
        ),
        errorStyle: AppTextStyles.bodySmall(isDark: isDark).copyWith(
          fontSize: AppSizes.fontSmall,
          color: AppColors.getError(isDark),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.inputPaddingHorizontal,
          vertical: AppSizes.inputPaddingVertical,
        ),
        filled: true,
        fillColor: AppColors.getSurface(isDark).withOpacity(0.5),
        suffixIcon: visibilityProvider != null
            ? IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.getTextSecondary(isDark),
                  size: AppSizes.iconMedium,
                ),
                onPressed: () =>
                    ref.read(visibilityProvider!.notifier).state = !isObscure,
                tooltip: isObscure ? 'Show password' : 'Hide password',
              )
            : null,
      ),
    );
  }
}
