import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/analysis_database.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ResultScreen({super.key, this.extra});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _imagePath;
  late Map<String, dynamic> _analysisData;

  double _acres = 1.0;
  final TextEditingController _acresController =
  TextEditingController(text: '1.0');

  bool _analysisSaved = false;
  Future<void>? _saveFuture;

  @override
  void initState() {
    super.initState();
    _initializeAnalysisData();
  }

  // ============================================================
  // INITIALIZE ANALYSIS DATA
  // ============================================================

  void _initializeAnalysisData() {
    final Map<String, dynamic> data = widget.extra ?? <String, dynamic>{};

    _imagePath = _readString(
      data,
      keys: <String>['imagePath', 'path', 'filePath', 'image'],
      fallback: '',
    );

    final String cropType = _readString(
      data,
      keys: <String>['cropType', 'cropName'],
      fallback: 'Unknown',
    );

    final double nitrogen = _readDouble(
      data,
      keys: <String>['nitrogen', 'predictedNitrogen'],
      fallback: 0.0,
    );

    final double biomass = _readDouble(
      data,
      keys: <String>['biomass', 'predictedBiomass'],
      fallback: 0.0,
    );

    final double confidence = _readDouble(
      data,
      keys: <String>['confidence', 'overallAccuracy'],
      fallback: 0.0,
    );

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════╗');
    debugPrint('║   ✅ LOCAL TFLITE DATA RECEIVED      ║');
    debugPrint('╚═══════════════════════════════════════╝');
    debugPrint('    Crop: $cropType');
    debugPrint('    Nitrogen: ${nitrogen.toStringAsFixed(2)}%');
    debugPrint('    Biomass: ${biomass.toStringAsFixed(2)} g/m²');
    debugPrint('    Confidence: ${confidence.toStringAsFixed(2)}%');
    debugPrint('');

    final String healthStatus = _calculateHealthStatus(nitrogen, biomass);
    final int healthScore = _calculateHealthScore(nitrogen, biomass);

    _analysisData = <String, dynamic>{
      'cropType': cropType,
      'nitrogen': nitrogen,
      'biomass': biomass,
      'confidence': confidence,
      'healthStatus': healthStatus,
      'healthScore': healthScore,
      'fertilizers': _generateFertilizerRecommendations(nitrogen, cropType),
      'pesticides': _generatePesticideRecommendations(healthStatus),
      'expectedYield': _calculateExpectedYield(biomass),
      'pricePerQuintal': 2500,
      'costPerAcre': 15000,
    };
  }

  // ============================================================
  // SAFE PARSERS
  // ============================================================

  String _readString(
      Map<String, dynamic> data, {
        required List<String> keys,
        required String fallback,
      }) {
    for (final String key in keys) {
      final Object? value = data[key];
      if (value == null) continue;

      final String text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return fallback;
  }

  double _readDouble(
      Map<String, dynamic> data, {
        required List<String> keys,
        required double fallback,
      }) {
    for (final String key in keys) {
      final Object? value = data[key];
      if (value == null) continue;

      if (value is num) {
        return value.toDouble();
      }

      final double? parsed = double.tryParse(value.toString().trim());
      if (parsed != null) return parsed;
    }

    return fallback;
  }

  // ============================================================
  // SAVE TO DATABASE
  // ============================================================

  Future<void> _saveAnalysisToDatabase() async {
    if (_analysisSaved) return;

    if (_saveFuture != null) {
      return _saveFuture;
    }

    _saveFuture = _doSaveAnalysisToDatabase();
    return _saveFuture;
  }

  Future<void> _doSaveAnalysisToDatabase() async {
    try {
      final Map<String, dynamic> analysisData = <String, dynamic>{
        'crop_name': _analysisData['cropType'] ?? 'Unknown',
        'disease_name': _analysisData['healthStatus'] ?? 'Unknown',
        'is_healthy': (_analysisData['healthStatus'] == 'Excellent' ||
            _analysisData['healthStatus'] == 'Good')
            ? 1
            : 0,
        'confidence': _analysisData['confidence'] ?? 0.0,
        'nitrogen': _analysisData['nitrogen'] ?? 0.0,
        'biomass': _analysisData['biomass'] ?? 0.0,
        'health_score': _analysisData['healthScore'] ?? 0,
        'severity': _analysisData['healthStatus'] ?? 'Unknown',
        'image_path': _imagePath,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await AnalysisDatabase.instance.insertAnalysis(analysisData);
      _analysisSaved = true;
      debugPrint('✅ Analysis saved to database');
    } catch (e) {
      debugPrint('❌ Error saving analysis: $e');
    }
  }

  // ============================================================
  // HEALTH LOGIC
  // ============================================================

  String _calculateHealthStatus(double nitrogen, double biomass) {
    if (nitrogen > 2.5 && biomass > 200) return 'Excellent';
    if (nitrogen > 1.5 && biomass > 100) return 'Good';
    if (nitrogen > 0.8 && biomass > 50) return 'Fair';
    return 'Poor';
  }

  int _calculateHealthScore(double nitrogen, double biomass) {
    int score = 0;

    if (nitrogen > 2.5 && nitrogen < 4.0) {
      score += 50;
    } else if (nitrogen > 1.5) {
      score += 35;
    } else if (nitrogen > 0.8) {
      score += 20;
    } else {
      score += 10;
    }

    if (biomass > 200) {
      score += 50;
    } else if (biomass > 100) {
      score += 35;
    } else if (biomass > 50) {
      score += 20;
    } else {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  double _calculateExpectedYield(double biomass) {
    return (biomass / 10).clamp(15, 35);
  }

  List<Map<String, String>> _generateFertilizerRecommendations(
      double nitrogen,
      String crop,
      ) {
    final List<Map<String, String>> recommendations = <Map<String, String>>[];

    if (nitrogen < 1.5) {
      recommendations.add(<String, String>{
        'name': 'Urea (46-0-0)',
        'quantity': '60 kg/acre',
        'timing': 'Apply immediately - split into 2 doses',
      });
      recommendations.add(<String, String>{
        'name': 'DAP (18-46-0)',
        'quantity': '30 kg/acre',
        'timing': 'Apply at next irrigation',
      });
    } else if (nitrogen > 4.0) {
      recommendations.add(<String, String>{
        'name': 'Reduce Nitrogen',
        'quantity': 'Skip next application',
        'timing': 'Wait 3-4 weeks before reassessing',
      });
    } else {
      recommendations.add(<String, String>{
        'name': 'Balanced NPK (20-20-20)',
        'quantity': '40 kg/acre',
        'timing': 'Maintain current schedule',
      });
    }

    recommendations.add(<String, String>{
      'name': 'Potash (MOP)',
      'quantity': '25 kg/acre',
      'timing': 'Apply after 30 days',
    });

    return recommendations;
  }

  List<Map<String, String>> _generatePesticideRecommendations(
      String healthStatus,
      ) {
    if (healthStatus == 'Poor' || healthStatus == 'Fair') {
      return <Map<String, String>>[
        <String, String>{
          'name': 'Chlorpyrifos 20% EC',
          'dosage': '2 ml/liter water',
          'purpose': 'Pest control and prevention',
        },
        <String, String>{
          'name': 'Mancozeb 75% WP',
          'dosage': '2.5 g/liter water',
          'purpose': 'Fungal disease prevention',
        },
      ];
    } else {
      return <Map<String, String>>[
        <String, String>{
          'name': 'Neem Oil',
          'dosage': '5 ml/liter water',
          'purpose': 'Organic pest prevention',
        },
      ];
    }
  }

  double _calculateIncome() {
    final num yieldVal = _analysisData['expectedYield'] as num;
    final num price = _analysisData['pricePerQuintal'] as num;
    final num cost = _analysisData['costPerAcre'] as num;

    final double revenue = yieldVal.toDouble() * price.toDouble() * _acres;
    final double totalCost = cost.toDouble() * _acres;
    return revenue - totalCost;
  }

  @override
  void dispose() {
    _acresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String cropType =
    (_analysisData['cropType'] as String?)?.trim().isNotEmpty == true
        ? _analysisData['cropType'] as String
        : 'Unknown';

    final double nitrogen = (_analysisData['nitrogen'] as num?)?.toDouble() ?? 0;
    final double biomass = (_analysisData['biomass'] as num?)?.toDouble() ?? 0;
    final double confidence =
        (_analysisData['confidence'] as num?)?.toDouble() ?? 0;
    final int healthScore = (_analysisData['healthScore'] as int?) ?? 0;
    final String healthStatus =
        (_analysisData['healthStatus'] as String?) ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Analysis Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await _saveAnalysisToDatabase();
            if (mounted) context.go(AppRouter.homePath);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Crop: $cropType | N: ${nitrogen.toStringAsFixed(2)}% | B: ${biomass.toStringAsFixed(1)} g/m²',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 Report downloaded!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 20),
            _buildCropInfoCard(cropType, confidence),
            const SizedBox(height: 16),
            _buildHealthStatusCard(healthStatus, healthScore),
            const SizedBox(height: 16),
            _buildNutrientCard(nitrogen, biomass),
            const SizedBox(height: 16),
            _buildFertilizersCard(),
            const SizedBox(height: 16),
            _buildPesticidesCard(),
            const SizedBox(height: 16),
            _buildIncomeCard(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _imagePath.isNotEmpty
            ? Image.file(
          File(_imagePath),
          fit: BoxFit.cover,
        )
            : Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.image,
            size: 80,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CROP INFO CARD
  // ============================================================

  Widget _buildCropInfoCard(String cropType, double confidence) {
    return _buildCard(
      title: 'Detected Crop',
      icon: Icons.eco,
      iconColor: AppColors.primary,
      child: Column(
        children: [
          Text(
            cropType.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '✅ Local Offline TFLite Prediction',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Confidence',
            '${confidence.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH STATUS CARD
  // ============================================================

  Widget _buildHealthStatusCard(String healthStatus, int healthScore) {
    Color healthColor = Colors.green;
    if (healthScore < 50) {
      healthColor = Colors.red;
    } else if (healthScore < 75) {
      healthColor = Colors.orange;
    }

    return _buildCard(
      title: 'Crop Health Status',
      icon: Icons.favorite,
      iconColor: healthColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  healthStatus,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$healthScore/100',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: healthScore / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUTRIENT CARD
  // ============================================================

  Widget _buildNutrientCard(double nitrogen, double biomass) {
    return _buildCard(
      title: 'Nutrient Analysis',
      icon: Icons.science,
      iconColor: Colors.blue,
      child: Row(
        children: [
          Expanded(
            child: _buildMetricBox(
              'Nitrogen',
              '${nitrogen.toStringAsFixed(2)}%',
              Colors.blue,
              Icons.water_drop,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricBox(
              'Biomass',
              '${biomass.toStringAsFixed(1)} g/m²',
              Colors.green,
              Icons.grass,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FERTILIZER CARD
  // ============================================================

  Widget _buildFertilizersCard() {
    final List fertilizers = _analysisData['fertilizers'] as List;

    return _buildCard(
      title: 'Recommended Fertilizers',
      icon: Icons.agriculture,
      iconColor: Colors.green,
      child: Column(
        children: fertilizers.map((fertilizer) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fertilizer['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${fertilizer['quantity']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Timing: ${fertilizer['timing']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // PESTICIDE CARD
  // ============================================================

  Widget _buildPesticidesCard() {
    final List pesticides = _analysisData['pesticides'] as List;

    return _buildCard(
      title: 'Recommended Pesticides',
      icon: Icons.pest_control,
      iconColor: Colors.orange,
      child: Column(
        children: pesticides.map((pesticide) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pesticide['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosage: ${pesticide['dosage']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Purpose: ${pesticide['purpose']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // INCOME CARD
  // ============================================================

  Widget _buildIncomeCard() {
    final double income = _calculateIncome();
    final bool isProfit = income > 0;

    return _buildCard(
      title: 'Annual Income Estimate',
      icon: Icons.currency_rupee,
      iconColor: Colors.purple,
      child: Column(
        children: [
          TextField(
            controller: _acresController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Acres',
              prefixIcon: const Icon(Icons.landscape),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _acres = double.tryParse(value) ?? 1.0;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProfit
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  isProfit ? 'Expected Profit' : 'Expected Loss',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₹${income.abs().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Per Year (${_acres.toStringAsFixed(1)} acres)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Expected Yield',
            '${_analysisData['expectedYield'].toStringAsFixed(1)} quintals/acre',
          ),
          _buildInfoRow(
            'Price per Quintal',
            '₹${_analysisData['pricePerQuintal']}',
          ),
          _buildInfoRow(
            'Cultivation Cost',
            '₹${_analysisData['costPerAcre']}/acre',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.go(AppRouter.reportsPath),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await _saveAnalysisToDatabase();
              if (mounted) context.go(AppRouter.quadratPath);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('New Analysis'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC BOX
  // ============================================================

  Widget _buildMetricBox(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}