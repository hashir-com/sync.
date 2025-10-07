import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sync_event/core/constants/app_colors.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App logo (replace with your own asset)
        const SizedBox(height: 16),
        Text(
          'Sync.',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 46,
            color: AppColors.splashText,
          ),
        ),
        Text(
          "Sync with the neighbourhood!",
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: AppColors.splashText,
          ),
        ),
      ],
    );
  }
}
