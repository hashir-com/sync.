// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';

class CreateEventOptionTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isRequired;
  final Widget? trailing;
  final VoidCallback onTap;

  const CreateEventOptionTile({
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
    final isDark = ref.watch(themeProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark).withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconXl + 4,
              height: AppSizes.iconXl + 4,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall + 2),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppSizes.iconSmall + 2,
              ),
            ),
            SizedBox(width: AppSizes.spacingMedium + 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        fontSize: AppSizes.fontLarge - 1,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRequired)
                    Text(
                      ' *',
                      style: TextStyle(
                        color: AppColors.getError(isDark),
                        fontSize: AppSizes.fontLarge - 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}