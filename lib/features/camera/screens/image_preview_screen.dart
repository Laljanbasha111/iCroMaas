import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

/// Image Preview Screen for Crop Analyzer app.
/// Displays the captured image with zoom/pinch functionality.
/// Provides options to retake or proceed with the selected image.
class ImagePreviewScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ImagePreviewScreen({super.key, this.extra});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late String? _imagePath;
  bool _isLoading = true;
  bool _fileExists = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.extra?['imagePath'] as String?;
    _checkFile();
  }

  /// Checks if the image file exists before displaying.
  Future<void> _checkFile() async {
    if (_imagePath == null) {
      setState(() {
        _isLoading = false;
        _fileExists = false;
      });
      return;
    }

    final file = File(_imagePath!);
    final exists = await file.exists();
    if (mounted) {
      setState(() {
        _fileExists = exists;
        _isLoading = false;
      });
    }
  }

  /// Navigates back to camera screen for retaking image.
  void _retakeImage() {
    context.go('/camera');
  }

  /// Navigates to quadrat screen with selected image path.
  void _useImage() {
    if (_imagePath != null && _fileExists) {
      context.go('/quadrat', extra: {'imagePath': _imagePath});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image not available. Please retake.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Image Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      )
          : !_fileExists
          ? const Center(
        child: Text(
          'Image file not found.\nPlease retake the photo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Failed to load image.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.refresh,
                        color: AppColors.primary),
                    label: const Text(
                      'Retake',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _retakeImage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle,
                        color: Colors.white),
                    label: const Text(
                      'Analyze',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: _useImage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}