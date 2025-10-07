// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sync_event/core/constants/app_colors.dart';
// import 'package:sync_event/core/constants/app_font_size.dart';

// class SplashPage extends ConsumerWidget {
//   const SplashPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     Future.delayed(const Duration(seconds: 2), () {
//       // ignore: use_build_context_synchronously
//       context.go('/onboarding');
//     });

//     return Scaffold(
//       backgroundColor: AppColors.splash,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "SYNC.",
//               style: GoogleFonts.quicksand(
//                 textStyle: AppTextStyles.splash(
//                   AppColors.splashText,
//                 ).copyWith(),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             Text(
//               "keep syncing with neigborhood!!",
//               style: GoogleFonts.quicksand(
//                 textStyle: AppTextStyles.bodyMedium(
//                   AppColors.splashText,
//                 ).copyWith(),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/splash/presentation/widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Scale controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    // Start animation sequence
    startAnimationSequence();
  }

  Future<void> startAnimationSequence() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _scaleController.forward();

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/onboarding'); // Use GoRouter’s context extension
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // BookMyShow-style dark background
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 0, 2, 129), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const SplashLogo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
