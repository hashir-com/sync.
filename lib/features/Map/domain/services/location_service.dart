// ignore_for_file: deprecated_member_use

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Service for handling location operations
class LocationService {
  // Get current location and return camera position
  Future<CameraPosition?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
        tilt: 45,
      );
    } catch (e) {
      throw LocationException('Error getting location: $e');
    }
  }
}

// Custom exception for location errors
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}
