import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_sizes.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  const OnboardingCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium.w),
      child: Column(
        children: [
          SizedBox(height: AppSizes.paddingLarge.h * 2), // Push image down
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.6, // Increased height
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withOpacity(
                    0.1,
                  ), // Subtle background
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium.r,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium.r,
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    width:
                        size.width *
                        0.9, // Adjusted from 1.2 to prevent overflow
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
