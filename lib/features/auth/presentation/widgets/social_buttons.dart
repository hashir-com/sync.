import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      children: [
        // Google Sign-In Button
        SizedBox(
          width: 320,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(14),
            shadowColor: Colors.black26,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: authState.isLoading
                  ? null
                  : () async {
                      final success = await authNotifier.signInWithGoogle(
                        forceAccountChooser: true,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully signed in!',
                              style: AppTextStyles.bodyLarge(
                                AppColors.backgroundLight,
                              ),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.go('/home');
                      } else if (authState.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sign-in failed: ${authState.error}',
                              style: AppTextStyles.bodyLarge(
                                AppColors.backgroundLight,
                              ),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.backgroundLight,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authState.isLoading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    else
                      const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                    const SizedBox(width: 16),
                    Text(
                      authState.isLoading
                          ? "Signing in..."
                          : "Continue with Google",
                      style: AppTextStyles.button(AppColors.textPrimaryLight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Phone Sign-In Button
        SizedBox(
          width: 320,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(14),
            shadowColor: Colors.black26,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                context.push('/phone');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundLight,
                      AppColors.backgroundLight.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: AppColors.success, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      "Continue with Phone",
                      style: AppTextStyles.button(AppColors.textPrimaryLight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
