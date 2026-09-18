import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/analysis_database.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const AnalysisResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState
    extends State<AnalysisResultScreen> {
  Future<void>? _saveFuture;
  bool _saveStarted = false;

  @override
  void initState() {
    super.initState();

    // Save the analysis automatically once the screen
    // has finished its first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSavedToHistory();
    });
  }

  // ============================================================
  // SAFE DATA HELPERS
  // ============================================================

  double _readDouble(
      Map<String, dynamic> data,
      List<String> keys, {
        double defaultValue = 0.0,
      }) {
    for (final String key in keys) {
      final dynamic value = data[key];

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        final double? parsed =
        double.tryParse(value.trim());

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return defaultValue;
  }

  String _readString(
      Map<String, dynamic> data,
      List<String> keys, {
        String defaultValue = 'Unknown',
      }) {
    for (final String key in keys) {
      final dynamic value = data[key];

      if (value is String &&
          value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value != null) {
        final String text =
        value.toString().trim();

        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return defaultValue;
  }

  // ============================================================
  // EXTRACT RESULT DATA
  // ============================================================

  Map<String, dynamic> _extractPredictionData() {
    final Map<String, dynamic> prediction =
    widget.result['prediction']
    is Map<String, dynamic>
        ? Map<String, dynamic>.from(
      widget.result['prediction']
      as Map<String, dynamic>,
    )
        : <String, dynamic>{};

    final String cropType = _readString(
      widget.result,
      [
        'cropType',
        'cropName',
        'crop',
      ],
      defaultValue: _readString(
        prediction,
        [
          'cropType',
          'cropName',
          'crop',
        ],
        defaultValue: 'Unknown',
      ),
    );

    final double nitrogen = _readDouble(
      widget.result,
      [
        'nitrogen',
        'predictedNitrogen',
      ],
      defaultValue: _readDouble(
        prediction,
        [
          'nitrogen',
          'predictedNitrogen',
        ],
      ),
    );

    final double biomass = _readDouble(
      widget.result,
      [
        'biomass',
        'predictedBiomass',
      ],
      defaultValue: _readDouble(
        prediction,
        [
          'biomass',
          'predictedBiomass',
        ],
      ),
    );

    final double confidence = _readDouble(
      widget.result,
      [
        'confidence',
        'overallAccuracy',
      ],
      defaultValue: _readDouble(
        prediction,
        [
          'confidence',
          'overallAccuracy',
        ],
      ),
    );

    final String imagePath = _readString(
      widget.result,
      [
        'imagePath',
        'imageUrl',
      ],
      defaultValue: '',
    );

    return <String, dynamic>{
      'cropType': cropType,
      'nitrogen': nitrogen,
      'biomass': biomass,
      'confidence': confidence,
      'imagePath': imagePath,
    };
  }

  // ============================================================
  // SAVE RESULT
  // ============================================================

  Future<void> _ensureSavedToHistory() {
    if (_saveFuture != null) {
      return _saveFuture!;
    }

    _saveFuture =
        _saveToHistory(
          _extractPredictionData(),
        );

    return _saveFuture!;
  }

  Future<void> _saveToHistory(
      Map<String, dynamic> data,
      ) async {
    // Prevent duplicate saves.
    if (_saveStarted) {
      return;
    }

    _saveStarted = true;

    try {
      // ----------------------------------------------------------
      // READ ANALYSIS DATA
      // ----------------------------------------------------------

      final String cropType =
          data['cropType'] as String? ??
              'Unknown';

      final double nitrogen =
          (data['nitrogen'] as num?)
              ?.toDouble() ??
              0.0;

      final double biomass =
          (data['biomass'] as num?)
              ?.toDouble() ??
              0.0;

      final double confidence =
          (data['confidence'] as num?)
              ?.toDouble() ??
              0.0;

      final String imagePath =
          data['imagePath'] as String? ??
              '';

      // ----------------------------------------------------------
      // CALCULATE HEALTH
      // ----------------------------------------------------------

      final String healthStatus =
      _getHealthStatus(
        nitrogen,
        biomass,
      );

      final int healthScore =
      _calculateHealthScore(
        nitrogen,
        biomass,
      );

      final bool isHealthy =
          healthStatus == 'Healthy';

      // ----------------------------------------------------------
      // FIRESTORE DATA
      // ----------------------------------------------------------

      final Map<String, dynamic>
      analysisData =
      <String, dynamic>{
        'crop_name': cropType,

        'disease_name': healthStatus,

        'is_healthy': isHealthy,

        'confidence': confidence,

        'nitrogen': nitrogen,

        'biomass': biomass,

        'health_score': healthScore,

        'severity': healthStatus,

        'image_path': imagePath,

        // AnalysisDatabase converts this
        // DateTime into Firestore Timestamp.
        'timestamp': DateTime.now(),
      };

      // ----------------------------------------------------------
      // SAVE TO FIREBASE
      // ----------------------------------------------------------

      final String analysisId =
      await AnalysisDatabase.instance
          .insertAnalysis(
        analysisData,
      );

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      debugPrint(
        '✅ ANALYSIS SAVED TO FIREBASE',
      );

      debugPrint(
        '🆔 Analysis ID: $analysisId',
      );

      debugPrint(
        '🌱 Crop: $cropType',
      );

      debugPrint(
        '🧪 Nitrogen: $nitrogen',
      );

      debugPrint(
        '🌾 Biomass: $biomass',
      );

      debugPrint(
        '🎯 Confidence: $confidence',
      );

      debugPrint(
        '❤️ Health: $healthStatus',
      );

      debugPrint(
        '📊 Health Score: $healthScore',
      );

      debugPrint(
        '☁️ Firebase save completed',
      );

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      debugPrint(
        '❌ FIREBASE SAVE FAILED',
      );

      debugPrint(
        '❌ Error: $e',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
    _extractPredictionData();

    final String imagePath =
        data['imagePath'] as String? ??
            '';

    final String cropType =
        data['cropType'] as String? ??
            'Unknown';

    final double nitrogen =
        (data['nitrogen'] as num?)
            ?.toDouble() ??
            0.0;

    final double biomass =
        (data['biomass'] as num?)
            ?.toDouble() ??
            0.0;

    final double confidence =
        (data['confidence'] as num?)
            ?.toDouble() ??
            0.0;

    final String healthStatus =
    _getHealthStatus(
      nitrogen,
      biomass,
    );

    final int healthScore =
    _calculateHealthScore(
      nitrogen,
      biomass,
    );

    final Color healthColor =
    _getHealthColor(
      healthStatus,
    );

    final List<String> recommendations =
    _generateRecommendations(
      cropType,
      nitrogen,
      biomass,
    );

    debugPrint(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    debugPrint(
      '🔍 ANALYSIS RESULT SCREEN',
    );

    debugPrint(
      '🌱 Crop: $cropType',
    );

    debugPrint(
      '🧪 Nitrogen: $nitrogen',
    );

    debugPrint(
      '🌾 Biomass: $biomass',
    );

    debugPrint(
      '🎯 Confidence: $confidence',
    );

    debugPrint(
      '❤️ Health: $healthStatus',
    );

    debugPrint(
      '📊 Health Score: $healthScore',
    );

    debugPrint(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text(
          'Analysis Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {
            await _ensureSavedToHistory();

            if (!context.mounted) {
              return;
            }

            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
            ),
            tooltip: 'Share Results',
            onPressed: () {
              _shareResults(
                context,
                cropType,
                nitrogen,
                biomass,
                confidence,
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.download,
            ),
            tooltip: 'Save Report',
            onPressed: () {
              _downloadReport(
                context,
                cropType,
                nitrogen,
                biomass,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics:
        const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            if (imagePath.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.black,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .image_not_supported_outlined,
                            size: 64,
                            color:
                            Colors.grey,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Unable to display image',
                            style:
                            TextStyle(
                              color:
                              Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                              const EdgeInsets
                                  .all(12),
                              decoration:
                              BoxDecoration(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),
                              child:
                              const Icon(
                                Icons.eco,
                                color: Color(
                                  0xFF2E7D32,
                                ),
                                size: 32,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  const Text(
                                    'Detected Crop',
                                    style:
                                    TextStyle(
                                      fontSize:
                                      14,
                                      color:
                                      Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    _formatCropName(
                                      cropType,
                                    ),
                                    style:
                                    const TextStyle(
                                      fontSize:
                                      24,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: Colors
                                          .black87,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .check_circle,
                                        size: 15,
                                        color:
                                        Colors.green[
                                        700],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'AI Analysis Complete',
                                        style:
                                        TextStyle(
                                          fontSize:
                                          12,
                                          color:
                                          Colors.green[
                                          700],
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildStatItem(
                                'Confidence',
                                '${confidence.toStringAsFixed(1)}%',
                                Icons.verified,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child:
                              _buildStatItem(
                                'Analysis',
                                'Offline AI',
                                Icons.memory,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            const Text(
                              'Crop Health Status',
                              style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration:
                              BoxDecoration(
                                color: healthColor
                                    .withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                healthStatus,
                                style: TextStyle(
                                  color:
                                  healthColor,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 75,
                              height: 75,
                              child: Stack(
                                alignment:
                                Alignment
                                    .center,
                                children: [
                                  CircularProgressIndicator(
                                    value:
                                    healthScore /
                                        100,
                                    strokeWidth:
                                    8,
                                    backgroundColor:
                                    Colors
                                        .grey
                                        .shade200,
                                    valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                      healthColor,
                                    ),
                                  ),
                                  Text(
                                    '$healthScore',
                                    style:
                                    TextStyle(
                                      fontSize:
                                      20,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color:
                                      healthColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  const Text(
                                    'Overall Health Score',
                                    style:
                                    TextStyle(
                                      fontSize:
                                      14,
                                      color:
                                      Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    '$healthScore / 100',
                                    style:
                                    const TextStyle(
                                      fontSize:
                                      22,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ClipRRect(
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                          child:
                          LinearProgressIndicator(
                            value:
                            healthScore /
                                100,
                            minHeight: 9,
                            backgroundColor:
                            Colors.grey
                                .shade200,
                            valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                              healthColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Crop Metrics',
                          style:
                          TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child:
                              _buildMetricTile(
                                'Nitrogen (N)',
                                '${nitrogen.toStringAsFixed(2)}%',
                                Icons.science,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                              _buildMetricTile(
                                'Biomass',
                                '${biomass.toStringAsFixed(1)} g/m²',
                                Icons.grass,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome,
                              color: Color(
                                0xFF2E7D32,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'AI Recommendations',
                              style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ...recommendations.map(
                              (
                              String recommendation,
                              ) =>
                              Padding(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 7,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    const Icon(
                                      Icons
                                          .check_circle,
                                      color: Color(
                                        0xFF2E7D32,
                                      ),
                                      size: 19,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Expanded(
                                      child: Text(
                                        recommendation,
                                        style:
                                        const TextStyle(
                                          fontSize:
                                          14,
                                          color: Colors
                                              .black87,
                                          height:
                                          1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _ensureSavedToHistory();

                        if (!context.mounted) {
                          return;
                        }

                        context.go('/home');
                      },
                      icon: const Icon(
                        Icons.home,
                      ),
                      label: const Text(
                        'Save & Go Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFF2E7D32,
                        ),
                        foregroundColor:
                        Colors.white,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.05),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                label,
                style:
                const TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                value,
                style:
                const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.bold,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // METRIC TILE
  // ============================================================

  Widget _buildMetricTile(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            label,
            style:
            const TextStyle(
              fontSize: 12,
              color:
              Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH STATUS
  // ============================================================

  String _getHealthStatus(
      double nitrogen,
      double biomass,
      ) {
    if (nitrogen > 2.0 &&
        biomass > 150) {
      return 'Healthy';
    }

    if (nitrogen > 1.0 &&
        biomass > 80) {
      return 'Moderate';
    }

    return 'Needs Attention';
  }

  // ============================================================
  // HEALTH SCORE
  // ============================================================

  int _calculateHealthScore(
      double nitrogen,
      double biomass,
      ) {
    final double nitrogenScore =
    (nitrogen / 4.0 * 50)
        .clamp(0.0, 50.0);

    final double biomassScore =
    (biomass / 300.0 * 50)
        .clamp(0.0, 50.0);

    return (nitrogenScore +
        biomassScore)
        .round()
        .clamp(0, 100);
  }

  // ============================================================
  // HEALTH COLOR
  // ============================================================

  Color _getHealthColor(
      String status,
      ) {
    switch (status) {
      case 'Healthy':
        return Colors.green;

      case 'Moderate':
        return Colors.orange;

      default:
        return Colors.red;
    }
  }

  // ============================================================
  // RECOMMENDATIONS
  // ============================================================

  List<String> _generateRecommendations(
      String crop,
      double nitrogen,
      double biomass,
      ) {
    final List<String>
    recommendations =
    <String>[];

    if (nitrogen < 1.5) {
      recommendations.add(
        'Apply nitrogen-rich fertilizer or urea to support healthy crop growth.',
      );
    } else if (nitrogen > 4.0) {
      recommendations.add(
        'Nitrogen appears high. Avoid excessive nitrogen fertilizer application.',
      );
    } else {
      recommendations.add(
        'Nitrogen level appears stable. Maintain the current nutrient management schedule.',
      );
    }

    if (biomass < 100) {
      recommendations.add(
        'Biomass is relatively low. Check irrigation, soil condition, and crop development.',
      );
    } else if (biomass > 300) {
      recommendations.add(
        'Biomass is strong. Continue monitoring crop development and field conditions.',
      );
    } else {
      recommendations.add(
        'Biomass level is developing normally. Continue regular crop monitoring.',
      );
    }

    if (crop != 'Unknown') {
      recommendations.add(
        'Continue monitoring $crop regularly using the crop analysis camera.',
      );
    } else {
      recommendations.add(
        'Capture a clearer crop image if you want more reliable crop identification.',
      );
    }

    return recommendations;
  }

  // ============================================================
  // FORMAT CROP NAME
  // ============================================================

  String _formatCropName(
      String crop,
      ) {
    if (crop.trim().isEmpty ||
        crop.toLowerCase() ==
            'unknown') {
      return 'UNKNOWN';
    }

    return crop
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where(
          (String word) =>
      word.trim().isNotEmpty,
    )
        .map(
          (String word) =>
      word[0].toUpperCase() +
          word
              .substring(1)
              .toLowerCase(),
    )
        .join(' ');
  }

  // ============================================================
  // SHARE
  // ============================================================

  void _shareResults(
      BuildContext context,
      String crop,
      double nitrogen,
      double biomass,
      double confidence,
      ) {
    final String message = '''
🌱 Crop Analysis Report

Crop: ${_formatCropName(crop)}
Nitrogen: ${nitrogen.toStringAsFixed(2)}%
Biomass: ${biomass.toStringAsFixed(1)} g/m²
AI Confidence: ${confidence.toStringAsFixed(1)}%

Generated by AI Crop Analyzer.
''';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message.trim(),
        ),
        duration:
        const Duration(
          seconds: 4,
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD / REPORT
  // ============================================================

  void _downloadReport(
      BuildContext context,
      String crop,
      double nitrogen,
      double biomass,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Report preparation for '
              '${_formatCropName(crop)} '
              '(${nitrogen.toStringAsFixed(2)}% N, '
              '${biomass.toStringAsFixed(1)} g/m²)',
        ),
      ),
    );
  }
}