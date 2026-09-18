import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  // -----------------------------
  // IMAGE PICKING
  // -----------------------------

  static Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<List<File>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    return pickedFiles.map((xFile) => File(xFile.path)).toList();
  }

  static Future<File?> showImageSourceDialog(BuildContext context) async {
    File? selectedImage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(dialogContext);
                selectedImage = await pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(dialogContext);
                selectedImage = await pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );

    return selectedImage;
  }

  // -----------------------------
  // IMAGE COMPRESSION
  // -----------------------------

  static Future<File?> compressImage(File image, int quality) async {
    try {
      final bytes = await image.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final compressed = img.encodeJpg(decoded, quality: quality);
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/${path.basename(image.path)}');
      await compressedFile.writeAsBytes(compressed);
      return compressedFile;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> compressImageToSize(File image, int maxSizeKB) async {
    int quality = 95;
    File? compressed = image;
    while (compressed != null && compressed.lengthSync() / 1024 > maxSizeKB && quality > 10) {
      compressed = await compressImage(image, quality);
      quality -= 10;
    }
    return compressed;
  }

  static Future<File?> resizeImage(File image, int width, int height) async {
    try {
      final bytes = await image.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(decoded, width: width, height: height);
      final tempDir = await getTemporaryDirectory();
      final resizedFile = File('${tempDir.path}/resized_${path.basename(image.path)}');
      await resizedFile.writeAsBytes(img.encodeJpg(resized));
      return resizedFile;
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  // IMAGE MANIPULATION
  // -----------------------------

  static Future<File?> cropImage(File image, {int? x, int? y, int? width, int? height}) async {
    try {
      final bytes = await image.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final cropped = img.copyCrop(
        decoded,
        x: x ?? 0,
        y: y ?? 0,
        width: width ?? decoded.width,
        height: height ?? decoded.height,
      );
      final tempDir = await getTemporaryDirectory();
      final croppedFile = File('${tempDir.path}/cropped_${path.basename(image.path)}');
      await croppedFile.writeAsBytes(img.encodeJpg(cropped));
      return croppedFile;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> rotateImage(File image, int degrees) async {
    try {
      final bytes = await image.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final rotated = img.copyRotate(decoded, angle: degrees);
      final tempDir = await getTemporaryDirectory();
      final rotatedFile = File('${tempDir.path}/rotated_${path.basename(image.path)}');
      await rotatedFile.writeAsBytes(img.encodeJpg(rotated));
      return rotatedFile;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> flipImage(File image, bool horizontal) async {
    try {
      final bytes = await image.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final flipped = horizontal ? img.flipHorizontal(decoded) : img.flipVertical(decoded);
      final tempDir = await getTemporaryDirectory();
      final flippedFile = File('${tempDir.path}/flipped_${path.basename(image.path)}');
      await flippedFile.writeAsBytes(img.encodeJpg(flipped));
      return flippedFile;
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  // IMAGE VALIDATION
  // -----------------------------

  static bool isValidImageFile(File file) {
    final ext = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext);
  }

  static Future<Size?> getImageSize(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      return Size(decoded.width.toDouble(), decoded.height.toDouble());
    } catch (_) {
      return null;
    }
  }

  static int getImageFileSize(File file) {
    return file.existsSync() ? file.lengthSync() : 0;
  }

  static bool isImageSizeValid(File file, int maxSizeKB) {
    final sizeKB = file.lengthSync() / 1024;
    return sizeKB <= maxSizeKB;
  }

  // -----------------------------
  // IMAGE CONVERSION
  // -----------------------------

  static Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }

  static Future<File> bytesToFile(Uint8List bytes, String filePath) async {
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File?> base64ToImage(String base64Str) async {
    try {
      final bytes = base64Decode(base64Str);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> imageToBase64(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  // IMAGE INFO
  // -----------------------------

  static Future<Map<String, dynamic>?> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      return {'width': decoded.width, 'height': decoded.height};
    } catch (_) {
      return null;
    }
  }

  static String getImageFormat(File file) {
    final ext = path.extension(file.path).replaceAll('.', '').toLowerCase();
    return ext.isEmpty ? 'unknown' : ext;
  }

  static Future<double?> getImageAspectRatio(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      return decoded.width / decoded.height;
    } catch (_) {
      return null;
    }
  }
}