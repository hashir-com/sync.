import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/screen/drawer.dart';
import 'package:sync_event/features/home/widgets/event_section.dart';
import 'package:sync_event/features/home/widgets/header_section.dart';
import 'package:sync_event/features/home/widgets/invite_banner.dart';

// ============================================
// Selected Category Provider
// ============================================
final selectedCategoryProvider = StateProvider<int>((ref) => 0);

// ============================================
// Home Screen Widget
// ============================================
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _handleRefresh(WidgetRef ref, BuildContext context) async {
    ref.invalidate(approvedEventsStreamProvider);

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Events refreshed'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          margin: EdgeInsets.all(AppSizes.paddingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(ref, context),
        color: AppColors.getPrimary(isDark),
        backgroundColor: AppColors.getCard(isDark),
        child: Column(
          children: [
            const HeaderSection(),
            // CategorySection(
            //   selectedCategory: selectedCategory,
            //   onCategoryTap: (index) {
            //     ref.read(selectedCategoryProvider.notifier).state = index;
            //   },
            // ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const EventSection(),
                    SizedBox(height: AppSizes.spacingXl.h),
                    const InviteBanner(),
                    SizedBox(height: AppSizes.spacingXl.h),
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
