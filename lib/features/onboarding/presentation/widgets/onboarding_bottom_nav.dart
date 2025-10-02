import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
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
    context.push('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 270,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Subtitle
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimaryDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22.h),

            // Navigation Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: () => _skip(context),
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: AppColors.textPrimaryDark),
                  ),
                ),

                // Dots Indicator
                Row(
                  children: List.generate(
                    totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage == index ? 14 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? AppColors.backgroundLight
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next Button
                TextButton(
                  onPressed: () => _nextPage(context, ref),
                  child: Text(
                    currentPage == totalPages - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
