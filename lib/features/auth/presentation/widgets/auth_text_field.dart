import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final theme = Theme.of(context);
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        errorStyle: TextStyle(fontSize: 12.sp, color: theme.colorScheme.error),
        suffixIcon: visibilityProvider != null
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    ref.read(visibilityProvider!.notifier).state = !isObscure,
              )
            : null,
      ),
      style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
    );
  }
}
