import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/auth/presentation/providers/phone_auth.dart';
import 'package:sync_event/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/login_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/phone_signin_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/signup_screen.dart';
import 'package:sync_event/features/home/screen/home_screen.dart';
import 'package:sync_event/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sync_event/features/profile/presentation/screens/edit_profile.dart';
import 'package:sync_event/features/splash/presentation/splash_screen.dart';
import 'package:sync_event/features/profile/presentation/screens/profile_screen.dart'; // <-- Add Profile import

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneSignInScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        if (extra == null) {
          return const Scaffold(
            body: Center(child: Text('No phone number provided')),
          );
        }

        final phoneNumber = extra['phoneNumber'] as String;
        final phoneAuthNotifier =
            extra['phoneAuthNotifier'] as PhoneAuthNotifier;

        return OtpVerificationScreen(
          phoneNumber: phoneNumber,
          phoneAuthNotifier: phoneAuthNotifier,
        );
      },
    ),
    // ✅ Profile Route
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);
