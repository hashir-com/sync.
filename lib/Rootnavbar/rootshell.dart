// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/Rootnavbar/root_tab_notifier.dart';
import 'package:sync_event/features/home/screen/events_screen.dart';
import 'package:sync_event/features/home/screen/home.dart';
import 'package:sync_event/features/home/screen/map_screen.dart';
import 'package:sync_event/features/profile/presentation/screens/profile_screen.dart'; // Adjust import path

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(
      rootTabProvider,
    ); // Watch the selected index
    final pages = [Home(), EventsScreen(), MapScreen(), ProfileScreen()];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(Icons.explore, 'Explore', 0, ref, context),
              _NavIcon(Icons.event, 'Events', 1, ref, context),
              SizedBox(width: 48), // space for FAB
              _NavIcon(Icons.map, 'Map', 2, ref, context),
              _NavIcon(Icons.person, 'Profile', 3, ref, context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                children: [
                  ListTile(
                    title: Text('Create Event'),
                    leading: Icon(Icons.add),
                  ),
                  ListTile(
                    title: Text('Upload Photo'),
                    leading: Icon(Icons.photo),
                  ),
                  ListTile(
                    title: Text('Other'),
                    leading: Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _NavIcon(
    IconData icon,
    String label,
    int idx,
    WidgetRef ref,
    BuildContext context,
  ) {
    final active = idx == ref.watch(rootTabProvider);
    return InkWell(
      onTap: () => ref.read(rootTabProvider.notifier).selectTab(idx),
      child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
