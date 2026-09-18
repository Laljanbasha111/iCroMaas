import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';

/// Screen displayed after an image is selected.
///
/// Automatic crop analysis is currently unavailable because the
/// API, YOLO, and TFLite analysis engines have been removed.
///
/// This screen:
/// - Checks whether the selected image exists
/// - Avoids calling the removed YOLO/API service
/// - Shows a clear explanation to the user
/// - Prevents repeated analysis errors
/// - Returns the user to the home screen
class AnalysisLoadingScreen extends StatefulWidget {
  const AnalysisLoadingScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState
    extends State<AnalysisLoadingScreen> {
  double _progress = 0.0;

  String _status =
      'Checking analysis availability...';

  bool _hasError = false;

  String _errorMessage = '';

  bool _checkStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (mounted) {
          _checkAnalysisAvailability();
        }
      },
    );
  }

  // ============================================================
  // CHECK ANALYSIS AVAILABILITY
  // ============================================================

  Future<void> _checkAnalysisAvailability() async {
    if (_checkStarted) {
      return;
    }

    _checkStarted = true;

    try {
      _updateStatus(
        0.15,
        'Checking selected image...',
      );

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '📷 CHECKING SELECTED CROP IMAGE',
      );
      debugPrint(
        '📁 Image: ${widget.imagePath}',
      );
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      final String safeImagePath =
      widget.imagePath.trim();

      if (safeImagePath.isEmpty) {
        throw Exception(
          'No image path was provided.',
        );
      }

      final File imageFile =
      File(safeImagePath);

      final bool imageExists =
      await imageFile.exists();

      if (!imageExists) {
        throw Exception(
          'Image file not found:\n$safeImagePath',
        );
      }

      final int fileSize =
      await imageFile.length();

      if (fileSize <= 0) {
        throw Exception(
          'The selected image file is empty.',
        );
      }

      debugPrint(
        '✅ Image file exists',
      );

      debugPrint(
        '📦 Image size: $fileSize bytes',
      );

      _updateStatus(
        0.35,
        'Image is ready...',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) {
        return;
      }

      throw StateError(
        'Automatic crop analysis is currently unavailable. '
            'No API, YOLO, or TFLite analysis engine is configured.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '⚠️ CROP ANALYSIS UNAVAILABLE',
      );
      debugPrint(
        '⚠️ Error: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      if (!mounted) {
        return;
      }

      final String message =
      error.toString().replaceFirst(
        'Exception: ',
        '',
      );

      setState(() {
        _hasError = true;
        _errorMessage = message;
        _status = 'Analysis unavailable';
        _progress = 0.0;
      });

      await Future<void>.delayed(
        const Duration(milliseconds: 250),
      );

      if (mounted) {
        _showUnavailableDialog();
      }
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  void _updateStatus(
      double progress,
      String status,
      ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _progress = progress
          .clamp(0.0, 1.0)
          .toDouble();

      _status = status;
    });
  }

  // ============================================================
  // UNAVAILABLE DIALOG
  // ============================================================

  void _showUnavailableDialog() {
    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Analysis Unavailable',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'The image was selected successfully, '
                      'but automatic crop analysis is not currently '
                      'configured in this app.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: 0.06),
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    _errorMessage.isEmpty
                        ? 'No analysis engine is configured.'
                        : _errorMessage,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Current status:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusItem(
                  icon: Icons.check_circle_outline,
                  text: 'Image selection is working.',
                  color: Colors.green,
                ),
                _buildStatusItem(
                  icon: Icons.remove_circle_outline,
                  text:
                  'Automatic crop prediction is disabled.',
                  color: Colors.orange,
                ),
                _buildStatusItem(
                  icon: Icons.remove_circle_outline,
                  text:
                  'No API, YOLO, or TFLite engine is active.',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _goToHome();
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
              label: const Text(
                'Back to Home',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATUS ITEM
  // ============================================================

  Widget _buildStatusItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _goToHome() {
    if (!mounted) {
      return;
    }

    context.go(
      AppRouter.homePath,
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/ai_processing.json',
                    width: 220,
                    height: 220,
                    repeat: !_hasError,
                    errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                        ) {
                      return Icon(
                        _hasError
                            ? Icons.info_outline
                            : Icons.analytics_outlined,
                        size: 120,
                        color: _hasError
                            ? Colors.orange
                            : AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 35),
                  Text(
                    _hasError
                        ? 'Analysis Unavailable'
                        : 'Preparing Image',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _hasError
                          ? Colors.orange[800]
                          : AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 16,
                      color: _hasError
                          ? Colors.orange[800]
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      color: _hasError
                          ? Colors.orange
                          : AppColors.primary,
                      backgroundColor:
                      Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _hasError
                          ? Colors.orange[800]
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _hasError
                          ? Colors.orange.withValues(
                        alpha: 0.10,
                      )
                          : AppColors.primary
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasError
                            ? Colors.orange.withValues(
                          alpha: 0.25,
                        )
                            : AppColors.primary
                            .withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _hasError
                              ? Icons.info_outline
                              : Icons.image_outlined,
                          color: _hasError
                              ? Colors.orange[800]
                              : AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _hasError
                                ? 'Your image is safe. '
                                'Automatic analysis is currently '
                                'disabled.'
                                : 'Checking the selected image.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: _hasError
                                  ? Colors.orange[900]
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}