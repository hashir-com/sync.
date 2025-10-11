// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sync_event/features/Map/data/cache/marker_cache.dart';
import 'package:sync_event/features/Map/data/services/image_processor.dart';
import 'package:sync_event/features/Map/domain/repositories/marker_repository.dart';

/// Implementation of marker repository
class MarkerRepositoryImpl implements MarkerRepository {
  final DefaultCacheManager _cacheManager;

  MarkerRepositoryImpl({DefaultCacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  @override
  Future<BitmapDescriptor> getMarkerIcon(String? imageUrl, String eventId) async {
    final cachedIcon = MarkerCache.getIcon(eventId);
    if (cachedIcon != null) return cachedIcon;

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final cacheKey = 'marker_${eventId}_v3';
        
        // Check cache first
        final cachedFile = await _cacheManager.getFileFromCache(cacheKey);

        Uint8List? imageData;
        if (cachedFile != null) {
          imageData = await cachedFile.file.readAsBytes();
          if (kDebugMode) print('Loaded cached image for marker_$eventId');
        } else {
          // Download and process image
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            imageData = response.bodyBytes;
            final finalData = await ImageProcessor.processImageInIsolate(imageData);
            await _cacheManager.putFile(cacheKey, finalData, fileExtension: 'png');
            imageData = finalData;
            if (kDebugMode) print('Processed and cached image for marker_$eventId');
          }
        }

        if (imageData != null) {
          final markerIcon = BitmapDescriptor.fromBytes(imageData);
          MarkerCache.setIcon(eventId, markerIcon);
          return markerIcon;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading marker icon: $e');
    }

    final defaultIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    );
    MarkerCache.setIcon(eventId, defaultIcon);
    return defaultIcon;
  }

  @override
  BitmapDescriptor? getCachedIcon(String eventId) {
    return MarkerCache.getIcon(eventId);
  }

  @override
  void clearCache() {
    MarkerCache.clearAll();
  }
}