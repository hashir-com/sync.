import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      children: [
        SizedBox(
          width: 320.w,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(14.r),
            shadowColor: theme.shadowColor.withOpacity(0.26),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: authState.isLoading
                  ? null
                  : () async {
                      final success = await authNotifier.signInWithGoogle(
                        forceAccountChooser: true,
                      );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully signed in!',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        );
                        context.go('/home');
                      } else if (authState.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sign-in failed: ${authState.error}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        print(authState.error);
                      }
                    },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authState.isLoading)
                      SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      FaIcon(
                        FontAwesomeIcons.google,
                        color:
                            theme.colorScheme.error, // Maps to red-like color
                        size: 22,
                      ),
                    SizedBox(width: 16.w),
                    Text(
                      authState.isLoading
                          ? "Signing in..."
                          : "Continue with Google",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: 320.w,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(14.r),
            shadowColor: theme.shadowColor.withOpacity(0.26),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => context.push('/phone'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      color: theme
                          .colorScheme
                          .primary, // Maps to success-like color
                      size: 22,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      "Continue with Phone",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
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
