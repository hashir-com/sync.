import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class BannerShimmer extends StatelessWidget {
  final bool isDark;

  const BannerShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveUtil.isMobile(context) ? 220 : 260,
      child: Shimmer.fromColors(
        baseColor: AppColors.getShimmerBase(isDark),
        highlightColor: AppColors.getShimmerHighlight(isDark),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
        ),
      ),
    );
  }
}
