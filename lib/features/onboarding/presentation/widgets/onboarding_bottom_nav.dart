import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
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
      ref.read(onboardingProvider.notifier).nextPage(totalPages);
    } else {
      context.go('/login');
    }
  }

  void _skip(BuildContext context) {
    context.go('/login'); // Changed from push to go for consistent navigation
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium.w,
        vertical: AppSizes.paddingLarge.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusLarge.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end, // Keep buttons at bottom
        children: [
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: AppSizes.fontLarge.sp,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              semanticsLabel: title,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall.h),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: AppSizes.fontSmall.sp,
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              semanticsLabel: subtitle,
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: 'Skip onboarding',
                child: TextButton(
                  onPressed: () => _skip(context),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: AppSizes.fontMedium.sp,
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: controller,
                count: totalPages,
                effect: WormEffect(
                  dotWidth: AppSizes.dotIndicatorActiveWidth.w,
                  dotHeight: AppSizes.dotIndicatorHeight.h,
                  spacing: AppSizes.paddingSmall.w,
                  activeDotColor: theme.colorScheme.onPrimary,
                  dotColor: theme.colorScheme.onPrimary.withOpacity(0.5),
                ),
              ),
              Semantics(
                label: currentPage == totalPages - 1
                    ? 'Get started'
                    : 'Next page',
                child: TextButton(
                  onPressed: () => _nextPage(context, ref),
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      48.w,
                      AppSizes.buttonHeight.h,
                    ), // Touch-friendly size
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium.w,
                    ),
                    foregroundColor:
                        theme.colorScheme.onPrimary, // Ripple effect color
                  ),
                  child: Text(
                    currentPage == totalPages - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: AppSizes.fontMedium.sp,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
