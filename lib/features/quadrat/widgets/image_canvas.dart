import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// ImageCanvas widget for displaying, zooming, panning, and optionally cropping images.
/// Used in the Crop Analyzer app for image analysis and visualization.
class ImageCanvas extends StatefulWidget {
  final File image;
  final Function(File)? onImageCropped;
  final bool enableCrop;
  final bool enableZoom;
  final bool enablePan;
  final double initialScale;
  final double minScale;
  final double maxScale;
  final Color backgroundColor;

  const ImageCanvas({
    Key? key,
    required this.image,
    this.onImageCropped,
    this.enableCrop = false,
    this.enableZoom = true,
    this.enablePan = true,
    this.initialScale = 1.0,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.backgroundColor = Colors.black,
  }) : super(key: key);

  @override
  State<ImageCanvas> createState() => _ImageCanvasState();
}

class _ImageCanvasState extends State<ImageCanvas> with TickerProviderStateMixin {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  Size? _imageSize;
  late TransformationController _transformationController;
  Animation<Matrix4>? _animationReset;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale;
    _transformationController = TransformationController();
    _loadImageSize();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  /// Loads the image dimensions asynchronously.
  Future<void> _loadImageSize() async {
    final data = await widget.image.readAsBytes();
    final decoded = await decodeImageFromList(data);
    setState(() {
      _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
    });
  }

  /// Resets zoom and pan transformations smoothly.
  void _resetTransform() {
    final resetMatrix = Matrix4.identity();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: resetMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController!));

    _animationController!.addListener(() {
      _transformationController.value = _animationReset!.value;
    });

    _animationController!.forward(from: 0);
    setState(() {
      _scale = widget.initialScale;
      _offset = Offset.zero;
    });
  }

  /// Handles scale gesture start.
  void _handleScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
  }

  /// Handles scale gesture update.
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.enableZoom && !widget.enablePan) return;

    setState(() {
      if (widget.enableZoom) {
        _scale = (_previousScale * details.scale)
            .clamp(widget.minScale, widget.maxScale);
      }
      if (widget.enablePan) {
        _offset = _previousOffset + details.focalPointDelta / _scale;
      }
    });
  }

  /// Handles scale gesture end.
  void _handleScaleEnd(ScaleEndDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
  }

  /// Builds the crop overlay if cropping is enabled.
  Widget _buildCropOverlay() {
    if (!widget.enableCrop) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CropOverlayPainter(),
      ),
    );
  }

  /// Builds zoom controls overlay.
  Widget _buildZoomControls() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: Colors.white.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(widget.minScale, widget.maxScale);
                _transformationController.value = Matrix4.identity()
                  ..scale(_scale);
              });
            },
            child: const Icon(Icons.zoom_in, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: Colors.white.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(widget.minScale, widget.maxScale);
                _transformationController.value = Matrix4.identity()
                  ..scale(_scale);
              });
            },
            child: const Icon(Icons.zoom_out, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'reset',
            mini: true,
            backgroundColor: Colors.white.withOpacity(0.8),
            onPressed: _resetTransform,
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// Builds the main image display with gestures and overlays.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: GestureDetector(
        onDoubleTap: _resetTransform,
        onScaleStart: widget.enableZoom || widget.enablePan ? _handleScaleStart : null,
        onScaleUpdate: widget.enableZoom || widget.enablePan ? _handleScaleUpdate : null,
        onScaleEnd: widget.enableZoom || widget.enablePan ? _handleScaleEnd : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: widget.enablePan,
              scaleEnabled: widget.enableZoom,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              child: Center(
                child: Image.file(
                  widget.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            _buildCropOverlay(),
            _buildZoomControls(),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing a crop overlay with transparent center.
class _CropOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final cropRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRect(cropRect),
    );

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(cropRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}