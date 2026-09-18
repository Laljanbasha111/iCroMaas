import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import '../../../app/theme/app_colors.dart';

/// Upload Image Screen for Crop Analyzer app.
/// Allows users to select an image from the gallery for analysis.
/// Validates file type and size, then navigates to image preview screen.
class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  /// Picks an image from the gallery and validates it.
  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        _showSnackBar('No image selected.', Colors.orangeAccent);
        setState(() => _isLoading = false);
        return;
      }

      final File file = File(pickedFile.path);
      final bool exists = await file.exists();

      if (!exists) {
        _showSnackBar('File not found. Please try again.', Colors.redAccent);
        setState(() => _isLoading = false);
        return;
      }

      // Validate file extension
      final String extension = path.extension(file.path).toLowerCase();
      if (!(extension == '.jpg' ||
          extension == '.jpeg' ||
          extension == '.png')) {
        _showSnackBar('Invalid file format. Use JPG or PNG.', Colors.redAccent);
        setState(() => _isLoading = false);
        return;
      }

      // Validate file size (max 10MB)
      final int fileSize = await file.length();
      const int maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        _showSnackBar('File too large. Max size is 10MB.', Colors.redAccent);
        setState(() => _isLoading = false);
        return;
      }

      // Navigate to image preview screen
      if (mounted) {
        context.go('/image-preview', extra: {'imagePath': file.path});
      }
    } catch (e) {
      _showSnackBar('Error selecting image: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Displays a SnackBar with a message and color.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Upload Image'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.cloud_upload,
              size: 120,
              color: AppColors.primary,
            ),
            const SizedBox(height: 30),
            const Text(
              'Upload Crop Image',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select an image from your gallery to analyze',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isLoading ? null : _pickImage,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Supported formats: JPG, JPEG, PNG\nMax file size: 10MB',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}