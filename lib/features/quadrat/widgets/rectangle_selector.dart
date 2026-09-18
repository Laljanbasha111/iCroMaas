import 'package:flutter/material.dart';

/// RectangleSelector widget for selecting a rectangular region on an image.
/// Supports dragging, resizing, aspect ratio locking, and visual overlays.
class RectangleSelector extends StatefulWidget {
  final Size imageSize;
  final Function(Rect)? onSelectionChanged;
  final Rect? initialSelection;
  final Size minSize;
  final Size? maxSize;
  final Color selectionColor;
  final Color handleColor;
  final Color overlayColor;
  final double handleSize;
  final double borderWidth;
  final bool showGrid;
  final double? aspectRatio;

  const RectangleSelector({
    Key? key,
    required this.imageSize,
    this.onSelectionChanged,
    this.initialSelection,
    this.minSize = const Size(50, 50),
    this.maxSize,
    this.selectionColor = Colors.green,
    this.handleColor = Colors.white,
    this.overlayColor = Colors.black54,
    this.handleSize = 20.0,
    this.borderWidth = 2.0,
    this.showGrid = true,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<RectangleSelector> createState() => _RectangleSelectorState();
}

/// Enum representing which handle is being dragged.
enum DragHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  center,
}

class _RectangleSelectorState extends State<RectangleSelector> {
  late Rect _selection;
  bool _isDragging = false;
  DragHandle? _dragHandle;
  Offset? _dragStartPosition;
  Rect? _initialSelection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection ??
        Rect.fromLTWH(
          widget.imageSize.width * 0.25,
          widget.imageSize.height * 0.25,
          widget.imageSize.width * 0.5,
          widget.imageSize.height * 0.5,
        );
  }

  /// Handles drag start for a specific handle.
  void _handleDragStart(DragHandle handle, Offset position) {
    setState(() {
      _isDragging = true;
      _dragHandle = handle;
      _dragStartPosition = position;
      _initialSelection = _selection;
    });
  }

