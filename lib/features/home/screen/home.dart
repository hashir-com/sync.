import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/screen/drawer.dart';
import 'package:sync_event/features/home/widgets/event_section.dart';
import 'package:sync_event/features/home/widgets/header_section.dart';
import 'package:sync_event/features/home/widgets/invite_banner.dart';

// Selected Category Provider

final selectedCategoryProvider = StateProvider<int>((ref) => 0);

// Home Screen Widget

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
          margin: AppSizes.getResponsivePadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.getBorderRadius(context, baseRadius: 8),
            ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(ref, context),
            color: AppColors.getPrimary(isDark),
            backgroundColor: AppColors.getCard(isDark),
            child: Column(
              children: [
                const HeaderSection(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            AppSizes.getAppBarHeight(context) -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const EventSection(),
                            SizedBox(
                              height: AppSizes.getHeightSpacing(
                                context,
                                baseSpacing: 20,
                              ),
                            ),
                            const InviteBanner(),
                            SizedBox(
                              height: AppSizes.getHeightSpacing(
                                context,
                                baseSpacing: 20,
                              ),
                            ),
                            // Add bottom padding for better UX
                            SizedBox(
                              height:
                                  ResponsiveUtil.getBottomPadding(context) +
                                  AppSizes.getHeightSpacing(
                                    context,
                                    baseSpacing: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      drawer: const CustomDrawer(),
    );
  }
}
