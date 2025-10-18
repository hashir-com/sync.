import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

class MarkerCache {
  static final Map<String, BitmapDescriptor> _icons = {};
  static final Set<Marker> _markers = {};
  static bool _isBuilt = false;
  static String _lastEventHash = '';

  static bool needsRebuild(List<EventEntity> events) {
    final currentHash = '${events.length}:${events.map((e) => '${e.id}:${e.status}:${e.updatedAt.millisecondsSinceEpoch}').join(',')}';
    print('MarkerCache: needsRebuild - lastHash=$_lastEventHash, currentHash=$currentHash');
    if (_lastEventHash != currentHash) {
      _lastEventHash = currentHash;
      _isBuilt = false;
      print('MarkerCache: Rebuild required due to hash change');
      return true;
    }
    if (!_isBuilt) {
      print('MarkerCache: Rebuild required as not built');
      return true;
    }
    print('MarkerCache: No rebuild needed');
    return false;
  }

  static void markBuilt() {
    _isBuilt = true;
    print('MarkerCache: Marked as built');
  }

  static BitmapDescriptor? getIcon(String eventId) => _icons[eventId];

  static void setIcon(String eventId, BitmapDescriptor icon) {
    _icons[eventId] = icon;
    print('MarkerCache: Cached icon for eventId=$eventId');
  }

  static Set<Marker> get markers => _markers;

  static void setMarkers(Set<Marker> markers) {
    _markers.clear();
    _markers.addAll(markers);
    print('MarkerCache: Set ${markers.length} markers');
  }

  static void clearAll() {
    _icons.clear();
    _markers.clear();
    _isBuilt = false;
    _lastEventHash = '';
    print('MarkerCache: Cleared all');
  }

  static void clearIcon(String eventId) {
    _icons.remove(eventId);
    print('MarkerCache: Cleared icon for eventId=$eventId');
  }
}