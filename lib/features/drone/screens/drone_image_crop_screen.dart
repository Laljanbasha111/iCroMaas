import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

class DroneImageCropScreen extends StatefulWidget {
  final String imagePath;

  const DroneImageCropScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<DroneImageCropScreen> createState() => _DroneImageCropScreenState();
}

class _DroneImageCropScreenState extends State<DroneImageCropScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Crop Field Area',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            child: Center(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Instructions & Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha(76),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1976D2).withAlpha(128),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF42A5F5),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap "Crop Image" to select the specific field area you want to analyze',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Skip Cropping Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () {
                          // Skip cropping, analyze full image
                          context.push('/loading', extra: widget.imagePath);
                        },
                        icon: const Icon(Icons.skip_next, color: Colors.white70),
                        label: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white30, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Crop Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _cropImage,
                        icon: _isProcessing
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.crop, color: Colors.white, size: 24),
                        label: Text(
                          _isProcessing ? 'Processing...' : 'Crop Image',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cropImage() async {
    setState(() => _isProcessing = true);

    try {
      debugPrint('🔵 Starting crop for: ${widget.imagePath}');
      debugPrint('🔵 File exists: ${File(widget.imagePath).existsSync()}');

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Field Area',
            toolbarColor: const Color(0xFF1976D2),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Field Area',
          ),
        ],
      );

      debugPrint('🔵 Crop result: ${croppedFile?.path ?? "null"}');

      if (!mounted) return;

      if (croppedFile != null) {
        debugPrint('✅ Cropped successfully: ${croppedFile.path}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Image cropped successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to analysis with cropped image
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        context.push('/loading', extra: croppedFile.path);
      } else {
        // ⚠️ IMPORTANT: Don't navigate if user cancelled
        debugPrint('⚠️ Cropping cancelled by user');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Text('Cropping cancelled. Tap "Skip" to analyze full image.'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );

        // DON'T navigate - stay on crop screen
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Crop error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Cropper failed. Use "Skip" to continue.\nError: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}