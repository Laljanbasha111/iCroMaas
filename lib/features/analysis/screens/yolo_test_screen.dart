import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/analysis_provider.dart';

class YoloTestScreen extends StatefulWidget {
  const YoloTestScreen({Key? key}) : super(key: key);

  @override
  State<YoloTestScreen> createState() => _YoloTestScreenState();
}

class _YoloTestScreenState extends State<YoloTestScreen> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize YOLO models when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().initializeYoloModels();
    });
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null) {
        setState(() => _imagePath = image.path);

        if (mounted) {
          final provider = context.read<AnalysisProvider>();
          await provider.analyzeImageWithYolo(File(image.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YOLO Model Test'),
        backgroundColor: const Color(0xFF1A7F64),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Display
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isAnalyzing
                            ? null
                            : () => _pickAndAnalyze(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A7F64),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isAnalyzing
                            ? null
                            : () => _pickAndAnalyze(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A7F64),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Loading Indicator
                if (provider.isAnalyzing)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Analyzing with YOLO models...',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: provider.progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1A7F64),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error Display
                if (provider.error != null && !provider.isAnalyzing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Results Display
                if (provider.yoloResults != null && !provider.isAnalyzing) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '🎯 Analysis Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nitrogen Result
                  _buildResultCard(
                    title: 'Nitrogen Status',
                    icon: Icons.science,
                    color: Colors.blue,
                    label: provider.nitrogenStatus ?? 'Unknown',
                    confidence: provider.nitrogenConfidence ?? 0,
                  ),

                  const SizedBox(height: 12),

                  // Crop Type Result
                  _buildResultCard(
                    title: 'Crop Type',
                    icon: Icons.grass,
                    color: Colors.green,
                    label: provider.cropType ?? 'Unknown',
                    confidence: provider.cropTypeConfidence ?? 0,
                  ),

                  const SizedBox(height: 12),

                  // Biomass Result
                  _buildResultCard(
                    title: 'Biomass Level',
                    icon: Icons.eco,
                    color: Colors.orange,
                    label: provider.biomassLevel ?? 'Unknown',
                    confidence: provider.biomassConfidence ?? 0,
                  ),

                  const SizedBox(height: 24),

                  // Health Score
                  if (provider.currentResult != null)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              '🏥 Overall Health Score',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${provider.currentResult!.healthScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _getHealthColor(
                                  provider.currentResult!.healthScore,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required Color color,
    required String label,
    required double confidence,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              label.replaceAll('_', ' '),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${confidence.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}