// File: features/map/data/repositories/marker_repositories_impl.dart
// Purpose: Implement marker icon fetching and caching with larger circular event image markers
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sync_event/features/map/data/cache/marker_cache.dart';
import 'package:sync_event/features/map/data/services/image_processor.dart';
import 'package:sync_event/features/map/domain/repositories/marker_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarkerRepositoryImpl implements MarkerRepository {
  final DefaultCacheManager _cacheManager;

  MarkerRepositoryImpl({DefaultCacheManager? cacheManager})
    : _cacheManager = cacheManager ?? DefaultCacheManager();

  // GetMarkerIcon: Fetch and process event image into a larger circular marker with border
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
        final cacheKey = 'marker_${eventId}_v3';
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
          // Process image into a larger circular marker with border
          final circularImage = await _createCircularMarker(imageData);
          final markerIcon = BitmapDescriptor.fromBytes(circularImage);
          MarkerCache.setIcon(eventId, markerIcon);
          await _cacheManager.putFile(
            cacheKey,
            circularImage,
            fileExtension: 'png',
          );
          print(
            'MarkerRepositoryImpl: Created and cached circular marker for eventId=$eventId',
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

  // CreateCircularMarker: Convert image to a larger circular marker with a white border
  Future<Uint8List> _createCircularMarker(Uint8List imageData) async {
    // Resize image to 96x96 for larger marker
    final resizedImage = await ImageProcessor.processImageInIsolate(
      imageData,
      targetSize: 90.sp.toInt(),
    );

    // Create a PictureRecorder and Canvas for drawing
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = 180.sp; // Larger total marker size (including border)
    final imageSize = 170.sp; // Larger inner image size
// Thicker white border

    // Draw white circular border
    final borderPaint = ui.Paint()
      ..color = ui.Color.fromARGB(255, 255, 255, 255)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(ui.Offset(size / 2, size / 2), size / 2, borderPaint);

    // Decode resized image
    final codec = await ui.instantiateImageCodec(resizedImage);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Draw circular clipped image
    canvas.save();
    canvas.clipRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(
          (size - imageSize) / 2,
          (size - imageSize) / 2,
          imageSize,
          imageSize,
        ),
        ui.Radius.circular(imageSize / 2),
      ),
    );
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(
        (size - imageSize) / 2,
        (size - imageSize) / 2,
        imageSize,
        imageSize,
      ),
      ui.Paint(),
    );
    canvas.restore();

    // Convert canvas to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    print(
      'MarkerRepositoryImpl: Created circular marker with size=${size.toInt()}px',
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
