import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

/// Cache for storing marker icons and built markers
class MarkerCache {
  static final Map<String, BitmapDescriptor> _icons = {};
  static final Set<Marker> _markers = {};
  static bool _isBuilt = false;
  static String _lastEventHash = '';

  /// Check if markers need to be rebuilt based on events
  static bool needsRebuild(List<EventEntity> events) {
    final currentHash = '${events.length}:${events.map((e) => e.id).join(',')}';
    if (_lastEventHash != currentHash) {
      _lastEventHash = currentHash;
      _isBuilt = false;
      return true;
    }
    return !_isBuilt;
  }

  /// Mark markers as built
  static void markBuilt() => _isBuilt = true;

  /// Get cached icon for event
  static BitmapDescriptor? getIcon(String eventId) => _icons[eventId];

  /// Cache icon for event
  static void setIcon(String eventId, BitmapDescriptor icon) =>
      _icons[eventId] = icon;

  /// Get all cached markers
  static Set<Marker> get markers => _markers;

  /// Set markers in cache
  static void setMarkers(Set<Marker> markers) {
    _markers.clear();
    _markers.addAll(markers);
  }

  /// Clear all cache
  static void clearAll() {
    _icons.clear();
    _markers.clear();
    _isBuilt = false;
    _lastEventHash = '';
  }

  /// Clear specific event icon
  static void clearIcon(String eventId) {
    _icons.remove(eventId);
  }
}