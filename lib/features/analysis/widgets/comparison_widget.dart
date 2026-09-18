import 'package:flutter/material.dart';
import '../../../models/test_result_model.dart';

/// Widget to compare predicted vs reference values
class ComparisonWidget extends StatelessWidget {
  final TestResult testResult;

  const ComparisonWidget({
    Key? key,
    required this.testResult,
  }) : super(key: key);

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
                colors: _getHeaderGradientColors(),
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
                const Icon(Icons.compare_arrows, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Accuracy Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildAccuracyBadge(),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall accuracy
                _buildOverallAccuracySection(),
                const SizedBox(height: 20),

                // Biomass comparison
                _buildComparisonSection(
                  icon: Icons.grass,
                  label: 'Biomass',
                  referenceValue: testResult.referenceBiomass,
                  predictedValue: testResult.predictedBiomass,
                  unit: 'g/m²',
                  accuracy: testResult.biomassAccuracy,
                  error: testResult.biomassError,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                // Nitrogen comparison
                _buildComparisonSection(
                  icon: Icons.science,
                  label: 'Nitrogen',
                  referenceValue: testResult.referenceNitrogen,
                  predictedValue: testResult.predictedNitrogen,
                  unit: '%',
                  accuracy: testResult.nitrogenAccuracy,
                  error: testResult.nitrogenError,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),

                // Performance indicator
                _buildPerformanceIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get header gradient colors based on accuracy
  List<Color> _getHeaderGradientColors() {
    if (testResult.isExcellentPrediction) {
      return [Colors.green[700]!, Colors.green[500]!];
    } else if (testResult.isGoodPrediction) {
      return [Colors.blue[700]!, Colors.blue[500]!];
    } else {
      return [Colors.orange[700]!, Colors.orange[500]!];
    }
  }

  /// Build accuracy badge
  Widget _buildAccuracyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        testResult.accuracyCategory,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build overall accuracy section
  Widget _buildOverallAccuracySection() {
    final color = _getAccuracyColor(testResult.overallAccuracy);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Accuracy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${testResult.overallAccuracy.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: testResult.overallAccuracy / 100,
              minHeight: 16,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Build comparison section
  Widget _buildComparisonSection({
    required IconData icon,
    required String label,
    required double referenceValue,
    required double predictedValue,
    required String unit,
    required double accuracy,
    required double error,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccuracyColor(accuracy),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Values comparison
          Row(
            children: [
              Expanded(
                child: _buildValueBox(
                  'Reference',
                  '${referenceValue.toStringAsFixed(2)} $unit',
                  Colors.grey[700]!,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Expanded(
                child: _buildValueBox(
                  'Predicted',
                  '${predictedValue.toStringAsFixed(2)} $unit',
                  color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Error display
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Error: ${error.abs().toStringAsFixed(2)} $unit',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                error > 0 ? '(Overestimated)' : '(Underestimated)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build value box
  Widget _buildValueBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build performance indicator
  Widget _buildPerformanceIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Indicators',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicatorItem(
                Icons.check_circle,
                testResult.isGoodPrediction ? 'Good' : 'Needs Improvement',
                testResult.isGoodPrediction ? Colors.green : Colors.orange,
              ),
              _buildIndicatorItem(
                Icons.star,
                testResult.isExcellentPrediction ? 'Excellent' : 'Not Excellent',
                testResult.isExcellentPrediction ? Colors.amber : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build indicator item
  Widget _buildIndicatorItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Get accuracy color
  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) {
      return Colors.green;
    } else if (accuracy >= 80) {
      return Colors.blue;
    } else if (accuracy >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}