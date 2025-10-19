// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';

final locationAddressProvider = StateProvider<String>(
  (ref) => "Fetching location...",
);
final locationLoadingProvider = StateProvider<bool>((ref) => true);

class LocationNotifier extends StateNotifier<AsyncValue<String>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    _getCurrentLocation();
    _listenToServiceStatus();
  }

  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    super.dispose();
  }

  void _listenToServiceStatus() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        _getCurrentLocation();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    state = const AsyncValue.loading();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = const AsyncValue.data("Location services disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = const AsyncValue.data("Permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = const AsyncValue.data("Permission permanently denied");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getAddressFromLatLng(position);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;
      state = AsyncValue.data(
        "${place.locality ?? 'Unknown'}, ${place.country ?? ''}",
      );
    } catch (e) {
      state = const AsyncValue.data("Error fetching location");
    }
  }

  void refresh() => _getCurrentLocation();
}

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<String>>((ref) {
      return LocationNotifier();
    });

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(isDark),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXl.w,
            vertical: AppSizes.paddingLarge.h,
          ),
          child: Column(
            children: [
              // -------- Search Bar with Drawer Icon --------
              Row(
                children: [
                  // Drawer Icon
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound.r),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: AppSizes.iconXl.w,
                      height: AppSizes.iconXl.w,
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getShadow(isDark),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu,
                        color: AppColors.getTextPrimary(isDark),
                        size: AppSizes.iconMedium.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: AppSizes.spacingMedium.w),

                  // Search Bar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(isDark),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusRound.r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getShadow(isDark),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          print("Searching for: $value");
                        },
                        onSubmitted: (value) {
                          print("Search submitted: $value");
                        },
                        decoration: InputDecoration(
                          hintText: "Start your search",
                          hintStyle: AppTextStyles.bodyMedium(
                            isDark: isDark,
                          ).copyWith(color: AppColors.getTextSecondary(isDark)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.getTextPrimary(isDark),
                            size: AppSizes.iconMedium.sp,
                          ),
                          filled: true,
                          fillColor: AppColors.getSurface(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusRound.r,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingLarge.w,
                            vertical: AppSizes.paddingLarge.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusRound.r,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusRound.r,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.getPrimary(isDark),
                              width: AppSizes.borderWidthMedium,
                            ),
                          ),
                        ),
                        style: AppTextStyles.bodyMedium(
                          isDark: isDark,
                        ).copyWith(color: AppColors.getTextPrimary(isDark)),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.spacingXxl.h),

              // -------- Categories Row --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryItem(
                    context: context,
                    isDark: isDark,
                    icon: '🔔',
                    label: 'Notification',
                    isSelected: true,
                  ),
                  _buildCategoryItem(
                    context: context,
                    isDark: isDark,
                    icon: '🎯',
                    label: 'Filter',
                    hasNewBadge: true,
                  ),
                  _buildCategoryItem(
                    context: context,
                    isDark: isDark,
                    icon: '⭐',
                    label: 'Popular',
                    hasNewBadge: true,
                  ),
                ],
              ),

              SizedBox(height: AppSizes.spacingMedium.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required bool isDark,
    required String icon,
    required String label,
    bool isSelected = false,
    bool hasNewBadge = false,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(icon, style: TextStyle(fontSize: AppSizes.iconLarge.sp)),
            if (hasNewBadge)
              Positioned(
                top: -AppSizes.spacingXs.h,
                right: -AppSizes.paddingXxl.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall.w,
                    vertical: AppSizes.paddingXs.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimary(isDark),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMedium.r,
                    ),
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.labelSmall(isDark: isDark).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSizes.spacingSmall.h),
        Text(
          label,
          style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
            color: isSelected
                ? AppColors.getTextPrimary(isDark)
                : AppColors.getTextSecondary(isDark),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (isSelected)
          Container(
            margin: EdgeInsets.only(top: AppSizes.spacingXs.h),
            height: AppSizes.borderWidthMedium.h,
            width: AppSizes.radiusRound.w,
            decoration: BoxDecoration(
              color: AppColors.getPrimary(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusXs.r),
            ),
          ),
      ],
    );
  }
}
