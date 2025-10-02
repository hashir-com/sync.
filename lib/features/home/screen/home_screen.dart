import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut(); // Sign out Firebase & Google
              if (context.mounted) {
                context.go('/login'); // Navigate to login page
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
