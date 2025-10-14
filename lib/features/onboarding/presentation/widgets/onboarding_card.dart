// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/theme_util.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  const OnboardingCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = ThemeUtils.isDark(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge.w),
      child: Column(
        children: [
          // Top spacing
          SizedBox(height: AppSizes.spacingXxxl.h * 2),

          // Image container
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.6,
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
                  border: Border.all(
                    color: AppColors.getBorder(isDark).withOpacity(0.1),
                    width: AppSizes.borderWidthThin,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    width: size.width * 0.9,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: AppSizes.iconXxl,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
