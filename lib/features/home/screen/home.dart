import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
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

  Future<void> _handleRefresh() async {
    ref.invalidate(approvedEventsStreamProvider);
    // Add a small delay for better UX 
    await Future.delayed(const Duration(milliseconds: 500));

    // The StreamProvider will automatically refetch data
    // Show a success message 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Events refreshed'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    EventSection(),
                    SizedBox(height: 20.h),
                    InviteBanner(),
                    SizedBox(height: 20.h),
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
