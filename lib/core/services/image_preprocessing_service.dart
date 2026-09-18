import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// General-purpose image processing service.
///
/// This service only performs image and camera-frame operations.
///
/// It does not:
/// - Load machine-learning models
/// - Run TFLite inference
/// - Use CropModelService
/// - Use Interpreter
/// - Make API or network requests
class ImagePreprocessingService {
  static const int defaultSize = 224;
  static const int defaultQuality = 85;

  // ============================================================
  // LOAD IMAGE FROM FILE PATH
  // ============================================================

  /// Loads and decodes an image from a local file path.
  static Future<img.Image?> loadImageFromPath(
      String path,
      ) async {
    try {
      debugPrint(
        '📂 Loading image from path: $path',
      );

      final File file = File(path);

      if (!await file.exists()) {
        debugPrint(
          '❌ File does not exist: $path',
        );

        return null;
      }

      final Uint8List bytes =
      await file.readAsBytes();

      if (bytes.isEmpty) {
        debugPrint(
          '❌ Image file is empty.',
        );

        return null;
      }

      final img.Image? image =
      img.decodeImage(bytes);

      if (image == null) {
        debugPrint(
          '❌ Failed to decode image.',
        );

        return null;
      }

      debugPrint(
        '✅ Image loaded: '
            '${image.width} x ${image.height}',
      );

      return image;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading image from path: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return null;
    }
  }

  // ============================================================
  // LOAD IMAGE FROM ASSETS
  // ============================================================

  /// Loads and decodes an image from Flutter assets.
  static Future<img.Image?> loadImageFromAssets(
      String assetPath,
      ) async {
    try {
      debugPrint(
        '📦 Loading image from assets: $assetPath',
      );

      final ByteData data =
      await rootBundle.load(assetPath);

      final Uint8List bytes =
      data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      if (bytes.isEmpty) {
        debugPrint(
          '❌ Asset image is empty.',
        );

        return null;
      }

      final img.Image? image =
      img.decodeImage(bytes);

      if (image == null) {
        debugPrint(
          '❌ Failed to decode asset image.',
        );

        return null;
      }

      debugPrint(
        '✅ Asset image loaded: '
            '${image.width} x ${image.height}',
      );

      return image;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading image from assets: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return null;
    }
  }

  // ============================================================
  // LOAD IMAGE FROM BYTES
  // ============================================================

  /// Loads and decodes an image from raw bytes.
  static img.Image? loadImageFromBytes(
      Uint8List bytes,
      ) {
    try {
      if (bytes.isEmpty) {
        debugPrint(
          '❌ Cannot decode empty image bytes.',
        );

        return null;
      }

      debugPrint(
        '📦 Loading image from bytes '
            '(${bytes.length} bytes)',
      );

      final img.Image? image =
      img.decodeImage(bytes);

      if (image == null) {
        debugPrint(
          '❌ Failed to decode image from bytes.',
        );

        return null;
      }

      debugPrint(
        '✅ Image loaded from bytes: '
            '${image.width} x ${image.height}',
      );

      return image;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading image from bytes: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return null;
    }
  }

  // ============================================================
  // CAMERA IMAGE CONVERSION
  // ============================================================

  /// Converts a platform camera frame into an [img.Image].
  static img.Image? convertCameraImage(
      CameraImage cameraImage,
      ) {
    try {
      debugPrint(
        '📷 Converting camera image: '
            '${cameraImage.width} x ${cameraImage.height}',
      );

      final ImageFormatGroup format =
          cameraImage.format.group;

      switch (format) {
        case ImageFormatGroup.yuv420:
          return _convertYuv420ToImage(
            cameraImage,
          );

        case ImageFormatGroup.bgra8888:
          return _convertBgra8888ToImage(
            cameraImage,
          );

        case ImageFormatGroup.jpeg:
          return _convertJpegToImage(
            cameraImage,
          );

        default:
          debugPrint(
            '⚠️ Unsupported camera image format: $format',
          );

          return null;
      }
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error converting camera image: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return null;
    }
  }

  // ============================================================
  // YUV420 TO IMAGE
  // ============================================================

