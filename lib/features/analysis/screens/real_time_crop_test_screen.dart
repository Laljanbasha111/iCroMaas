import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/crop_test_controller.dart';
import '../widgets/crop_selector_widget.dart';
import '../widgets/prediction_card_widget.dart';
import '../widgets/comparison_widget.dart';

/// Screen for real-time crop model testing
class RealTimeCropTestScreen extends StatelessWidget {
  const RealTimeCropTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(CropTestController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Model Testing'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          // Model status indicator
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: controller.isModelLoaded.value
                      ? Colors.green[300]
                      : Colors.red[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.isModelLoaded.value
                          ? Icons.check_circle
                          : Icons.error,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.isModelLoaded.value
                          ? 'Model Ready'
                          : 'Model Loading',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          // Statistics button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatisticsDialog(context, controller),
            tooltip: 'View Statistics',
          ),
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context, controller),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics Summary Card
              _buildStatisticsSummaryCard(controller),
              const SizedBox(height: 16),

              // Crop Selector
              CropSelectorWidget(
                cropDataList: controller.allCropData.value,
                selectedCrop: controller.currentCropData.value,
                onCropSelected: (crop) {
                  controller.selectCrop(crop);
                },
              ),
              const SizedBox(height: 16),

              // Test Button
              if (controller.currentCropData.value != null) ...[
                ElevatedButton.icon(
                  onPressed: controller.isModelLoaded.value
                      ? () => controller.runPredictionOnReferenceCrop()
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Prediction Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Prediction Result Card
              if (controller.currentPrediction.value != null)
                PredictionCardWidget(
                  prediction: controller.currentPrediction.value!,
                ),

              const SizedBox(height: 16),

              // Comparison Widget
              if (controller.currentTestResult.value != null)
                ComparisonWidget(
                  testResult: controller.currentTestResult.value!,
                ),

              const SizedBox(height: 16),

              // Error Message
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.resetCurrentTest(),
        icon: const Icon(Icons.refresh),
        label: const Text('Reset'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  /// Build statistics summary card
  Widget _buildStatisticsSummaryCard(CropTestController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Testing Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Tests',
                  controller.totalTests.value.toString(),
                  Icons.science,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Avg Accuracy',
                  '${controller.averageAccuracy.value.toStringAsFixed(1)}%',
                  Icons.percent,
                  Colors.green,
                ),
                _buildStatItem(
                  'Excellent',
                  controller.excellentPredictions.value.toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Show statistics dialog
  void _showStatisticsDialog(BuildContext context, CropTestController controller) {
    final stats = controller.getModelInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text('Detailed Statistics'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Tests', controller.totalTests.value.toString()),
              _buildStatRow(
                'Average Accuracy',
                '${controller.averageAccuracy.value.toStringAsFixed(2)}%',
              ),
              _buildStatRow('Good Predictions', controller.goodPredictions.value.toString()),
              _buildStatRow(
                'Excellent Predictions',
                controller.excellentPredictions.value.toString(),
              ),
              const Divider(height: 24),
              const Text(
                'Model Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatRow('Model Loaded', stats['loaded'].toString()),
              if (stats['loaded'] == true) ...[
                _buildStatRow('Input Size', stats['input_size'].toString()),
                _buildStatRow('Channels', stats['num_channels'].toString()),
                _buildStatRow('Outputs', stats['num_outputs'].toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build stat row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Show history dialog
  void _showHistoryDialog(BuildContext context, CropTestController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text('Test History'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.testHistory.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No test history available'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.testHistory.length,
              itemBuilder: (context, index) {
                final result = controller.testHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: result.isExcellentPrediction
                          ? Colors.green
                          : result.isGoodPrediction
                          ? Colors.blue
                          : Colors.orange,
                      child: Text(
                        result.cropName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(result.cropName),
                    subtitle: Text(
                      'Accuracy: ${result.overallAccuracy.toStringAsFixed(1)}%',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        controller.deleteTestResult(result.id);
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearAllTestResults();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}