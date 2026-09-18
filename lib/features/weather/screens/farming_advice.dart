import 'package:flutter/material.dart';

class FarmingAdviceScreen extends StatelessWidget {
  const FarmingAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> alerts = [
      {
        'type': 'warning',
        'title': 'Heavy Rain Expected',
        'message': 'Heavy rainfall expected on Sunday. Consider postponing irrigation and field work.',
        'icon': Icons.warning_amber,
        'color': Colors.orange,
        'action': 'View Details',
      },
      {
        'type': 'info',
        'title': 'Optimal Planting Conditions',
        'message': 'Next 3 days show ideal conditions for planting wheat. Soil moisture is optimal.',
        'icon': Icons.info,
        'color': Colors.blue,
        'action': 'Learn More',
      },
      {
        'type': 'success',
        'title': 'Good Weather Ahead',
        'message': 'Clear skies forecasted for the weekend. Perfect for harvesting and field preparation.',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'action': 'Plan Activities',
      },
    ];

    final List<Map<String, dynamic>> recommendations = [
      {
        'title': 'Irrigation Schedule',
        'description': 'Based on current weather, reduce irrigation by 30% this week.',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'title': 'Pest Control',
        'description': 'High humidity may increase pest activity. Monitor crops closely.',
        'icon': Icons.bug_report,
        'color': Colors.red,
      },
      {
        'title': 'Fertilizer Application',
        'description': 'Ideal conditions for fertilizer application on Friday morning.',
        'icon': Icons.science,
        'color': Colors.green,
      },
      {
        'title': 'Harvesting Window',
        'description': 'Best harvesting conditions expected between Jul 24-26.',
        'icon': Icons.agriculture,
        'color': Colors.amber,
      },
    ];

    final List<Map<String, dynamic>> tips = [
      {
        'title': 'Soil Moisture Management',
        'tip': 'With expected rainfall, ensure proper drainage to prevent waterlogging.',
      },
      {
        'title': 'Crop Protection',
        'tip': 'Cover sensitive crops before heavy rain to prevent damage.',
      },
      {
        'title': 'Equipment Maintenance',
        'tip': 'Service machinery during clear weather days for optimal performance.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather Alerts
          const Text(
            'Weather Alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) => _buildAlertCard(context, alert)),

          const SizedBox(height: 24),

          // Farming Recommendations
          const Text(
            'Farming Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => _buildRecommendationCard(rec)),

          const SizedBox(height: 24),

          // Quick Tips
          const Text(
            'Quick Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
              children: tips.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                return Column(
                  children: [
                    _buildTipItem(tip),
                    if (index < tips.length - 1)
                      Divider(height: 1, color: Colors.grey[200]),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (alert['color'] as Color).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (alert['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alert['icon'],
                    color: alert['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['message'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${alert['action']} - Coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(alert['action']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (rec['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              rec['icon'],
              color: rec['color'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(Map<String, dynamic> tip) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['tip'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}