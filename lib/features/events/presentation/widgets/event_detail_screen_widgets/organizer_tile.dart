// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';

class OrganizerTile extends StatelessWidget {
  final String organizerName;
  final String? organizerImageUrl;
  final bool isDark;

  const OrganizerTile({
    super.key,
    required this.organizerName,
    this.organizerImageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.getBorder(isDark).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildOrganizerAvatar(),
              SizedBox(width: AppSizes.spacingMedium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organizerName,
                    style: AppTextStyles.bodyMedium(
                      isDark: isDark,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXs),
                  Text(
                    'Organizer',
                    style: AppTextStyles.bodySmall(
                      isDark: isDark,
                    ).copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.getPrimary(isDark).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: AppColors.getPrimary(isDark),
                ),
                SizedBox(width: 4),
                Text(
                  'Chat',
                  style: AppTextStyles.labelMedium(isDark: isDark).copyWith(
                    color: AppColors.getPrimary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerAvatar() {
    // Check if organizer has an image URL
    if (organizerImageUrl != null && organizerImageUrl!.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.getPrimary(isDark).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            organizerImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(),
          ),
        ),
      );
    }

    // Show initial letter avatar if no image
    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    final initial = organizerName.isNotEmpty
        ? organizerName[0].toUpperCase()
        : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimary(isDark),
            AppColors.getPrimary(isDark).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: AppColors.getPrimary(isDark).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXl,
          ),
        ),
      ),
    );
  }
}