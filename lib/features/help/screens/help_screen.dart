import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Getting Started',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'questions': [
        {
          'question': 'How do I analyze my crops?',
          'answer': 'Simply tap the camera icon on the home screen, take a photo of your crop, and our AI will analyze it within seconds. You can also upload existing photos from your gallery.',
        },
        {
          'question': 'What crops are supported?',
          'answer': 'We support analysis for wheat, rice, corn, tomatoes, potatoes, cotton, soybeans, and many more. Our AI is continuously learning to support more crop varieties.',
        },
        {
          'question': 'How accurate is the analysis?',
          'answer': 'Our AI model has 95%+ accuracy in detecting common crop diseases and health issues. However, we recommend consulting with agricultural experts for critical decisions.',
        },
      ],
    },
    {
      'category': 'Analysis & Results',
      'icon': Icons.analytics,
      'color': Colors.green,
      'questions': [
        {
          'question': 'How long does analysis take?',
          'answer': 'Most analyses complete within 5-10 seconds. Complex cases may take up to 30 seconds. Make sure you have a stable internet connection.',
        },
        {
          'question': 'Can I save my analysis results?',
          'answer': 'Yes! All your analyses are automatically saved in the History section. You can view, compare, and export them anytime.',
        },
        {
          'question': 'What do the health scores mean?',
          'answer': 'Health scores range from 0-100:\n• 80-100: Excellent health\n• 60-79: Good health\n• 40-59: Fair health, monitor closely\n• 0-39: Poor health, action needed',
        },
      ],
    },
    {
      'category': 'Weather & Advice',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'questions': [
        {
          'question': 'How accurate is the weather forecast?',
          'answer': 'We use multiple weather data sources to provide accurate 7-day forecasts. Weather predictions are updated every 6 hours.',
        },
        {
          'question': 'Can I get farming advice for my location?',
          'answer': 'Yes! Enable location services and we\'ll provide weather-based farming advice specific to your area.',
        },
        {
          'question': 'How does the AI assistant work?',
          'answer': 'Our AI assistant uses natural language processing to understand your farming questions and provide relevant advice based on best practices and scientific research.',
        },
      ],
    },
    {
      'category': 'Account & Settings',
      'icon': Icons.settings,
      'color': Colors.purple,
      'questions': [
        {
          'question': 'How do I change my password?',
          'answer': 'Go to Profile > Settings > Privacy & Security > Change Password. You\'ll need to enter your current password to set a new one.',
        },
        {
          'question': 'Can I use the app offline?',
          'answer': 'Some features like viewing saved analyses work offline. However, new crop analysis and weather updates require an internet connection.',
        },
        {
          'question': 'How do I delete my account?',
          'answer': 'Go to Profile > Delete Account. Please note this action is permanent and will delete all your data.',
        },
      ],
    },
    {
      'category': 'Troubleshooting',
      'icon': Icons.build,
      'color': Colors.red,
      'questions': [
        {
          'question': 'Camera not working?',
          'answer': 'Make sure you\'ve granted camera permissions in your device settings. Go to Settings > Apps > CropAnalyzer > Permissions and enable Camera.',
        },
        {
          'question': 'Analysis failed or stuck?',
          'answer': 'Check your internet connection and try again. If the problem persists, clear the app cache in Settings > Storage > Clear Cache.',
        },
        {
          'question': 'App crashes or freezes?',
          'answer': 'Try restarting the app. If issues continue, update to the latest version from the app store or contact support.',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'icon': Icons.email,
      'title': 'Email Support',
      'subtitle': 'support@cropanalyzer.com',
      'color': Colors.blue,
      'action': 'email',
    },
    {
      'icon': Icons.phone,
      'title': 'Phone Support',
      'subtitle': '+91 1800-123-4567',
      'color': Colors.green,
      'action': 'phone',
    },
    {
      'icon': Icons.chat,
      'title': 'Live Chat',
      'subtitle': 'Chat with our team',
      'color': Colors.orange,
      'action': 'chat',
    },
    {
      'icon': Icons.language,
      'title': 'Visit Website',
      'subtitle': 'www.cropanalyzer.com',
      'color': Colors.purple,
      'action': 'website',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFAQs() {
    if (_searchQuery.isEmpty) return _faqs;

    return _faqs.map((category) {
      final filteredQuestions = (category['questions'] as List).where((q) {
        final question = q['question'].toString().toLowerCase();
        final answer = q['answer'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return question.contains(query) || answer.contains(query);
      }).toList();

      return {
        ...category,
        'questions': filteredQuestions,
      };
    }).where((category) => (category['questions'] as List).isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFAQs = _getFilteredFAQs();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find answers or contact support',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Support Options
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9, // Fixed overflow: Increased height allowance per card
                    ),
                    itemCount: _supportOptions.length,
                    itemBuilder: (context, index) {
                      final option = _supportOptions[index];
                      return _buildSupportCard(option);
                    },
                  ),

                  const SizedBox(height: 32),

                  // FAQs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          '${filteredFAQs.fold<int>(0, (sum, cat) => sum + (cat['questions'] as List).length)} results',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (filteredFAQs.isEmpty)
                    _buildNoResults()
                  else
                    ...filteredFAQs.map((category) {
                      return _buildFAQCategory(category);
                    }),

                  const SizedBox(height: 32),

                  // Additional Resources
                  const Text(
                    'Additional Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResourceCard(
                    icon: Icons.video_library,
                    title: 'Video Tutorials',
                    subtitle: 'Watch step-by-step guides',
                    color: Colors.red,
                    onTap: () => _showComingSoon('Video Tutorials'),
                  ),
                  const SizedBox(height: 12),
                  _buildResourceCard(
                    icon: Icons.menu_book,
                    title: 'User Guide',
                    subtitle: 'Complete documentation',
                    color: Colors.blue,
                    onTap: () => _showComingSoon('User Guide'),
                  ),
                  const SizedBox(height: 12),
                  _buildResourceCard(
                    icon: Icons.forum,
                    title: 'Community Forum',
                    subtitle: 'Connect with other farmers',
                    color: Colors.green,
                    onTap: () => _showComingSoon('Community Forum'),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(Map<String, dynamic> option) {
    return InkWell(
      onTap: () => _handleSupportAction(option['action']),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (option['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option['icon'],
                color: option['color'],
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              option['title'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              option['subtitle'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category['icon'],
              color: category['color'],
              size: 24,
            ),
          ),
          title: Text(
            category['category'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            '${(category['questions'] as List).length} questions',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          children: (category['questions'] as List).map((q) {
            return _buildFAQItem(q);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              faq['question'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['answer'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or contact support',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleSupportAction(String action) {
    switch (action) {
      case 'email':
        _launchEmail();
        break;
      case 'phone':
        _launchPhone();
        break;
      case 'chat':
        _openLiveChat();
        break;
      case 'website':
        _launchWebsite();
        break;
    }
  }

  void _launchEmail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email app...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _launchPhone() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening phone app...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text('Live Chat'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Our support team is available:'),
            SizedBox(height: 12),
            Text(
              'Monday - Friday\n9:00 AM - 6:00 PM IST',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Average response time: 5 minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/chatbot');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _launchWebsite() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening website...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}