import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/di/injection_container.dart';
import 'package:sync_event/core/routes/routes.dart';
import 'package:sync_event/features/profile/presentation/providers/other_users_provider.dart'
    hide UserModel, allUsersProvider;
import 'package:sync_event/features/profile/presentation/providers/profile_providers.dart';
import 'package:sync_event/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return AppWithAuthListener(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sync Event',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}

// Add this to your main.dart or app.dart wrapper widget

class AppWithAuthListener extends ConsumerWidget {
  final Widget child;

  const AppWithAuthListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes and invalidate providers
    ref.listen<AsyncValue<UserModel?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user == null) {
          // User logged out - invalidate all user-related providers
          print(' Auth listener: User logged out, invalidating providers');
          ref.invalidate(allUsersProvider);
          // Family providers auto-invalidate when their dependencies change
        } else {
          // User logged in
          print(' Auth listener: User logged in - ${user.id}');
          // Providers will automatically refresh due to currentUserProvider watch
        }
      });
    });

    return child;
  }
}

