// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/util/theme_util.dart';

class EditEventOptionTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isRequired;
  final Widget? trailing;
  final VoidCallback onTap;

  const EditEventOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isRequired,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      splashColor: AppColors.getPrimary(isDark).withOpacity(0.1),
      highlightColor: AppColors.getPrimary(isDark).withOpacity(0.05),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark).withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: AppColors.getBorder(isDark).withOpacity(0.3),
            width: AppSizes.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: AppSizes.avatarMedium,
              height: AppSizes.avatarMedium,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppSizes.iconMedium,
              ),
            ),
            SizedBox(width: AppSizes.spacingMedium),

            // Label with required indicator
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRequired)
                    Text(
                      ' *',
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        color: AppColors.getError(isDark),
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Trailing widget if provided
            if (trailing != null) ...[
              SizedBox(width: AppSizes.spacingSmall),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}