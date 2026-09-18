import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../core/services/render_analysis_service.dart';

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
  String _status = 'Preparing image...';
  bool _hasError = false;
  String _errorMessage = '';
  bool _analysisStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _runAnalysis();
      }
    });
  }

  Future<void> _runAnalysis() async {
    if (_analysisStarted) {
      return;
    }

    _analysisStarted = true;

    try {
      final imageFile = File(widget.imagePath);

      setState(() {
        _progress = 0.15;
        _status = 'Checking selected image...';
      });

      if (!await imageFile.exists()) {
        throw Exception(
          'Selected image was not found.',
        );
      }

      final fileLength = await imageFile.length();

      if (fileLength == 0) {
        throw Exception(
          'Selected image is empty.',
        );
      }

      setState(() {
        _progress = 0.30;
        _status = 'Connecting to iCroMaas AI...';
      });

      debugPrint(
        'Render analysis image: ${widget.imagePath}',
      );

      final response =
          await RenderAnalysisService.analyzeImage(
        widget.imagePath,
      );

      setState(() {
        _progress = 0.80;
        _status = 'Processing AI results...';
      });

      final analysis = response['analysis'];

      if (analysis is! Map<String, dynamic>) {
        throw Exception(
          'Invalid analysis response received from server.',
        );
      }

      final cropType =
          (analysis['cropType'] ??
                  analysis['cropClass'] ??
                  'Unknown')
              .toString();

      final cropConfidence = _toDouble(
        analysis['cropTypeConfidence'] ??
            analysis['confidence'],
      );

      final biomass = _toDouble(
        analysis['biomass'],
      );

      final nitrogen = _toDouble(
        analysis['nitrogen'],
      );

      debugPrint(
        'Crop Type: $cropType',
      );
      debugPrint(
        'Crop Confidence: $cropConfidence',
      );
      debugPrint(
        'Biomass: $biomass',
      );
      debugPrint(
        'Nitrogen: $nitrogen',
      );

      setState(() {
        _progress = 1.0;
        _status = 'Analysis complete!';
      });

      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) {
        return;
      }

      AppRouter.navigateToResult(
        context,
        imagePath: widget.imagePath,
        cropType: cropType,
        nitrogen: nitrogen,
        biomass: biomass,
        confidence: cropConfidence,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Render analysis failed: $e',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _status = 'Analysis failed';
        _progress = 0.0;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  void _retry() {
    setState(() {
      _progress = 0.0;
      _status = 'Preparing image...';
      _hasError = false;
      _errorMessage = '';
      _analysisStarted = false;
    });

    _runAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Analysis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: _hasError
                ? _buildErrorView(colorScheme)
                : _buildLoadingView(colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.eco,
            size: 58,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Analyzing your crop',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _status,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 260,
          child: LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _progress > 0
              ? '${(_progress * 100).round()}%'
              : 'Connecting...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          'Securely sending the image to the iCroMaas AI backend.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 56,
            color: colorScheme.error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Analysis Failed',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage.isEmpty
              ? 'Unable to analyze this image.'
              : _errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Analysis'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }
}
