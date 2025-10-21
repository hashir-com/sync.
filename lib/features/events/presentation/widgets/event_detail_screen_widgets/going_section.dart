import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

// Widget for the "Going" avatars and Invite button
class GoingSection extends StatelessWidget {
  const GoingSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Build going section with avatars and button
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar stack and "Going" text
        Row(
          children: [
            SizedBox(
              width: 75.w,
              height: 40.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(0, 'assets/images/avatar1.jpg'),
                  _buildAvatar(20, 'assets/images/avatar2.jpg'),
                  _buildCountBadge(40),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall.w),
            Text('Going', style: AppTextStyles.bodyMedium(isDark: false)),
          ],
        ),
        // Invite button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r)),
          child: Text('Invite', style: AppTextStyles.labelMedium(isDark: false)),
        ),
      ],
    );
  }

  // Helper for avatar images
  Widget _buildAvatar(double left, String asset) => Positioned(
        left: left.w,
        child: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
            image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
          ),
        ),
      );

  // Helper for attendee count badge
  Widget _buildCountBadge(double left) => Positioned(
        left: left.w,
        child: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: Center(child: Text('+20', style: AppTextStyles.bodySmall(isDark: false))),
        ),
      );
}