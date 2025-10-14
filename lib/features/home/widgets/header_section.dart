// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HeaderSection extends ConsumerStatefulWidget {
  const HeaderSection({super.key});

  @override
  ConsumerState<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends ConsumerState<HeaderSection> {
  String _currentAddress = "Fetching location...";
  bool _isLoading = true;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToServiceStatus();
  }

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    super.dispose();
  }

  // Watch for changes in location service (ON/OFF)
  void _listenToServiceStatus() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.enabled) {
        _getCurrentLocation(); // Re-fetch when user turns GPS ON
      }
    });
  }

  //  Get current position
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _currentAddress = "Fetching location...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _currentAddress = "Location services disabled";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _currentAddress = "Permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _currentAddress = "Permission permanently denied";
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentAddress = "Error fetching location";
      });
    }
  }

  //  Convert coordinates to readable address
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;

      setState(() {
        _isLoading = false;
        _currentAddress =
            "${place.locality ?? 'Unknown'}, ${place.country ?? ''}";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentAddress = "Error fetching location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5E72E4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 46.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
                Column(
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _currentAddress,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF747688),
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Color(0xFF120D26)),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: Color(0xFF747688),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune, color: Color(0xFF747688), size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: Color(0xFF747688),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
