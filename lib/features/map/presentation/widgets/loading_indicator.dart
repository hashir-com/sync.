import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/map/presentation/provider/map_providers.dart';

class LoadingIndicatorWidget extends ConsumerWidget {
  const LoadingIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingMarkersProvider);
    final isDark = ref.watch(themeProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading
          ? TweenAnimationBuilder<double>(
              key: const ValueKey('loading'),
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXxl,
                  vertical: AppSizes.paddingMedium + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(isDark),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSemiRound),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadow(isDark),
                      blurRadius: AppSizes.cardElevationHigh,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: AppSizes.iconSmall - 2,
                      height: AppSizes.iconSmall - 2,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: AppSizes.spacingMedium),
                    Text(
                      'Loading markers...',
                      style: AppTextStyles.labelLarge(isDark: isDark).copyWith(
                        color: Colors.white,
                        fontSize: AppSizes.fontMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('not_loading')),
    );
  }
}