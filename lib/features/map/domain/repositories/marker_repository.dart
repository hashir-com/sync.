// File: features/map/domain/repositories/marker_repository.dart
// Purpose: Define interface for marker icon operations
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MarkerRepository {
  // GetMarkerIcon: Fetch or create marker icon from image URL
  Future<BitmapDescriptor> getMarkerIcon(String? imageUrl, String eventId);

  // GetCachedIcon: Retrieve cached icon for event
  Future<BitmapDescriptor?> getCachedIcon(String eventId);

  // ClearCache: Remove all cached icons
  void clearCache();
}