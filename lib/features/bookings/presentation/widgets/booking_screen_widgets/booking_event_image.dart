import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class BookingEventImageCard extends StatelessWidget {
  final EventEntity event;
  final bool isDark;

  const BookingEventImageCard({
    super.key,
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge.r),
      child: event.imageUrl != null
          ? Image.network(
              event.imageUrl!,
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null ? child : _buildShimmerLoader(),
              errorBuilder: (context, error, stackTrace) =>
                  _buildErrorPlaceholder(),
            )
          : _buildErrorPlaceholder(),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.getSurface(isDark),
      highlightColor: AppColors.getBorder(isDark).withOpacity(0.5),
      child: Container(
        height: 200.h,
        width: double.infinity,
        color: AppColors.getSurface(isDark),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getPrimary(isDark),
            AppColors.getPrimary(isDark).withOpacity(0.6),
          ],
        ),
      ),
      child: Icon(
        Icons.event,
        size: AppSizes.iconXxl,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}