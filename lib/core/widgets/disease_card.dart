import 'package:flutter/material.dart';

class DiseaseCard extends StatefulWidget {
  final String diseaseName;
  final String? scientificName;
  final String severity;
  final double affectedArea;
  final double confidence;
  final String? imageUrl;
  final List<String> symptoms;
  final List<String> treatments;
  final String? description;
  final VoidCallback? onTap;
  final bool isExpanded;

  const DiseaseCard({
    Key? key,
    required this.diseaseName,
    this.scientificName,
    required this.severity,
    required this.affectedArea,
    required this.confidence,
    this.imageUrl,
    required this.symptoms,
    required this.treatments,
    this.description,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<DiseaseCard> createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<DiseaseCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.redAccent;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning_amber_rounded;
      case 'high':
        return Icons.error_outline;
      case 'critical':
        return Icons.dangerous;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildHeader() {
    final color = _getSeverityColor(widget.severity);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: Image.network(widget.imageUrl!, fit: BoxFit.contain),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getSeverityIcon(widget.severity), color: color, size: 40),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.diseaseName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.scientificName != null && widget.scientificName!.isNotEmpty)
                Text(
                  widget.scientificName!,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getSeverityIcon(widget.severity), color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.severity,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${value.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsList() {
    if (widget.symptoms.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.sick, color: Colors.redAccent, size: 18),
            SizedBox(width: 6),
            Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ...widget.symptoms.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 6, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTreatmentsList() {
    if (widget.treatments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.medical_services, color: Colors.green, size: 18),
            SizedBox(width: 6),
            Text('Treatment Recommendations', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ...widget.treatments.map((t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.check, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildExpandedContent() {
    final color = _getSeverityColor(widget.severity);
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.description != null && widget.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.description!,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            _buildSymptomsList(),
            _buildTreatmentsList(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = false),
                icon: const Icon(Icons.expand_less, color: Colors.green),
                label: const Text('Show Less', style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(widget.severity);
    return GestureDetector(
      onTap: widget.onTap ?? () => setState(() => _expanded = !_expanded),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildProgressBar('Affected Area', widget.affectedArea, color, Icons.area_chart),
              const SizedBox(height: 8),
              _buildProgressBar('Confidence', widget.confidence, Colors.blue, Icons.verified),
              const SizedBox(height: 8),
              if (!_expanded)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _expanded = true),
                    icon: const Icon(Icons.expand_more, color: Colors.green),
                    label: const Text('Show More', style: TextStyle(color: Colors.green)),
                  ),
                ),
              _buildExpandedContent(),
            ],
          ),
        ),
      ),
    );
  }
}