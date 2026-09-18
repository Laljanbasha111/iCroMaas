import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalysisCard extends StatelessWidget {
  final File imageFile;
  final String cropType;
  final double healthScore;
  final String date;
  final String? disease;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const AnalysisCard({
    Key? key,
    required this.imageFile,
    required this.cropType,
    required this.healthScore,
    required this.date,
    this.disease,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getHealthIcon(double score) {
    if (score >= 80) return Icons.eco;
    if (score >= 50) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  String _formatDate(String dateString) {
    try {
      final parsed = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor(healthScore);
    final formattedDate = _formatDate(date);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.agriculture, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        cropType,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: healthColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getHealthIcon(healthScore), color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${healthScore.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (disease != null && disease!.isNotEmpty)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bug_report, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          disease!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle, color: Colors.white, size: 48),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.white24,
                    highlightColor: Colors.white10,
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}