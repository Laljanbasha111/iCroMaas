import 'package:flutter/material.dart';

class DroneControlPanel extends StatelessWidget {
  final bool isConnected;
  final bool isFlying;
  final bool isCameraActive;
  final double altitude;
  final VoidCallback onConnect;
  final VoidCallback onTakeoff;
  final VoidCallback onLand;
  final VoidCallback onCapture;
  final Function(double) onAltitudeChange;

  const DroneControlPanel({
    super.key,
    required this.isConnected,
    required this.isFlying,
    required this.isCameraActive,
    required this.altitude,
    required this.onConnect,
    required this.onTakeoff,
    required this.onLand,
    required this.onCapture,
    required this.onAltitudeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        children: [
          // Main action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Connect/Disconnect
              _buildControlButton(
                icon: isConnected ? Icons.link_off : Icons.link,
                label: isConnected ? 'Disconnect' : 'Connect',
                color: isConnected ? Colors.red : Colors.blue,
                onPressed: isConnected ? null : onConnect,
              ),

              // Takeoff/Land
              _buildControlButton(
                icon: isFlying ? Icons.flight_land : Icons.flight_takeoff,
                label: isFlying ? 'Land' : 'Takeoff',
                color: isFlying ? Colors.orange : Colors.green,
                onPressed: isConnected ? (isFlying ? onLand : onTakeoff) : null,
              ),

              // Capture
              _buildControlButton(
                icon: Icons.camera,
                label: 'Capture',
                color: Colors.purple,
                onPressed: isCameraActive ? onCapture : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Directional controls
          if (isFlying) _buildDirectionalControls(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed != null ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionalControls() {
    return Column(
      children: [
        const Text(
          'Flight Controls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up
            IconButton(
              onPressed: () => onAltitudeChange(1),
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 16),
            // Down
            IconButton(
              onPressed: () => onAltitudeChange(-1),
              icon: const Icon(Icons.arrow_downward, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

