// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';
import 'package:sync_event/features/onboarding/controller/onboarding_controler.dart';

class OnboardingBottomNav extends ConsumerWidget {
  final PageController controller;
  final int currentPage;
  final int totalPages;
  final String title;
  final String subtitle;

  const OnboardingBottomNav({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
    required this.title,
    required this.subtitle,
  });

  void _nextPage(BuildContext context, WidgetRef ref) {
    if (currentPage < totalPages - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      ref.read(onboardingProvider.notifier).setPage(currentPage + 1);
    } else {
      Future.microtask(() {
        if (context.mounted) {
          context.go('/login');
        }
      });
    }
  }

  void _skip(BuildContext context) {
    Future.microtask(() {
      if (context.mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);
    final fontMultiplier = ResponsiveUtil.getFontSizeMultiplier(context);
    final spacing = ResponsiveUtil.getSpacing(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use constraints for fine-tuned responsiveness within the available space
        final maxWidth = constraints.maxWidth;
        final isNarrow =
            maxWidth <
            400; // Additional check for very narrow screens (e.g., mobile portrait)

        return Container(
          width: double.infinity, // Ensure full width
          constraints: BoxConstraints(
            minHeight:
                ResponsiveUtil.getButtonHeight(context) *
                2.5, // Minimum height for visibility
            maxHeight: constraints.maxHeight > 0
                ? constraints.maxHeight
                : double.infinity,
          ),
          padding: ResponsiveUtil.getResponsiveVerticalPadding(context)
              .copyWith(
                left: ResponsiveUtil.getPadding(context) * 1.5,
                right: ResponsiveUtil.getPadding(context) * 1.5,
              ),
          decoration: BoxDecoration(
            color: AppColors.getPrimary(isDark),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                ResponsiveUtil.getBorderRadius(context, baseRadius: 20.0),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(isDark),
                blurRadius: ResponsiveUtil.getElevation(
                  context,
                  baseElevation: 8.0,
                ),
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: true, // Ensure bottom safe area on mobile
            child: IntrinsicHeight(
              // Use IntrinsicHeight to size based on children
              child: Padding(
                padding: EdgeInsets.only(top: spacing, bottom: spacing * 0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title - Adjust alignment and size based on width
                    Expanded(
                      // Allow title to take space but not overflow
                      flex: 2,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrow ? spacing : spacing * 0.5,
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: (32.0 * fontMultiplier).clamp(
                                20.0,
                                36.0,
                              ), // Adjusted clamp for mobile
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: isNarrow
                                ? TextAlign.center
                                : TextAlign.start,
                            maxLines: isNarrow ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            semanticsLabel: title,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 0.5),

                    // Subtitle - Center and clamp lines for narrow screens
                    Expanded(
                      flex: 1,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: (16.0 * fontMultiplier).clamp(
                                12.0,
                                18.0,
                              ),
                              color: Colors.white.withOpacity(0.85),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: isNarrow ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            semanticsLabel: subtitle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 0.25),

                    // Navigation controls - Flexible row without scroll
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Skip button - Expanded for flexibility
                          Expanded(
                            flex: 1,
                            child: Semantics(
                              label: 'Skip onboarding',
                              child: TextButton(
                                onPressed: () => _skip(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spacing * 0.25,
                                    vertical: spacing * 0.125,
                                  ),
                                  foregroundColor: Colors.white.withOpacity(
                                    0.9,
                                  ),
                                  minimumSize: const Size(
                                    0,
                                    32,
                                  ), // Allow shrink
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: (14.0 * fontMultiplier).clamp(
                                      12.0,
                                      16.0,
                                    ),
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Page indicator - Fixed width, centered
                          const Spacer(),
                          SizedBox(
                            width: (maxWidth * 0.2).clamp(
                              80.0,
                              200.0,
                            ), // Responsive width
                            child: SmoothPageIndicator(
                              controller: controller,
                              count: totalPages,
                              effect: WormEffect(
                                dotWidth: (12.0 * fontMultiplier).clamp(
                                  6.0,
                                  14.0,
                                ),
                                dotHeight: (8.0 * fontMultiplier).clamp(
                                  4.0,
                                  10.0,
                                ),
                                spacing: (6.0 * fontMultiplier).clamp(3.0, 8.0),
                                activeDotColor: Colors.white,
                                dotColor: Colors.white.withOpacity(0.4),
                                strokeWidth: 1.0,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Next/Get Started button - Expanded for flexibility
                          Expanded(
                            flex: 1,
                            child: Semantics(
                              label: currentPage == totalPages - 1
                                  ? 'Get started'
                                  : 'Next page',
                              child: TextButton(
                                onPressed: () => _nextPage(context, ref),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spacing * 0.25,
                                    vertical: spacing * 0.125,
                                  ),
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtil.getBorderRadius(context),
                                    ),
                                  ),
                                  minimumSize: const Size(0, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        currentPage == totalPages - 1
                                            ? 'Get Started'
                                            : 'Next',
                                        style: TextStyle(
                                          fontSize: (14.0 * fontMultiplier)
                                              .clamp(12.0, 16.0),
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!isNarrow) ...[
                                      // Hide icon on very narrow to save space
                                      SizedBox(width: spacing * 0.125),
                                      Icon(
                                        currentPage == totalPages - 1
                                            ? Icons.check_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: (18.0 * fontMultiplier).clamp(
                                          14.0,
                                          20.0,
                                        ),
                                        color: Colors.white,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
