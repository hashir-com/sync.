// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/core/constants/app_sizes.dart';
import 'package:sync_event/core/constants/app_text_styles.dart';
import 'package:sync_event/core/constants/app_theme.dart';

// ============================================
// Providers for Location State
// ============================================

final locationAddressProvider = StateProvider<String>(
  (ref) => "Fetching location...",
);
final locationLoadingProvider = StateProvider<bool>((ref) => true);

// ============================================
// Location Service Notifier
// ============================================

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
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
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

// ============================================
// Header Section Widget
// ============================================

class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final locationState = ref.watch(locationNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXxl.r + 12),
          bottomRight: Radius.circular(AppSizes.radiusXxl.r + 12),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingXl.w,
              46.h,
              AppSizes.paddingXl.w,
              AppSizes.paddingLarge.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: AppSizes.iconMedium,
                  ),
                ),
                _buildLocationDisplay(locationState, isDark),
                _buildNotificationIcon(isDark),
              ],
            ),
          ),
          _buildSearchBar(isDark),
        ],
      ),
    );
  }

  Widget _buildLocationDisplay(AsyncValue<String> locationState, bool isDark) {
    return Column(
      children: [
        Text(
          'Current Location',
          style: AppTextStyles.labelSmall(
            isDark: false,
          ).copyWith(color: Colors.white70),
        ),
        locationState.when(
          data: (address) => Text(
            address,
            style: AppTextStyles.bodyMedium(isDark: false).copyWith(
              color: Colors.white,
              fontSize: AppSizes.fontMedium - 1.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          loading: () => _buildLocationShimmer(),
          error: (_, __) => Text(
            "Error fetching location",
            style: AppTextStyles.bodyMedium(isDark: false).copyWith(
              color: Colors.white,
              fontSize: AppSizes.fontMedium - 1.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.8),
      child: Text(
        "Location loading...",
        style: AppTextStyles.bodySmall(
          isDark: false,
        ).copyWith(color: Colors.white, fontSize: AppSizes.fontMedium - 1.sp),
      ),
    );
  }

  Widget _buildNotificationIcon(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingSmall.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall.r),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: Colors.white,
        size: AppSizes.iconMedium,
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingXl.w,
        0,
        AppSizes.paddingXl.w,
        AppSizes.paddingXl.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: AppSizes.cardElevationMedium,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge.w,
              ),
              child: Icon(
                Icons.search,
                color: AppColors.getTextSecondary(false),
                size: AppSizes.iconMedium,
              ),
            ),
            Expanded(
              child: TextField(
                
                style: AppTextStyles.bodySmall(isDark: false),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyles.bodySmall(
                    isDark: false,
                  ).copyWith(color: AppColors.getTextSecondary(false)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(AppSizes.paddingSmall.w),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium.w,
                vertical: AppSizes.paddingSmall.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusSemiRound.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.getTextSecondary(false),
                    size: AppSizes.iconSmall - 2,
                  ),
                  SizedBox(width: AppSizes.spacingXs),
                  Text(
                    'Filters',
                    style: AppTextStyles.bodyMedium(isDark: false).copyWith(
                      color: AppColors.getTextSecondary(false),
                      fontSize: AppSizes.fontMedium - 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
