import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/auth/presentation/providers/phone_auth.dart';
import 'package:sync_event/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/login_page.dart';
import 'package:sync_event/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/phone_signin_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/signup_page.dart';
import 'package:sync_event/features/home/screen/home_screen.dart';
import 'package:sync_event/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sync_event/features/splash/presentation/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneSignInScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        // Extract the extra data passed from the previous screen
        final extra = state.extra as Map<String, dynamic>?;

        if (extra == null) {
          return const Scaffold(
            body: Center(child: Text('No phone number provided')),
          );
        }

        final phoneNumber = extra['phoneNumber'] as String;
        final authService = extra['authService'] as AuthService;

        return OtpVerificationScreen(
          phoneNumber: phoneNumber,
          authService: authService,
        );
      },
    ),
  ],
);
