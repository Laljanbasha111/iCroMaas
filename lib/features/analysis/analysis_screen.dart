import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import 'screens/analysis_loading_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final File? imageFile;

  const AnalysisScreen({
    super.key,
    this.imageFile,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.imageFile != null) {
      _selectedImage = widget.imageFile;
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        return;
      }

      final File imageFile = File(pickedFile.path);

      if (!await imageFile.exists()) {
        _showErrorDialog(
          'The selected image could not be found.',
        );
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImage = imageFile;
      });
    } catch (e) {
      debugPrint('❌ Image selection error: $e');

      if (!mounted) {
        return;
      }

      _showErrorDialog(
        'Failed to select image:\n$e',
      );
    }
  }

  // ============================================================
  // START REAL AI ANALYSIS
  // ============================================================

  Future<void> _analyzeImage() async {
    final File? image = _selectedImage;

    if (image == null) {
      _showErrorDialog(
        'Please select or capture a crop image first.',
      );
      return;
    }

    try {
      if (!await image.exists()) {
        _showErrorDialog(
          'The selected image no longer exists.',
        );
        return;
      }

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '🚀 Starting REAL crop analysis',
      );
      debugPrint(
        '📷 Image: ${image.path}',
      );
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      if (!mounted) {
        return;
      }

      // ----------------------------------------------------------
      // IMPORTANT
      //
      // Do NOT use mock prediction data here.
      //
      // AnalysisLoadingScreen is responsible for:
      //
      // 1. Loading the image
      // 2. Loading CropModelService
      // 3. Running TFLite inference
      // 4. Creating PredictionResult
      // 5. Navigating to the result screen
      // ----------------------------------------------------------

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnalysisLoadingScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Failed to start analysis: $e',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      if (!mounted) {
        return;
      }

      _showErrorDialog(
        'Unable to start crop analysis:\n$e',
      );
    }
  }

  // ============================================================
  // IMAGE SOURCE DIALOG
  // ============================================================

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose how you want to provide the crop image',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Camera
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Colors.blue.withValues(
                    alpha: 0.08,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Capture a new crop image',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 10),

                // Gallery
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Colors.green.withValues(
                    alpha: 0.08,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Choose an existing crop image',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR DIALOG
  // ============================================================

  void _showErrorDialog(String message) {
    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'Error',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // IMAGE SECTION
  // ============================================================

  Widget _buildImageSection() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 330,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade100,
              Colors.green.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Unable to display image',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Change image button
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showImageSourceDialog,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.green.withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 50,
                color: Colors.green.shade400,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No crop image selected',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Capture or select a crop image\nto start AI analysis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(
                Icons.add_photo_alternate,
              ),
              label: const Text(
                'Select Image',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI INFORMATION CARD
  // ============================================================

  Widget _buildAIInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Crop Analysis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'The selected image will be processed using the configured crop AI model.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODEL INFORMATION CARD
  // ============================================================

  Widget _buildAnalysisDetails() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What will be analyzed?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildDetailRow(
              Icons.eco,
              'Crop information',
              'Identify and analyze the crop',
            ),

            const SizedBox(height: 10),

            _buildDetailRow(
              Icons.grass,
              'Biomass',
              'Estimate crop biomass',
            ),

            const SizedBox(height: 10),

            _buildDetailRow(
              Icons.science,
              'Nitrogen',
              'Estimate nitrogen level',
            ),

            const SizedBox(height: 10),

            _buildDetailRow(
              Icons.analytics,
              'AI confidence',
              'Show model prediction confidence',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Analysis',
        ),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Analyze Your Crop',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Upload a clear crop image and let the AI analyze it.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Image
              _buildImageSection(),

              const SizedBox(height: 16),

              // AI information
              _buildAIInfoCard(),

              const SizedBox(height: 16),

              // Analysis details
              _buildAnalysisDetails(),

              const SizedBox(height: 20),

              // Analyze button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: hasImage
                      ? _analyzeImage
                      : _showImageSourceDialog,
                  icon: Icon(
                    hasImage
                        ? Icons.analytics_outlined
                        : Icons.add_a_photo_outlined,
                  ),
                  label: Text(
                    hasImage
                        ? 'Analyze Crop with AI'
                        : 'Select Crop Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (hasImage)
                Center(
                  child: TextButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                    ),
                    label: const Text(
                      'Choose another image',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Floating camera button
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add_a_photo,
        ),
      ),
    );
  }
}