import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/util/responsive_util.dart';

class SmallCardShimmer extends StatelessWidget {
  final bool isDark;

  const SmallCardShimmer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveUtil.isMobile(context) ? 140.w : 180.w;

    return SizedBox(
      height: ResponsiveUtil.isMobile(context) ? 240.h : 280.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: ResponsiveUtil.getResponsiveHorizontalPadding(context),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: AppSizes.spacingMedium),
            child: SizedBox(
              width: cardWidth,
              child: Shimmer.fromColors(
                baseColor: AppColors.getShimmerBase(isDark),
                highlightColor: AppColors.getShimmerHighlight(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(isDark),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingXs),
                    Container(
                      width: double.infinity,
                      height: 12,
                      color: AppColors.getSurface(isDark),
                    ),
                    SizedBox(height: AppSizes.spacingXs),
                    Container(
                      width: 100,
                      height: 10,
                      color: AppColors.getSurface(isDark),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}