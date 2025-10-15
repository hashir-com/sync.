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
    final locationState = ref.watch(locationNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getPrimary(isDark),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXxl.r + 12),
          bottomRight: Radius.circular(AppSizes.radiusXxl.r + 12),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingXl.w,
            AppSizes.paddingLarge.h,
            AppSizes.paddingXl.w,
            AppSizes.paddingLarge.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: Drawer (left) and Notification (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIcon(
                    isDark: isDark,
                    icon: Icons.menu_rounded,
                    onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                  ),
                  _circleIcon(
                    isDark: isDark,
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: AppSizes.spacingLarge.h),

              // Location chip (neatly above search bar)
              _LocationChip(locationState: locationState, isDark: isDark),

              SizedBox(height: AppSizes.spacingMedium.h),

              // Big rounded search bar with nice elevation and centered title
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 620.w),
                  child: _SearchBar(isDark: isDark),
                ),
              ),

              SizedBox(height: AppSizes.spacingMedium.h),

              // Small elegant filter icon under the search bar
              Center(
                child: _circleIcon(
                  isDark: isDark,
                  icon: Icons.tune_rounded,
                  onTap: () {},
                  size: 36.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIcon({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
    double? size,
  }) {
    final double s = size ?? 36.w;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.getTextPrimary(isDark)),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.locationState, required this.isDark});

  final AsyncValue<String> locationState;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium.w,
          vertical: (AppSizes.paddingSmall.h * 0.8),
        ),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: locationState.when(
          data: (address) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: AppColors.getTextPrimary(isDark),
              ),
              SizedBox(width: 6.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 260.w),
                child: Text(
                  address,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          loading: () => Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: AppColors.getTextPrimary(isDark),
                ),
                SizedBox(width: 6.w),
                Text(
                  "Locating...",
                  style: AppTextStyles.bodySmall(
                    isDark: isDark,
                  ).copyWith(color: AppColors.getTextPrimary(isDark)),
                ),
              ],
            ),
          ),
          error: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 16.sp,
                color: AppColors.getTextPrimary(isDark),
              ),
              SizedBox(width: 6.w),
              Text(
                "Error fetching location",
                style: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(color: AppColors.getTextPrimary(isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.isDark});
  final bool isDark;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl.r * 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left search icon (decorative)
          Positioned(
            left: 14.w,
            child: Icon(
              Icons.search_rounded,
              size: AppSizes.iconLarge.sp,
              color: AppColors.getTextSecondary(false),
            ),
          ),
          // Centered text field
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Start your search",
              hintStyle: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                color: AppColors.getTextSecondary(false),
                fontWeight: FontWeight.w700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXxl.r * 1.4),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge.w,
                vertical: AppSizes.paddingMedium.h + 2,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.w700,
            ),
            onSubmitted: (v) {},
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
