// File: features/map/data/repositories/marker_repositories_impl.dart
// Purpose: Implement marker icon fetching and caching with responsive circular event image markers
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';  // For kIsWeb
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sync_event/features/map/data/cache/marker_cache.dart';
import 'package:sync_event/features/map/data/services/image_processor.dart';
import 'package:sync_event/features/map/domain/repositories/marker_repository.dart';

class MarkerRepositoryImpl implements MarkerRepository {
  final DefaultCacheManager _cacheManager;

  MarkerRepositoryImpl({DefaultCacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  // GetMarkerIcon: Fetch and process event image into a responsive circular marker with border
  @override
  Future<BitmapDescriptor> getMarkerIcon(
    String? imageUrl,
    String eventId,
  ) async {
    print(
      'MarkerRepositoryImpl: Getting icon for eventId=$eventId, imageUrl=$imageUrl',
    );
    final cachedIcon = await getCachedIcon(eventId);
    if (cachedIcon != null) {
      print('MarkerRepositoryImpl: Using cached icon for eventId=$eventId');
      return cachedIcon;
    }

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Responsive cache key: Platform-specific to avoid mixing
        final platformSuffix = kIsWeb ? '_web' : '_mobile';
        final cacheKey = 'marker_${eventId}_v3$platformSuffix';
        final cachedFile = await _cacheManager.getFileFromCache(cacheKey);

        Uint8List? imageData;
        if (cachedFile != null) {
          imageData = await cachedFile.file.readAsBytes();
          print(
            'MarkerRepositoryImpl: Loaded cached image for eventId=$eventId',
          );
        } else {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            imageData = response.bodyBytes;
            print('MarkerRepositoryImpl: Fetched image for eventId=$eventId');
          } else {
            print(
              'MarkerRepositoryImpl: Failed to fetch image for eventId=$eventId, status=${response.statusCode}',
            );
          }
        }

        if (imageData != null) {
          // Responsive: Smaller on web to match mobile visual size (counters 2x DPR)
          final int targetSize = kIsWeb ? 45 : 90;
          // Process image into a responsive circular marker with border
          final circularImage = await _createCircularMarker(imageData, targetSize: targetSize);
          final markerIcon = BitmapDescriptor.fromBytes(circularImage);
          MarkerCache.setIcon(eventId, markerIcon);
          await _cacheManager.putFile(
            cacheKey,
            circularImage,
            fileExtension: 'png',
          );
          print(
            'MarkerRepositoryImpl: Created and cached circular marker for eventId=$eventId (platform: ${kIsWeb ? "web" : "mobile"}, size: ${targetSize * 2}px)',
          );
          return markerIcon;
        }
      }
    } catch (e) {
      print(
        'MarkerRepositoryImpl: Error processing icon for eventId=$eventId: $e',
      );
    }

    // Fallback to default marker if image fails
    final defaultIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    );
    MarkerCache.setIcon(eventId, defaultIcon);
    print('MarkerRepositoryImpl: Using default icon for eventId=$eventId');
    return defaultIcon;
  }

  // CreateCircularMarker: Convert image to a responsive circular marker with a white border
  Future<Uint8List> _createCircularMarker(Uint8List imageData, {required int targetSize}) async {
    // Resize image to target size while maintaining aspect ratio
    final resizedImage = await ImageProcessor.processImageInIsolate(
      imageData,
      targetSize: targetSize,
    );

    // Responsive canvas: Double the targetSize for border room (proportional to original 180px)
    final int canvasSize = targetSize * 2;
    final double borderRatio = 170 / 180;  // Original inner-to-canvas ratio (~0.944)
    final int innerSize = (canvasSize * borderRatio).round();

    // Create a PictureRecorder and Canvas for drawing
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Draw white circular border
    final borderPaint = ui.Paint()
      ..color = const ui.Color.fromARGB(255, 255, 255, 255)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(ui.Offset(canvasSize / 2, canvasSize / 2), canvasSize / 2, borderPaint);

    // Decode resized image
    final codec = await ui.instantiateImageCodec(resizedImage);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Draw circular clipped image
    canvas.save();
    canvas.clipRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(
          (canvasSize - innerSize) / 2,
          (canvasSize - innerSize) / 2,
          innerSize.toDouble(),
          innerSize.toDouble(),
        ),
        ui.Radius.circular(innerSize / 2),
      ),
    );
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(
        (canvasSize - innerSize) / 2,
        (canvasSize - innerSize) / 2,
        innerSize.toDouble(),
        innerSize.toDouble(),
      ),
      ui.Paint(),
    );
    canvas.restore();

    // Convert canvas to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(canvasSize, canvasSize);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    print(
      'MarkerRepositoryImpl: Created circular marker with canvas=${canvasSize}px, inner=${innerSize}px (platform: ${kIsWeb ? "web" : "mobile"})',
    );
    return bytes!.buffer.asUint8List();
  }

  // GetCachedIcon: Retrieve cached icon asynchronously
  @override
  Future<BitmapDescriptor?> getCachedIcon(String eventId) async {
    final icon = MarkerCache.getIcon(eventId);
    print(
      'MarkerRepositoryImpl: getCachedIcon for eventId=$eventId, found=${icon != null}',
    );
    return icon;
  }

  // ClearCache: Remove all cached icons
  @override
  void clearCache() {
    MarkerCache.clearAll();
    print('MarkerRepositoryImpl: Cache cleared');
  }
}