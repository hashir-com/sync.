import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/util/responsive_util.dart';
import 'package:sync_event/core/util/theme_util.dart';

class ErrorView extends ConsumerWidget {
  final String message;
  final dynamic error;

  const ErrorView({super.key, required this.message, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ThemeUtils.isDark(context);

    return Center(
      child: Padding(
        padding: ResponsiveUtil.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.getIconSize(context, baseSize: AppSizes.iconXxl),
              color: AppColors.getError(isDark),
            ),
            SizedBox(
              height: AppSizes.getHeightSpacing(
                context,
                baseSpacing: AppSizes.spacingMedium,
              ),
            ),
            Text(
              message,
              style: AppTextStyles.headingSmall(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            if (error != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.spacingMedium,
                  horizontal: AppSizes.paddingMedium,
                ),
                child: Text(
                  error is Failure ? error.message : error.toString(),
                  style: AppTextStyles.bodyMedium(isDark: isDark),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              height: AppSizes.getHeightSpacing(
                context,
                baseSpacing: AppSizes.spacingMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