  static img.Image _convertYuv420ToImage(
      CameraImage cameraImage,
      ) {
    if (cameraImage.planes.length < 3) {
      throw Exception(
        'YUV420 image must contain three planes.',
      );
    }

    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final Plane yPlane =
    cameraImage.planes[0];

    final Plane uPlane =
    cameraImage.planes[1];

    final Plane vPlane =
    cameraImage.planes[2];

    final img.Image image = img.Image(
      width: width,
      height: height,
    );

    final int uvPixelStride =
        uPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex =
            y * yPlane.bytesPerRow + x;

        final int uvRow =
            y ~/ 2;

        final int uvColumn =
            x ~/ 2;

        final int uvIndex =
            uvRow * uPlane.bytesPerRow +
                uvColumn * uvPixelStride;

        if (yIndex < 0 ||
            yIndex >= yPlane.bytes.length ||
            uvIndex < 0 ||
            uvIndex >= uPlane.bytes.length ||
            uvIndex >= vPlane.bytes.length) {
          continue;
        }

        final int yValue =
        yPlane.bytes[yIndex];

        final int uValue =
        uPlane.bytes[uvIndex];

        final int vValue =
        vPlane.bytes[uvIndex];

        final int red =
        (yValue +
            1.370705 *
                (vValue - 128))
            .clamp(0, 255)
            .toInt();

        final int green =
        (yValue -
            0.337633 *
                (uValue - 128) -
            0.698001 *
                (vValue - 128))
            .clamp(0, 255)
            .toInt();

        final int blue =
        (yValue +
            1.732446 *
                (uValue - 128))
            .clamp(0, 255)
            .toInt();

        image.setPixelRgba(
          x,
          y,
          red,
          green,
          blue,
          255,
        );
      }
    }

    debugPrint(
      '✅ YUV420 conversion complete.',
    );

    return image;
  }

  // ============================================================
  // BGRA8888 TO IMAGE
  // ============================================================

  static img.Image _convertBgra8888ToImage(
      CameraImage cameraImage,
      ) {
    if (cameraImage.planes.isEmpty) {
      throw Exception(
        'BGRA8888 image does not contain a plane.',
      );
    }

    final Uint8List bytes =
        cameraImage.planes[0].bytes;

    final img.Image image =
    img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: bytes.buffer,
      order: img.ChannelOrder.bgra,
    );

    debugPrint(
      '✅ BGRA8888 conversion complete.',
    );

    return image;
  }

  // ============================================================
  // JPEG TO IMAGE
  // ============================================================

  static img.Image? _convertJpegToImage(
      CameraImage cameraImage,
      ) {
    if (cameraImage.planes.isEmpty) {
      throw Exception(
        'JPEG image does not contain a plane.',
      );
    }

    final Uint8List bytes =
        cameraImage.planes[0].bytes;

    final img.Image? image =
    img.decodeJpg(bytes);

    if (image == null) {
      debugPrint(
        '❌ Failed to decode JPEG camera image.',
      );

      return null;
    }

    debugPrint(
      '✅ JPEG conversion complete.',
    );

    return image;
  }

  // ============================================================
  // RESIZE IMAGE
  // ============================================================

  /// Resizes an image to the requested dimensions.
  static img.Image resizeImage(
      img.Image image, {
        int width = defaultSize,
        int height = defaultSize,
        img.Interpolation interpolation =
            img.Interpolation.linear,
      }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError(
        'Image width and height must be greater than zero.',
      );
    }

    debugPrint(
      '🔄 Resizing image: '
          '${image.width} x ${image.height} '
          '→ $width x $height',
    );

    final img.Image resized =
    img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: interpolation,
    );

    debugPrint(
      '✅ Resize complete.',
    );

    return resized;
  }

  // ============================================================
  // CROP TO SQUARE
  // ============================================================

  /// Crops the center of an image into a square.
  static img.Image cropToSquare(
      img.Image image,
      ) {
    if (image.width <= 0 ||
        image.height <= 0) {
      throw ArgumentError(
        'Image dimensions must be greater than zero.',
      );
    }

    final int size =
    image.width < image.height
        ? image.width
        : image.height;

    final int x =
        (image.width - size) ~/ 2;

    final int y =
        (image.height - size) ~/ 2;

    debugPrint(
      '✂️ Cropping to square: '
          '$size x $size from ($x, $y)',
    );

    final img.Image cropped =
    img.copyCrop(
      image,
      x: x,
      y: y,
      width: size,
      height: size,
    );

    debugPrint(
      '✅ Crop complete.',
    );

    return cropped;
  }

  // ============================================================
  // NORMALIZE IMAGE
  // ============================================================

  /// Converts RGB pixel values into the range 0.0–1.0.
  static List<List<List<double>>> normalizeImage(
      img.Image image,
      ) {
    debugPrint(
      '🔢 Normalizing image values.',
    );

    return List<List<List<double>>>.generate(
      image.height,
          (int y) {
        return List<List<double>>.generate(
          image.width,
              (int x) {
            final pixel =
            image.getPixel(x, y);

            return <double>[
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        );
      },
    );
  }

  // ============================================================
  // COLOR ADJUSTMENTS
  // ============================================================

  /// Adjusts image brightness.
  static img.Image adjustBrightness(
      img.Image image,
      double factor,
      ) {
    debugPrint(
      '☀️ Adjusting brightness: factor=$factor',
    );

    return img.adjustColor(
      image,
      brightness: factor,
    );
  }

  /// Adjusts image contrast.
  static img.Image adjustContrast(
      img.Image image,
      double factor,
      ) {
    debugPrint(
      '🎨 Adjusting contrast: factor=$factor',
    );

    return img.adjustColor(
      image,
      contrast: factor,
    );
  }

  /// Adjusts image saturation.
  static img.Image adjustSaturation(
      img.Image image,
      double factor,
      ) {
    debugPrint(
      '🌈 Adjusting saturation: factor=$factor',
    );

    return img.adjustColor(
      image,
      saturation: factor,
    );
  }

  // ============================================================
  // ROTATE IMAGE
  // ============================================================

  /// Rotates an image by 90, 180, or 270 degrees.
  static img.Image rotateImage(
      img.Image image,
      int degrees,
      ) {
    debugPrint(
      '🔄 Rotating image: $degrees degrees',
    );

    if (degrees == 90 ||
        degrees == 180 ||
        degrees == 270) {
      return img.copyRotate(
        image,
        angle: degrees,
      );
    }

    debugPrint(
      '⚠️ Invalid rotation angle. '
          'Returning the original image.',
    );

    return image;
  }

  // ============================================================
  // FLIP IMAGE
  // ============================================================

  /// Flips an image horizontally.
  static img.Image flipHorizontal(
      img.Image image,
      ) {
    debugPrint(
      '↔️ Flipping image horizontally.',
    );

    return img.flipHorizontal(image);
  }

  /// Flips an image vertically.
  static img.Image flipVertical(
      img.Image image,
      ) {
    debugPrint(
      '↕️ Flipping image vertically.',
    );

    return img.flipVertical(image);
  }

  // ============================================================
  // GRAYSCALE
  // ============================================================

  /// Converts an image to grayscale.
  static img.Image toGrayscale(
      img.Image image,
      ) {
    debugPrint(
      '⚫ Converting image to grayscale.',
    );

    return img.grayscale(image);
  }

  // ============================================================
  // BLUR
  // ============================================================

  /// Applies Gaussian blur to an image.
  static img.Image applyBlur(
      img.Image image, {
        int radius = 3,
      }) {
    if (radius < 0) {
      throw ArgumentError(
        'Blur radius cannot be negative.',
      );
    }

    debugPrint(
      '🌫️ Applying Gaussian blur: '
          'radius=$radius',
    );

    return img.gaussianBlur(
      image,
      radius: radius,
    );
  }

  // ============================================================
  // IMAGE PROCESSING PIPELINE
  // ============================================================

  /// Applies common image transformations.
  ///
  /// This pipeline is independent of any machine-learning
  /// framework. It can be used for displaying, saving, or
  /// preparing images for any future processing.
  static img.Image preprocessImage(
      img.Image image, {
        int targetSize = defaultSize,
        bool cropSquare = true,
        double brightness = 1.0,
        double contrast = 1.0,
        double saturation = 1.0,
        int? rotation,
        bool flipH = false,
        bool flipV = false,
      }) {
    if (targetSize <= 0) {
      throw ArgumentError(
        'Target size must be greater than zero.',
      );
    }

    debugPrint(
      '🔧 Starting image-processing pipeline.',
    );

    img.Image processed = image;

    if (cropSquare &&
        processed.width != processed.height) {
      processed = cropToSquare(processed);
    }

    if (processed.width != targetSize ||
        processed.height != targetSize) {
      processed = resizeImage(
        processed,
        width: targetSize,
        height: targetSize,
      );
    }

    if (rotation != null &&
        rotation != 0) {
      processed = rotateImage(
        processed,
        rotation,
      );
    }

    if (flipH) {
      processed = flipHorizontal(
        processed,
      );
    }

    if (flipV) {
      processed = flipVertical(
        processed,
      );
    }

    if (brightness != 1.0 ||
        contrast != 1.0 ||
        saturation != 1.0) {
      processed = img.adjustColor(
        processed,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
      );
    }

    debugPrint(
      '✅ Image-processing pipeline complete.',
    );

    return processed;
  }

  // ============================================================
  // BACKWARD-COMPATIBLE METHOD
  // ============================================================

  /// Backward-compatible alias for existing code.
  ///
  /// Existing screens may still call this method. It now uses
  /// the general image-processing pipeline and does not perform
  /// model inference.
  static img.Image preprocessForModel(
      img.Image image, {
        int targetSize = defaultSize,
        bool cropSquare = true,
        double brightness = 1.0,
        double contrast = 1.0,
        double saturation = 1.0,
        int? rotation,
        bool flipH = false,
        bool flipV = false,
      }) {
    return preprocessImage(
      image,
      targetSize: targetSize,
      cropSquare: cropSquare,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
      rotation: rotation,
      flipH: flipH,
      flipV: flipV,
    );
  }

  // ============================================================
  // SAVE IMAGE
  // ============================================================

  /// Encodes an image as JPEG and saves it to a file.
  static Future<File> saveImage(
      img.Image image,
      String path, {
        int quality = defaultQuality,
      }) async {
    final int safeQuality =
    quality.clamp(0, 100);

    debugPrint(
      '💾 Saving image to: $path',
    );

    final List<int> bytes =
    img.encodeJpg(
      image,
      quality: safeQuality,
    );

    final File file = File(path);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    debugPrint(
      '✅ Image saved successfully.',
    );

    return file;
  }

  // ============================================================
  // IMAGE TO JPEG BYTES
  // ============================================================

  /// Converts an image into JPEG bytes.
  static Uint8List imageToBytes(
      img.Image image, {
        int quality = defaultQuality,
      }) {
    final int safeQuality =
    quality.clamp(0, 100);

    debugPrint(
      '📦 Converting image to JPEG bytes '
          '(quality=$safeQuality)',
    );

    return Uint8List.fromList(
      img.encodeJpg(
        image,
        quality: safeQuality,
      ),
    );
  }

  // ============================================================
  // IMAGE TO PNG BYTES
  // ============================================================

  /// Converts an image into PNG bytes.
  static Uint8List imageToPngBytes(
      img.Image image,
      ) {
    debugPrint(
      '📦 Converting image to PNG bytes.',
    );

    return Uint8List.fromList(
      img.encodePng(image),
    );
  }

  // ============================================================
  // IMAGE DIMENSIONS
  // ============================================================

  static Map<String, int> getImageDimensions(
      img.Image image,
      ) {
    return <String, int>{
      'width': image.width,
      'height': image.height,
    };
  }

  // ============================================================
  // PROCESSING CHECK
  // ============================================================

  static bool needsPreprocessing(
      img.Image image,
      int targetSize,
      ) {
    return image.width != targetSize ||
        image.height != targetSize;
  }

  // ============================================================
  // ASPECT RATIO
  // ============================================================

  static double getAspectRatio(
      img.Image image,
      ) {
    if (image.height == 0) {
      return 0.0;
    }

    return image.width / image.height;
  }

  // ============================================================
  // SQUARE CHECK
  // ============================================================

  static bool isSquare(
      img.Image image,
      ) {
    return image.width == image.height;
  }

  // ============================================================
  // IMAGE INFORMATION
  // ============================================================

  static Map<String, dynamic> getImageInfo(
      img.Image image,
      ) {
    return <String, dynamic>{
      'width': image.width,
      'height': image.height,
      'aspect_ratio': getAspectRatio(image),
      'is_square': isSquare(image),
      'num_channels': image.numChannels,
    };
  }

  // ============================================================
  // PRINT IMAGE INFORMATION
  // ============================================================

  static void printImageInfo(
      img.Image image, {
        String? label,
      }) {
    final Map<String, dynamic> info =
    getImageInfo(image);

    final String labelText =
    label == null ? '' : ' ($label)';

    debugPrint(
      '📊 Image info$labelText:',
    );

    info.forEach(
          (
          String key,
          dynamic value,
          ) {
        debugPrint(
          '   $key: $value',
        );
      },
    );
  }
}