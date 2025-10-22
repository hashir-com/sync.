// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/util/responsive_helper.dart';
import 'package:sync_event/features/Map/presentation/screens/map_screen.dart';
import 'package:sync_event/features/Rootnavbar/root_tab_notifier.dart';
import 'package:sync_event/features/events/presentation/Screens/events_screen.dart';
import 'package:sync_event/features/home/presentation/screen/home.dart';
import 'package:sync_event/features/profile/presentation/screens/profile_screen.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(rootTabProvider);
    final pages = [HomeScreen(), EventsScreen(), MapScreen(), ProfileScreen()];
    final navigationType = ResponsiveHelper.getNavigationType(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (navigationType == NavigationType.sidebar) {
          // Desktop layout with permanent sidebar
          return Scaffold(
            body: Row(
              children: [
                _buildDesktopSidebar(context, ref, selectedIndex),
                Expanded(
                  child: pages[selectedIndex],
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(context),
          );
        } else if (navigationType == NavigationType.rail) {
          // Tablet layout with navigation rail
          return Scaffold(
            body: Row(
              children: [
                _buildNavigationRail(context, ref, selectedIndex),
                Expanded(
                  child: pages[selectedIndex],
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(context),
          );
        } else {
          // Mobile layout with bottom navigation
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: _buildBottomNavigationBar(context, ref, selectedIndex),
            floatingActionButton: _buildFloatingActionButton(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        }
      },
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, WidgetRef ref, int selectedIndex) {
    return Container(
      width: ResponsiveHelper.getResponsiveValueSimple(
        context,
        mobile: 0,
        tablet: 0,
        desktop: 280.w,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveHelper.getAppBarHeight(context)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsiveVerticalPadding(context).vertical,
              ),
              children: [
                _buildSidebarItem(context, ref, Icons.explore, 'Explore', 0, selectedIndex),
                _buildSidebarItem(context, ref, Icons.paste_rounded, 'Events', 1, selectedIndex),
                _buildSidebarItem(context, ref, Icons.location_on_rounded, 'Map', 2, selectedIndex),
                _buildSidebarItem(context, ref, Icons.person, 'Profile', 3, selectedIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, WidgetRef ref, int selectedIndex) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => ref.read(rootTabProvider.notifier).selectTab(index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.explore),
          selectedIcon: Icon(Icons.explore),
          label: Text('Explore'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.paste_rounded),
          selectedIcon: Icon(Icons.paste_rounded),
          label: Text('Events'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.location_on_rounded),
          selectedIcon: Icon(Icons.location_on_rounded),
          label: Text('Map'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, int selectedIndex) {
    return BottomAppBar(
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveVerticalPadding(context).vertical,
          horizontal: 6.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(Icons.explore, 'Explore', 0, ref, context),
            _NavIcon(Icons.paste_rounded, 'Events', 1, ref, context),
            SizedBox(width: ResponsiveHelper.getTouchTargetSize(context)),
            _NavIcon(Icons.location_on_rounded, 'Map', 2, ref, context),
            _NavIcon(Icons.person, 'Profile', 3, ref, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Create Event',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, baseRadius: 26),
        ),
      ),
      onPressed: () {
        context.push('/create-event');
      },
      child: Icon(
        Icons.add,
        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    int index,
    int selectedIndex,
  ) {
    final isSelected = index == selectedIndex;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveHorizontalPadding(context).horizontal,
        vertical: 4.h,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 16,
            ),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
          ),
        ),
        onTap: () => ref.read(rootTabProvider.notifier).selectTab(index),
      ),
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
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getBorderRadius(context, baseRadius: 8),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveVerticalPadding(context).vertical / 2,
          horizontal: ResponsiveHelper.getResponsiveHorizontalPadding(context).horizontal / 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: ResponsiveHelper.getIconSize(context, baseSize: 24),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 11,
                  tablet: 12,
                  desktop: 12,
                ),
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
