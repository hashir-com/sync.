import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/home/screen/drawer.dart';
import 'package:sync_event/features/home/widgets/category_section.dart';
import 'package:sync_event/features/home/widgets/event_section.dart';
import 'package:sync_event/features/home/widgets/header_section.dart';
import 'package:sync_event/features/home/widgets/invite_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(),
            CategorySection(
              selectedCategory: _selectedCategory,
              onCategoryTap: (index) =>
                  setState(() => _selectedCategory = index),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EventSection(),
                    InviteBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
    );
  }
}
