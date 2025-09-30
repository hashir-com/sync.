import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });

    return Scaffold(
      backgroundColor: AppColors.splash,
      body: Center(
        child: Text(
          'Sync.',
          style: TextStyle(color: AppColors.splashtext, fontSize: 56),
        ),
      ),
    );
  }
}
