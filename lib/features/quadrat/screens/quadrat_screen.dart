import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/router/app_router.dart'; // ✅ ADDED

/// Quadrat Screen for Crop Analyzer app.
class QuadratScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const QuadratScreen({super.key, this.extra});

  @override
  State<QuadratScreen> createState() => _QuadratScreenState();
}

class _QuadratScreenState extends State<QuadratScreen> {
  String? _imagePath;
  Rect? _quadratRect;
  bool _isDragging = false;
  Offset? _dragStart;
  Rect? _initialRect;
  final double _handleRadius = 12.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.extra?['imagePath'] as String?;

    if (_imagePath == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureImage();
      });
    }
  }

  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
        });
        debugPrint('✅ Image captured: ${photo.path}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image capture cancelled'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
        });
        debugPrint('✅ Image selected from gallery: ${photo.path}');
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetQuadrat(Size size) {
    setState(() {
      final double marginX = size.width * 0.2;
      final double marginY = size.height * 0.2;
      _quadratRect = Rect.fromLTWH(
        marginX,
        marginY,
        size.width - 2 * marginX,
        size.height - 2 * marginY,
      );
    });
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (_quadratRect == null) return;
    final Offset pos = details.localPosition;
    _dragStart = pos;
    _initialRect = _quadratRect;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!_isDragging || _quadratRect == null || _initialRect == null) return;
    final Offset delta = details.localPosition - _dragStart!;
    setState(() {
      _quadratRect = _initialRect!.shift(delta);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
  }

  void _onHandleDrag(Offset localPosition, Size size, String corner) {
    if (_quadratRect == null) return;
    Rect rect = _quadratRect!;
    switch (corner) {
      case 'tl':
        rect = Rect.fromPoints(localPosition, rect.bottomRight);
        break;
      case 'tr':
        rect = Rect.fromPoints(
            Offset(rect.left, localPosition.dy), Offset(localPosition.dx, rect.bottom));
        break;
      case 'bl':
        rect = Rect.fromPoints(
            Offset(localPosition.dx, rect.top), Offset(rect.right, localPosition.dy));
        break;
      case 'br':
        rect = Rect.fromPoints(rect.topLeft, localPosition);
        break;
    }
    setState(() {
      _quadratRect = rect;
    });
  }

  /// ✅ FIXED: Navigates to analysis loading screen with ONNX
  void _analyzeImage() {
    // Validate image path
    if (_imagePath == null || _imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected. Please capture or select an image.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate quadrat
    if (_quadratRect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid area before analyzing.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ✅ FIXED: Navigate to analysis-loading (triggers ONNX)
    debugPrint('🚀 Starting ONNX analysis for: $_imagePath');

    setState(() {
      _isLoading = true;
    });

    // Navigate to analysis loading screen (runs ONNX models)
    AppRouter.navigateToAnalysisLoading(context, _imagePath!);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_imagePath == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Select Analysis Area'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Opening camera...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.photo),
                label: const Text('Choose Image Source'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Select Analysis Area'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _showImageSourceDialog,
            tooltip: 'Change Image',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          final Size size = Size(constraints.maxWidth, constraints.maxHeight);
          _quadratRect ??= Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.2,
            size.width * 0.6,
            size.height * 0.6,
          );

          return Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) => _onPanStart(details, size),
                  onPanUpdate: (details) => _onPanUpdate(details, size),
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: QuadratPainter(
                      rect: _quadratRect!,
                      handleRadius: _handleRadius,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Drag corners to adjust the analysis area',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              ..._buildHandles(size),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                        ),
                        onPressed: () => _resetQuadrat(size),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _analyzeImage,
                        child: const Text(
                          'Analyze',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildHandles(Size size) {
    if (_quadratRect == null) return [];
    final rect = _quadratRect!;
    return [
      _buildHandle(rect.topLeft, 'tl', size),
      _buildHandle(rect.topRight, 'tr', size),
      _buildHandle(rect.bottomLeft, 'bl', size),
      _buildHandle(rect.bottomRight, 'br', size),
    ];
  }

  Widget _buildHandle(Offset position, String corner, Size size) {
    return Positioned(
      left: position.dx - _handleRadius,
      top: position.dy - _handleRadius,
      child: GestureDetector(
        onPanUpdate: (details) {
          _onHandleDrag(details.localPosition + position, size, corner);
        },
        child: Container(
          width: _handleRadius * 2,
          height: _handleRadius * 2,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuadratPainter extends CustomPainter {
  final Rect rect;
  final double handleRadius;

  QuadratPainter({required this.rect, required this.handleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final Path overlayPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path rectPath = Path()..addRect(rect);
    final Path finalPath = Path.combine(PathOperation.difference, overlayPath, rectPath);
    canvas.drawPath(finalPath, overlayPaint);

    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, borderPaint);

    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(rect.left + rect.width / 3, rect.top),
      Offset(rect.left + rect.width / 3, rect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(rect.left + 2 * rect.width / 3, rect.top),
      Offset(rect.left + 2 * rect.width / 3, rect.bottom),
      gridPaint,
    );

    canvas.drawLine(
      Offset(rect.left, rect.top + rect.height / 3),
      Offset(rect.right, rect.top + rect.height / 3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + 2 * rect.height / 3),
      Offset(rect.right, rect.top + 2 * rect.height / 3),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(covariant QuadratPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}