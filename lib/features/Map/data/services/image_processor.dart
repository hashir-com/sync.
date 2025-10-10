import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service for processing marker images
class ImageProcessor {
  /// Process image in isolate for better performance
  static Future<Uint8List> processImageInIsolate(Uint8List imageData) async {
    return compute(_processImage, imageData);
  }

  /// Internal image processing function
  static Uint8List _processImage(Uint8List imageData) {
    final decodedImage = img.decodeImage(imageData);
    if (decodedImage == null) throw Exception('Failed to decode image');

    const pixelRatio = 1.0;
    const baseSize = 120.0;
    final scaledSize = (baseSize * pixelRatio).toInt();

    final resizedImage = img.copyResize(
      decodedImage,
      width: scaledSize,
      height: scaledSize,
      interpolation: img.Interpolation.linear,
    );

    const padding = 8;
    const imageWidth = 120;
    final scaledImageWidth = (imageWidth * pixelRatio).toInt();
    final scaledPadding = (padding * pixelRatio).toInt();
    final finalWidth = scaledImageWidth + 2 * scaledPadding;
    final finalHeight = scaledImageWidth + 2 * scaledPadding;

    final canvas = img.Image(
      width: finalWidth,
      height: finalHeight,
      numChannels: 4,
    );

    // rounded rectangle with proper corner radius (50px)
    const cornerRadius = 50;

    // White background with shadow effect
    img.fillRect(
      canvas,
      x1: 0,
      y1: 0,
      x2: finalWidth - 1,
      y2: finalHeight - 1,
      color: img.ColorRgba8(255, 255, 255, 255),
      radius: cornerRadius.toDouble() * pixelRatio,
    );

    // Create rounded mask for the image
    final mask = img.Image(
      width: scaledImageWidth,
      height: scaledImageWidth,
      numChannels: 4,
    );
    img.fillRect(
      mask,
      x1: 0,
      y1: 0,
      x2: scaledImageWidth - 1,
      y2: scaledImageWidth - 1,
      color: img.ColorRgba8(255, 255, 255, 255),
      radius: (cornerRadius - 2).toDouble() * pixelRatio,
    );

    // Apply rounded corners to the image
    final roundRectImage = img.compositeImage(
      img.Image(
        width: scaledImageWidth,
        height: scaledImageWidth,
        numChannels: 4,
      ),
      resizedImage,
      mask: mask,
    );

    // Composite the rounded image onto the canvas
    img.compositeImage(
      canvas,
      roundRectImage,
      dstX: scaledPadding,
      dstY: scaledPadding,
    );

    final encodedImage = img.encodePng(canvas);
    if (kDebugMode) {
      print(
        'Processed marker: ${finalWidth}x$finalHeight with ${cornerRadius}px corners',
      );
    }
    return Uint8List.fromList(encodedImage);
  }
}
