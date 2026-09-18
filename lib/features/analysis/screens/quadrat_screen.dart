import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class QuadratScreen extends StatefulWidget {
  const QuadratScreen({super.key});

  @override
  State<QuadratScreen> createState() => _QuadratScreenState();
}

class _QuadratScreenState extends State<QuadratScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'No cameras found on this device';
            _isLoading = false;
          });
        }
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize camera: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError('Camera not ready');
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Capturing image...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final XFile image = await _cameraController!.takePicture();
      debugPrint('✅ Image captured: ${image.path}');

      if (mounted) {
        context.push('/loading', extra: {'imagePath': image.path});
      }
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('✅ Image selected from gallery: ${image.path}');

        if (mounted) {
          context.push('/loading', extra: {'imagePath': image.path});
        }
      }
    } catch (e) {
      debugPrint('❌ Gallery error: $e');
      _showError('Failed to pick image: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Crop Image'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : _error != null
          ? _buildErrorView()
          : _buildCameraView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick from Gallery Instead'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null || !_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '📸 Position your crop within the grid\nTap capture when ready',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: _pickFromGallery,
              ),
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.green,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
              ),
              _buildControlButton(
                icon: Icons.flip_camera_android,
                label: 'Flip',
                onPressed: _switchCamera,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      _showError('No other camera available');
      return;
    }

    try {
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final newIndex = (currentIndex + 1) % _cameras!.length;

      await _cameraController?.dispose();

      _cameraController = CameraController(
        _cameras![newIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Switch camera error: $e');
      _showError('Failed to switch camera');
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cellWidth * i, 0),
        Offset(cellWidth * i, size.height),
        paint,
      );
    }

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, cellHeight * i),
        Offset(size.width, cellHeight * i),
        paint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}