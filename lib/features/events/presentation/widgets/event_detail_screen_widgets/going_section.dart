import 'package:flutter/material.dart';

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
              width: 75,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(0, 'assets/images/avatar1.jpg'),
                  _buildAvatar(20, 'assets/images/avatar2.jpg'),
                  _buildCountBadge(40),
                ],
              ),
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Text('Going', style: AppTextStyles.bodyMedium(isDark: false)),
          ],
        ),
        // Invite button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Text(
            'Invite',
            style: AppTextStyles.labelMedium(isDark: false),
          ),
        ),
      ],
    );
  }

  // Helper for avatar images
  Widget _buildAvatar(double left, String asset) => Positioned(
    left: left,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
      ),
    ),
  );

  // Helper for attendee count badge
  Widget _buildCountBadge(double left) => Positioned(
    left: left,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text('+20', style: AppTextStyles.bodySmall(isDark: false)),
      ),
    ),
  );
}