  /// Handles drag update and updates selection rectangle.
  void _handleDragUpdate(Offset position) {
    if (!_isDragging || _dragHandle == null || _dragStartPosition == null) return;

    final dx = position.dx - _dragStartPosition!.dx;
    final dy = position.dy - _dragStartPosition!.dy;
    Rect newSelection = _initialSelection!;

    switch (_dragHandle!) {
      case DragHandle.topLeft:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left + dx,
          _initialSelection!.top + dy,
          _initialSelection!.right,
          _initialSelection!.bottom,
        );
        break;
      case DragHandle.topRight:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left,
          _initialSelection!.top + dy,
          _initialSelection!.right + dx,
          _initialSelection!.bottom,
        );
        break;
      case DragHandle.bottomLeft:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left + dx,
          _initialSelection!.top,
          _initialSelection!.right,
          _initialSelection!.bottom + dy,
        );
        break;
      case DragHandle.bottomRight:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left,
          _initialSelection!.top,
          _initialSelection!.right + dx,
          _initialSelection!.bottom + dy,
        );
        break;
      case DragHandle.top:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left,
          _initialSelection!.top + dy,
          _initialSelection!.right,
          _initialSelection!.bottom,
        );
        break;
      case DragHandle.bottom:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left,
          _initialSelection!.top,
          _initialSelection!.right,
          _initialSelection!.bottom + dy,
        );
        break;
      case DragHandle.left:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left + dx,
          _initialSelection!.top,
          _initialSelection!.right,
          _initialSelection!.bottom,
        );
        break;
      case DragHandle.right:
        newSelection = Rect.fromLTRB(
          _initialSelection!.left,
          _initialSelection!.top,
          _initialSelection!.right + dx,
          _initialSelection!.bottom,
        );
        break;
      case DragHandle.center:
        newSelection = _initialSelection!.shift(Offset(dx, dy));
        break;
    }

    if (widget.aspectRatio != null &&
        _dragHandle != DragHandle.center &&
        _dragHandle != DragHandle.top &&
        _dragHandle != DragHandle.bottom &&
        _dragHandle != DragHandle.left &&
        _dragHandle != DragHandle.right) {
      final width = newSelection.width;
      final height = width / widget.aspectRatio!;
      newSelection = Rect.fromLTWH(
        newSelection.left,
        newSelection.top,
        width,
        height,
      );
    }

    _updateSelection(newSelection);
  }

  /// Handles drag end.
  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
      _dragHandle = null;
      _dragStartPosition = null;
      _initialSelection = null;
    });
  }

  /// Updates selection with constraints and notifies callback.
  void _updateSelection(Rect newSelection) {
    final constrained = _constrainSelection(newSelection);
    setState(() {
      _selection = constrained;
    });
    widget.onSelectionChanged?.call(_selection);
  }

  /// Constrains selection within image bounds and size limits.
  Rect _constrainSelection(Rect rect) {
    double left = rect.left.clamp(0.0, widget.imageSize.width);
    double top = rect.top.clamp(0.0, widget.imageSize.height);
    double right = rect.right.clamp(0.0, widget.imageSize.width);
    double bottom = rect.bottom.clamp(0.0, widget.imageSize.height);

    double width = (right - left).clamp(widget.minSize.width,
        widget.maxSize?.width ?? widget.imageSize.width);
    double height = (bottom - top).clamp(widget.minSize.height,
        widget.maxSize?.height ?? widget.imageSize.height);

    if (right - left < widget.minSize.width) right = left + widget.minSize.width;
    if (bottom - top < widget.minSize.height) bottom = top + widget.minSize.height;

    if (widget.aspectRatio != null) {
      final aspect = widget.aspectRatio!;
      if (width / height > aspect) {
        width = height * aspect;
      } else {
        height = width / aspect;
      }
    }

    if (left + width > widget.imageSize.width) left = widget.imageSize.width - width;
    if (top + height > widget.imageSize.height) top = widget.imageSize.height - height;

    return Rect.fromLTWH(left, top, width, height);
  }

  /// Builds a draggable handle at a given position.
  Widget _buildHandle(DragHandle handle, Offset position) {
    return Positioned(
      left: position.dx - widget.handleSize / 2,
      top: position.dy - widget.handleSize / 2,
      child: GestureDetector(
        onPanStart: (details) => _handleDragStart(handle, details.globalPosition),
        onPanUpdate: (details) => _handleDragUpdate(details.globalPosition),
        onPanEnd: (_) => _handleDragEnd(),
        child: Container(
          width: widget.handleSize,
          height: widget.handleSize,
          decoration: BoxDecoration(
            color: widget.handleColor,
            shape: BoxShape.circle,
            border: Border.all(color: widget.selectionColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// Builds all 8 drag handles.
  List<Widget> _buildHandles() {
    final handles = <Widget>[];
    final rect = _selection;

    handles.addAll([
      _buildHandle(DragHandle.topLeft, rect.topLeft),
      _buildHandle(DragHandle.topRight, rect.topRight),
      _buildHandle(DragHandle.bottomLeft, rect.bottomLeft),
      _buildHandle(DragHandle.bottomRight, rect.bottomRight),
      _buildHandle(DragHandle.top, Offset(rect.center.dx, rect.top)),
      _buildHandle(DragHandle.bottom, Offset(rect.center.dx, rect.bottom)),
      _buildHandle(DragHandle.left, Offset(rect.left, rect.center.dy)),
      _buildHandle(DragHandle.right, Offset(rect.right, rect.center.dy)),
    ]);

    return handles;
  }

  /// Builds grid overlay (rule of thirds).
  Widget _buildGrid() {
    if (!widget.showGrid) return const SizedBox.shrink();
    return Positioned.fromRect(
      rect: _selection,
      child: CustomPaint(
        painter: _GridPainter(color: widget.selectionColor.withOpacity(0.5)),
      ),
    );
  }

  /// Builds dimmed overlay outside selection.
  Widget _buildOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        size: widget.imageSize,
        painter: _OverlayPainter(
          selection: _selection,
          overlayColor: widget.overlayColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.imageSize.width,
      height: widget.imageSize.height,
      child: Stack(
        children: [
          _buildOverlay(),
          Positioned.fromRect(
            rect: _selection,
            child: GestureDetector(
              onPanStart: (details) =>
                  _handleDragStart(DragHandle.center, details.globalPosition),
              onPanUpdate: (details) =>
                  _handleDragUpdate(details.globalPosition),
              onPanEnd: (_) => _handleDragEnd(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.selectionColor,
                    width: widget.borderWidth,
                  ),
                ),
              ),
            ),
          ),
          _buildGrid(),
          ..._buildHandles(),
        ],
      ),
    );
  }
}

/// Painter for dimmed overlay outside selection.
class _OverlayPainter extends CustomPainter {
  final Rect selection;
  final Color overlayColor;

  _OverlayPainter({required this.selection, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      Path()..addRect(selection),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.selection != selection ||
          oldDelegate.overlayColor != overlayColor;
}

/// Painter for grid lines (rule of thirds).
class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    for (int i = 1; i < 3; i++) {
      final dx = thirdWidth * i;
      final dy = thirdHeight * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}