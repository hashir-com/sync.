// lib/features/home/presentation/providers/location_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final userCityProvider = FutureProvider<String>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Your City';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return 'Your City';
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ?? 'Your City';
    }
    return 'Your City';
  } catch (e) {
    return 'Your City';
  }
});

class LocationState {
  final Position? position;
  final bool isDenied;
  final bool isLoading;
  final bool isServiceDisabled;

  LocationState({
    this.position,
    this.isDenied = false,
    this.isLoading = true,
    this.isServiceDisabled = false,
  });

  LocationState copyWith({
    Position? position,
    bool? isDenied,
    bool? isLoading,
    bool? isServiceDisabled,
  }) {
    return LocationState(
      position: position ?? this.position,
      isDenied: isDenied ?? this.isDenied,
      isLoading: isLoading ?? this.isLoading,
      isServiceDisabled: isServiceDisabled ?? this.isServiceDisabled,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isServiceDisabled: true,
          isDenied: false,
          isLoading: false,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isDenied: true,
          isServiceDisabled: false,
          isLoading: false,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = state.copyWith(
        position: pos,
        isDenied: false,
        isServiceDisabled: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isDenied: true, isLoading: false);
    }
  }

  void retry() {
    state = LocationState();
    _checkLocationPermission();
  }

  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {}
  }

  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {}
  }
}

final locationStateProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});