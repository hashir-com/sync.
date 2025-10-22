import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/util/responsive_helper.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';
import 'package:sync_event/features/home/presentation/screen/drawer.dart';
import 'package:sync_event/features/home/presentation/widgets/event_section.dart';
import 'package:sync_event/features/home/presentation/widgets/header_section.dart';
import 'package:sync_event/features/home/presentation/widgets/invite_banner.dart';

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
    final navigationType = ResponsiveHelper.getNavigationType(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(ref, context),
            color: AppColors.getPrimary(isDark),
            backgroundColor: AppColors.getCard(isDark),
            child: SafeArea(
              child: Column(
                children: [
                  const HeaderSection(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight -
                              ResponsiveHelper.getAppBarHeight(context) -
                              MediaQuery.of(context).padding.top -
                              (navigationType == NavigationType.drawer 
                                  ? ResponsiveHelper.getBottomNavHeight(context) 
                                  : 0),
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: ResponsiveHelper.getResponsivePadding(context),
                            child: Column(
                              children: [
                                const EventSection(),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeightSpacing(
                                    context,
                                    mobile: 20,
                                    tablet: 24,
                                    desktop: 32,
                                  ),
                                ),
                                const InviteBanner(),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeightSpacing(
                                    context,
                                    mobile: 20,
                                    tablet: 24,
                                    desktop: 32,
                                  ),
                                ),
                                // Add bottom padding for better UX
                                SizedBox(
                                  height: ResponsiveHelper.getBottomPadding(context) +
                                      ResponsiveHelper.getResponsiveHeightSpacing(
                                        context,
                                        mobile: 16,
                                        tablet: 20,
                                        desktop: 24,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      drawer: navigationType == NavigationType.drawer ? const CustomDrawer() : null,
    );
  }
}
