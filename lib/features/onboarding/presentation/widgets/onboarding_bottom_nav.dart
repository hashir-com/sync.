// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
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
      ref.read(onboardingProvider.notifier).nextPage(totalPages);
    } else {
      context.go('/login');
    }
  }

  void _skip(BuildContext context) {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge.w,
        vertical: AppSizes.paddingXl.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSemiRound.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: AppSizes.cardElevationHigh,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                title,
                style: AppTextStyles.headingLarge(isDark: false).copyWith(
                  fontSize: AppSizes.fontXxxl.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
                semanticsLabel: title,
              ),
            ),
            SizedBox(height: AppSizes.spacingMaxl.h),

            // Subtitle
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                subtitle,
                style: AppTextStyles.bodyMedium(isDark: false).copyWith(
                  fontSize: AppSizes.fontMedium.sp,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                semanticsLabel: subtitle,
              ),
            ),
            SizedBox(height: AppSizes.spacingXl.h),

            // Navigation controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button
                Semantics(
                  label: 'Skip onboarding',
                  child: TextButton(
                    onPressed: () => _skip(context),
                    style: TextButton.styleFrom(
                      minimumSize: Size(
                        AppSizes.buttonHeightSmall.w,
                        AppSizes.buttonHeightSmall.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium.w,
                        vertical: AppSizes.paddingSmall.h,
                      ),
                      foregroundColor: Colors.white.withOpacity(0.9),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelLarge(isDark: false).copyWith(
                        fontSize: AppSizes.fontMedium.sp,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Page indicator
                SmoothPageIndicator(
                  controller: controller,
                  count: totalPages,
                  effect: WormEffect(
                    dotWidth: AppSizes.dotIndicatorActiveWidth.w,
                    dotHeight: AppSizes.dotIndicatorHeight.h,
                    spacing: AppSizes.dotIndicatorSpacing.w,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.4),
                    strokeWidth: 1.5,
                  ),
                ),

                // Next/Get Started button
                Semantics(
                  label: currentPage == totalPages - 1
                      ? 'Get started'
                      : 'Next page',
                  child: TextButton(
                    onPressed: () => _nextPage(context, ref),
                    style: TextButton.styleFrom(
                      minimumSize: Size(
                        AppSizes.buttonHeightSmall.w,
                        AppSizes.buttonHeightSmall.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium.w,
                        vertical: AppSizes.paddingSmall.h,
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusRound.r,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentPage == totalPages - 1
                              ? 'Get Started'
                              : 'Next',
                          style: AppTextStyles.labelLarge(isDark: false)
                              .copyWith(
                                fontSize: AppSizes.fontMedium.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(width: AppSizes.spacingXs.w),
                        Icon(
                          currentPage == totalPages - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: AppSizes.iconSmall.sp,
                          color: Colors.white,
                        ),
                      ],
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
