import 'package:flutter/material.dart';

/// Enum representing the position of the resize handle.
enum HandlePosition {
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

/// Enum representing the shape of the resize handle.
enum HandleShape {
  circle,
  square,
}

/// A draggable resize handle widget used for resizing or moving selections.
/// Supports custom shapes, directional icons, hover feedback, and drag callbacks.
class ResizeHandle extends StatelessWidget {
  final HandlePosition position;
  final double size;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final Function(DragStartDetails)? onDragStart;
  final Function(DragUpdateDetails)? onDragUpdate;
  final Function(DragEndDetails)? onDragEnd;
  final HandleShape shape;
  final bool showIcon;

  const ResizeHandle({
    Key? key,
    required this.position,
    this.size = 20.0,
    this.color = Colors.white,
    this.borderColor = Colors.green,
    this.borderWidth = 2.0,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.shape = HandleShape.circle,
    this.showIcon = false,
  }) : super(key: key);

  /// Returns an icon representing the handle direction.
  IconData? _getIcon() {
    switch (position) {
      case HandlePosition.topLeft:
        return Icons.north_west;
      case HandlePosition.topRight:
        return Icons.north_east;
      case HandlePosition.bottomLeft:
        return Icons.south_west;
      case HandlePosition.bottomRight:
        return Icons.south_east;
      case HandlePosition.top:
        return Icons.north;
      case HandlePosition.bottom:
        return Icons.south;
      case HandlePosition.left:
        return Icons.west;
      case HandlePosition.right:
        return Icons.east;
      case HandlePosition.center:
        return Icons.open_with;
    }
  }

  /// Returns a mouse cursor based on the handle position.
  MouseCursor _getCursor() {
    switch (position) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case HandlePosition.top:
      case HandlePosition.bottom:
        return SystemMouseCursors.resizeUpDown;
      case HandlePosition.left:
      case HandlePosition.right:
        return SystemMouseCursors.resizeLeftRight;
      case HandlePosition.center:
        return SystemMouseCursors.move;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _getCursor(),
      child: GestureDetector(
        onPanStart: onDragStart,
        onPanUpdate: onDragUpdate,
        onPanEnd: onDragEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: shape == HandleShape.circle ? BoxShape.circle : BoxShape.rectangle,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: showIcon
              ? Center(
            child: Icon(
              _getIcon(),
              size: size * 0.6,
              color: borderColor,
            ),
          )
              : null,
        ),
      ),
    );
  }
}