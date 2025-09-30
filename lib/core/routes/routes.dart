import 'package:flutter/material.dart';
import 'package:sync_event/features/auth/presentation/screens/login_page.dart';
import 'package:sync_event/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sync_event/features/splash/presentation/splash_screen.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (_) => const SplashPage(),
  '/onboarding': (_) => const OnboardingPage(),
  '/login': (_) => const LoginPage(),

  
};
