import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../../core/constants/api_constants.dart';
import '../../core/error/app_exception.dart';

/// Image processing parameters for isolate
class ImageProcessParams {
  ImageProcessParams({
    required this.imageUrl,
    required this.targetSize,
    required this.quality,
    required this.outputPath,
  });

  final String imageUrl;
  final int targetSize;
  final int quality;
  final String outputPath;
}

class ImageProcessor {
  Future<String> processAndCacheImage({
    required String imageUrl,
    required int targetSize,
    int quality = ApiConstants.imageQuality,
  }) async {
    try {
      // Get cache directory
      final cacheDir = await getApplicationCacheDirectory();
      final imageDir = Directory(path.join(cacheDir.path, 'pokemon_images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate filename from URL
      final filename = _generateFilename(imageUrl, targetSize);
      final outputPath = path.join(imageDir.path, filename);

      // Check if already cached
      final file = File(outputPath);
      if (await file.exists()) {
        return outputPath;
      }

      // Process in isolate
      final params = ImageProcessParams(
        imageUrl: imageUrl,
        targetSize: targetSize,
        quality: quality,
        outputPath: outputPath,
      );

      final result = await compute(_processImageInIsolate, params);
      return result;
    } catch (e) {
      throw ImageProcessingException('Failed to process image: ${e.toString()}');
    }
  }

  String _generateFilename(String imageUrl, int size) {
    final uri = Uri.parse(imageUrl);
    final segments = uri.pathSegments;
    final baseName = segments.isNotEmpty ? segments.last : 'image';
    final nameWithoutExt = baseName.split('.').first;
    return '${nameWithoutExt}_${size}x$size.jpg';
  }

  /// Downloads image bytes from URL
  static Future<Uint8List> _downloadImageBytes(String imageUrl) async {
    final dio = Dio();
    final response = await dio.get<Uint8List>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download image: ${response.statusCode}');
    }

    final imageBytes = response.data;
    if (imageBytes == null) {
      throw Exception('Failed to download image: no data received');
    }

    return imageBytes;
  }

  /// Decodes image bytes into image object
  static img.Image _decodeImageBytes(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return image;
  }

  /// Resizes image to target size
  static img.Image _resizeImage(img.Image image, int targetSize) {
    return img.copyResize(
      image,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Encodes image as JPEG with specified quality
  static Uint8List _encodeImageAsJpeg(img.Image image, int quality) {
    return img.encodeJpg(image, quality: quality);
  }

  /// Saves image bytes to file
  static Future<void> _saveImageToFile(String outputPath, Uint8List imageBytes) async {
    final file = File(outputPath);
    await file.writeAsBytes(imageBytes);
  }

  // Process image in background isolate
  static Future<String> _processImageInIsolate(ImageProcessParams params) async {
    try {
      final imageBytes = await _downloadImageBytes(params.imageUrl);
      final image = _decodeImageBytes(imageBytes);
      final resized = _resizeImage(image, params.targetSize);
      final jpegBytes = _encodeImageAsJpeg(resized, params.quality);
      await _saveImageToFile(params.outputPath, jpegBytes);
      return params.outputPath;
    } catch (e) {
      throw Exception('Image processing failed: ${e.toString()}');
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final imageDir = Directory(path.join(cacheDir.path, 'pokemon_images'));
      if (await imageDir.exists()) {
        await imageDir.delete(recursive: true);
      }
    } catch (e) {
      throw ImageProcessingException('Failed to clear image cache: ${e.toString()}');
    }
  }
}

