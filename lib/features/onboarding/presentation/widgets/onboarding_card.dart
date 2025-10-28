// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  const OnboardingCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = ThemeUtils.isDark(context);
    final fontMultiplier = ResponsiveUtil.getFontSizeMultiplier(context);  // For icon scaling

    return Padding(
      padding: ResponsiveUtil.getResponsiveHorizontalPadding(context),
      child: Column(
        children: [
          // Top spacing
          SizedBox(height: ResponsiveUtil.getSpacing(context) * 3),

          // Image container
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: size.width * (ResponsiveUtil.isMobile(context) ? 0.9 : 0.8),  // Tighter on larger screens
                height: size.height * (ResponsiveUtil.isMobile(context) ? 0.6 : 0.5),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(ResponsiveUtil.getBorderRadius(context, baseRadius: 16.0)),
                  border: Border.all(
                    color: AppColors.getBorder(isDark).withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveUtil.getBorderRadius(context, baseRadius: 16.0)),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    width: size.width * (ResponsiveUtil.isMobile(context) ? 0.9 : 0.8),
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48.0 * fontMultiplier,  // Scaled icon
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