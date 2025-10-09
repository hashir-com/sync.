import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract repository for marker operations
abstract class MarkerRepository {
  /// Get marker icon for event
  Future<BitmapDescriptor> getMarkerIcon(String? imageUrl, String eventId);

  /// Get cached icon if available
  BitmapDescriptor? getCachedIcon(String eventId);

  /// Clear all marker cache
  void clearCache();
}