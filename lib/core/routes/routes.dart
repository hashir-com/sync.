import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/features/auth/presentation/providers/phone_auth.dart';
import 'package:sync_event/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/login_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/phone_signin_screen.dart';
import 'package:sync_event/features/auth/presentation/screens/signup_screen.dart';
import 'package:sync_event/features/events/presentation/Screens/create_event_screen.dart';
import 'package:sync_event/features/events/presentation/Screens/edit_event_screen.dart';
import 'package:sync_event/features/events/presentation/Screens/events_screen.dart';
import 'package:sync_event/features/events/presentation/Screens/event_detail_screen.dart';
import 'package:sync_event/features/events/presentation/Screens/location_picker_screen.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/Screens/my_events.dart';
import 'package:sync_event/features/home/screen/home.dart';
import 'package:sync_event/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sync_event/features/profile/presentation/screens/edit_profile.dart';
import 'package:sync_event/features/splash/presentation/splash_screen.dart';
import 'package:sync_event/features/profile/presentation/screens/profile_screen.dart';
import 'package:sync_event/features/Rootnavbar/rootshell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    // List of public routes (no auth required)
    final publicRoutes = [
      '/',
      '/onboarding',
      '/login',
      '/signup',
      '/phone',
      '/otp',
      '/forgot-password',
    ];
    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    // If user is logged in and trying to access public routes, redirect to home
    if (isLoggedIn && isPublicRoute) {
      return '/root';
    }

    // If user is not logged in and trying to access protected routes
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

    GoRoute(path: '/root', builder: (context, state) => const RootShell()),
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

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/create-event',
      builder: (context, state) => CreateEventScreen(),
    ),
    GoRoute(
      path: '/location-picker',
      builder: (context, state) => const LocationPickerScreen(),
    ),

    GoRoute(path: '/events', builder: (context, state) => const EventsScreen()),

    GoRoute(
      path: '/my-events',
      builder: (context, state) => const MyEventsScreen(),
    ),
    GoRoute(
      path: '/edit-event',
      builder: (context, state) {
        final event = state.extra as EventEntity;
        return EditEventScreen(event: event);
      },
    ),
    GoRoute(
      path: '/event-detail',
      pageBuilder: (context, state) {
        final event = state.extra as EventEntity;
        return CustomTransitionPage(
          key: state.pageKey,
          child: EventDetailScreen(event: event),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
  ],
);
