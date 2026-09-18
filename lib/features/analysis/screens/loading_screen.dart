import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AnalysisLoadingScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisLoadingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  final List<String> _steps = [
    'Processing image data...',
    'Analyzing crop health...',
    'Detecting diseases...',
    'Generating recommendations...',
  ];

  @override
  void initState() {
    super.initState();

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress Controller
    _progressController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // Start analysis simulation
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Start progress animation
    _progressController.forward();

    // Simulate step-by-step analysis
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }

    // Wait a bit more for completion
    await Future.delayed(const Duration(milliseconds: 1000));

    // Navigate to results
    if (mounted) {
      context.pushReplacement(
        '/analysis-result',
        extra: {
          'imagePath': widget.imagePath,
          'disease': 'Leaf Blight',
          'confidence': 92.5,
          'severity': 'Moderate',
          'affectedArea': 35.0,
          'recommendations': [
            'Remove affected leaves immediately',
            'Apply fungicide treatment',
            'Improve air circulation',
            'Reduce watering frequency',
          ],
        },
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50),
                  ],
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Analyzing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Animated Icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Progress Text
                Text(
                  _currentStep < _steps.length
                      ? _steps[_currentStep]
                      : 'Finalizing results...',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'This may take a few moments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_progressController.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Feature Cards
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.psychology,
                        title: 'AI-Powered',
                        subtitle: 'Advanced machine learning',
                        isActive: _currentStep >= 0,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.check_circle_outline,
                        title: 'Accurate Results',
                        subtitle: 'High accuracy rate',
                        isActive: _currentStep >= 1,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.local_hospital,
                        title: 'Crop Health',
                        subtitle: 'Complete health analysis',
                        isActive: _currentStep >= 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
        ],
      ),
    );
  }
}