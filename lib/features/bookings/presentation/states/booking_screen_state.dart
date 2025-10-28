// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/error/failures.dart';

class BookingLoadingWidget extends StatelessWidget {
  const BookingLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: AppSizes.spacingMedium),
            _buildShimmerCard(isDark, height: 150),
            SizedBox(height: AppSizes.spacingXxl),
            _buildShimmerCard(isDark, height: 200),
            SizedBox(height: AppSizes.spacingXxl),
            _buildShimmerCard(isDark, height: 180),
            SizedBox(height: AppSizes.spacingXxl),
            _buildShimmerCard(isDark, height: 220),
            SizedBox(height: AppSizes.spacingXxl),
            _buildShimmerCard(isDark, height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark, {required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.getSurface(isDark),
      highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      ),
    );
  }
}

class BookingErrorWidget extends StatelessWidget {
  final dynamic error;
  final bool isDark;

  const BookingErrorWidget({
    super.key,
    required this.error,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_rounded,
            size: AppSizes.iconXxl * 2,
            color: AppColors.getError(isDark),
          ),
          SizedBox(height: AppSizes.spacingLarge),
          Text(
            error is String ? error : 'Error loading event',
            style: AppTextStyles.headingSmall(isDark: isDark),
          ),
          if (error != null && error is! String)
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
              child: Text(
                error is Failure ? error.message : error.toString(),
                style: AppTextStyles.bodyMedium(isDark: isDark),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Text(
              'Go Back',
              style: AppTextStyles.labelMedium(isDark: isDark)
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}