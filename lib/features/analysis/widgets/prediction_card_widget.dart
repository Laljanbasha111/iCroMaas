import 'package:flutter/material.dart';
import '../../../models/prediction_result_model.dart';

/// Widget to display prediction results
class PredictionCardWidget extends StatelessWidget {
  final PredictionResult prediction;

  const PredictionCardWidget({
    super.key, // ✅ FIXED: Modern Flutter syntax
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Prediction Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildConfidenceBadge(),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop name (if available)
                if (prediction.cropName != null) ...[
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        prediction.cropName!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Biomass prediction
                _buildPredictionRow(
                  icon: Icons.grass,
                  label: 'Predicted Biomass',
                  value: prediction.formattedBiomass,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),

                // Nitrogen prediction
                _buildPredictionRow(
                  icon: Icons.science,
                  label: 'Predicted Nitrogen',
                  value: prediction.formattedNitrogen,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),

                // Confidence bar
                _buildConfidenceBar(),
                const SizedBox(height: 16),

                // Timestamp
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      prediction.formattedTimestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  /// Build confidence badge
  Widget _buildConfidenceBadge() {
    final confidencePercent = (prediction.confidence * 100).toStringAsFixed(0);
    final color = _getConfidenceColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '$confidencePercent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build prediction row
  Widget _buildPredictionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // ✅ FIXED: Use withValues
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)), // ✅ FIXED
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2), // ✅ FIXED
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build confidence bar
  Widget _buildConfidenceBar() {
    final confidencePercent = prediction.confidence * 100;
    final color = _getConfidenceColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Confidence Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${confidencePercent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: prediction.confidence,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getConfidenceLabel(),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Get confidence color based on value
  Color _getConfidenceColor() {
    if (prediction.confidence >= 0.8) {
      return Colors.green;
    } else if (prediction.confidence >= 0.6) {
      return Colors.blue;
    } else if (prediction.confidence >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get confidence label
  String _getConfidenceLabel() {
    if (prediction.confidence >= 0.8) {
      return 'High Confidence';
    } else if (prediction.confidence >= 0.6) {
      return 'Good Confidence';
    } else if (prediction.confidence >= 0.4) {
      return 'Moderate Confidence';
    } else {
      return 'Low Confidence';
    }
  }
}