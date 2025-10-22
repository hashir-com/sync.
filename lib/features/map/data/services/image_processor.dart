// File: features/map/data/services/image_processor.dart
// Purpose: Process images for marker icons in an isolate to avoid UI blocking

import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class ImageProcessor {
  static Future<Uint8List> processImageInIsolate(Uint8List input, {int targetSize = 64}) async {
    print('ImageProcessor: Processing image, targetSize=$targetSize');
    try {
      final image = img.decodeImage(input);
      if (image == null) {
        print('ImageProcessor: Failed to decode image');
        throw Exception('Failed to decode image');
      }

      // Resize to target size while maintaining aspect ratio
      final resized = img.copyResize(image, width: targetSize, height: targetSize);
      final bytes = img.encodePng(resized);
      print('ImageProcessor: Image resized to ${resized.width}x${resized.height}');
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('ImageProcessor: Error processing image: $e');
      rethrow;
    }
  }
}