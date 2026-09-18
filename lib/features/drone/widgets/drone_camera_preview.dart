import 'package:flutter/material.dart';

class DroneCameraPreview extends StatelessWidget {
  final bool isActive;
  final double altitude;
  final bool isFlying;
  final int capturedImages;

  const DroneCameraPreview({
    super.key,
    required this.isActive,
    required this.altitude,
    required this.isFlying,
    required this.capturedImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Stack(
        children: [
          // Simulated camera view background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.videocam : Icons.videocam_off,
                  size: 80,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  isActive ? 'LIVE FEED' : 'CAMERA INACTIVE',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Crosshair overlay (targeting reticle)
          if (isActive)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Center crosshair
                    Center(
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    // Corner markers
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.green, width: 3),
                            left: BorderSide(color: Colors.green, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.green, width: 3),
                            right: BorderSide(color: Colors.green, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.green, width: 3),
                            left: BorderSide(color: Colors.green, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.green, width: 3),
                            right: BorderSide(color: Colors.green, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Altitude indicator (Right side)
          if (isFlying)
            Positioned(
              right: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.height, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      '${altitude.toStringAsFixed(1)}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ALT',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Captured images counter (Left side)
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$capturedImages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PHOTOS',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid overlay (when camera is active)
          if (isActive)
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),

          // Bottom info bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.camera,
                    label: isActive ? '4K 60FPS' : 'STANDBY',
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                  if (isFlying)
                    _buildInfoItem(
                      icon: Icons.speed,
                      label: '0.0 m/s',
                      color: Colors.blue,
                    ),
                  _buildInfoItem(
                    icon: Icons.sd_card,
                    label: '128GB',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom painter for grid overlay
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    final verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalSpacing * i, 0),
        Offset(verticalSpacing * i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    final horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, horizontalSpacing * i),
        Offset(size.width, horizontalSpacing * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}