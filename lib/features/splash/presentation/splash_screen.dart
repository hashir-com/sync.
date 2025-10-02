import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_font_size.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      context.go('/onboarding');
    });

    return Scaffold(
      backgroundColor: AppColors.splash,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SYNC.",
              style: GoogleFonts.quicksand(
                textStyle: AppTextStyles.splash(
                  AppColors.splashText,
                ).copyWith(),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "keep syncing with neigborhood!!",
              style: GoogleFonts.quicksand(
                textStyle: AppTextStyles.bodyMedium(
                  AppColors.splashText,
                ).copyWith(),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
