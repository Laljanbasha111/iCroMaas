import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkModeEnabled = false;
  bool _autoSaveAnalysis = true;
  bool _highQualityImages = true;
  bool _offlineMode = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';
  String _dataUsage = 'WiFi Only';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Settings',
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
              child: const Column(
                children: [
                  Icon(
                    Icons.settings,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
                  // Notifications Section
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.notifications_active,
                      title: 'Enable Notifications',
                      subtitle: 'Receive app notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.notifications,
                      title: 'Push Notifications',
                      subtitle: 'Get instant updates',
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.email,
                      title: 'Email Notifications',
                      subtitle: 'Receive updates via email',
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Appearance Section
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Enable dark theme',
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      onTap: () => _showLanguageDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.palette,
                      title: 'Theme',
                      subtitle: _selectedTheme,
                      onTap: () => _showThemeDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Analysis Settings Section
                  const Text(
                    'Analysis Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.save,
                      title: 'Auto-Save Analysis',
                      subtitle: 'Automatically save results',
                      value: _autoSaveAnalysis,
                      onChanged: (value) {
                        setState(() {
                          _autoSaveAnalysis = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.high_quality,
                      title: 'High Quality Images',
                      subtitle: 'Better accuracy, more data',
                      value: _highQualityImages,
                      onChanged: (value) {
                        setState(() {
                          _highQualityImages = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.data_usage,
                      title: 'Data Usage',
                      subtitle: _dataUsage,
                      onTap: () => _showDataUsageDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Storage Section
                  const Text(
                    'Storage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.offline_pin,
                      title: 'Offline Mode',
                      subtitle: 'Use cached data when offline',
                      value: _offlineMode,
                      onChanged: (value) {
                        setState(() {
                          _offlineMode = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.storage,
                      title: 'Storage Usage',
                      subtitle: '245 MB used',
                      onTap: () => _showStorageDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.delete_sweep,
                      title: 'Clear Cache',
                      subtitle: 'Free up space',
                      onTap: () => _showClearCacheDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Privacy & Security Section
                  const Text(
                    'Privacy & Security',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.lock,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () => context.push('/change-password'),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => _showPrivacyDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.security,
                      title: 'Security',
                      subtitle: 'Manage security settings',
                      onTap: () => _showSecurityDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // About Section
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.info,
                      title: 'About App',
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Get help',
                      onTap: () => context.push('/help'),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.rate_review,
                      title: 'Rate App',
                      subtitle: 'Share your feedback',
                      onTap: () => _showRateDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.share,
                      title: 'Share App',
                      subtitle: 'Tell your friends',
                      onTap: () => _showShareDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 72,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('🇺🇸', 'English'),
            _buildLanguageOption('🇮🇳', 'Hindi'),
            _buildLanguageOption('🇪🇸', 'Spanish'),
            _buildLanguageOption('🇫🇷', 'French'),
            _buildLanguageOption('🇩🇪', 'German'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String language) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF2E7D32))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(Icons.light_mode, 'Light'),
            _buildThemeOption(Icons.dark_mode, 'Dark'),
            _buildThemeOption(Icons.brightness_auto, 'System Default'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(IconData icon, String theme) {
    final isSelected = _selectedTheme == theme;
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(theme),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF2E7D32))
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Data Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDataUsageOption('WiFi Only'),
            _buildDataUsageOption('WiFi & Mobile Data'),
            _buildDataUsageOption('Always Ask'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUsageOption(String option) {
    final isSelected = _dataUsage == option;
    return ListTile(
      title: Text(option),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF2E7D32))
          : null,
      onTap: () {
        setState(() {
          _dataUsage = option;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageItem('Images', '150 MB'),
            const SizedBox(height: 8),
            _buildStorageItem('Analysis Data', '75 MB'),
            const SizedBox(height: 8),
            _buildStorageItem('Cache', '20 MB'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildStorageItem('Total', '245 MB', isBold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String size, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          size,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear temporary files and free up 20 MB of space. Your saved analyses will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('We collect crop images and analysis data to provide our services.'),
              SizedBox(height: 16),
              Text(
                'Data Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Your data is used solely for crop health analysis and improving our AI models.'),
              SizedBox(height: 16),
              Text(
                'Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('All data is encrypted and stored securely.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Security Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.fingerprint, color: Color(0xFF2E7D32)),
              title: Text('Biometric Login'),
              subtitle: Text('Use fingerprint or face ID'),
            ),
            ListTile(
              leading: Icon(Icons.lock_clock, color: Color(0xFF2E7D32)),
              title: Text('Auto-Lock'),
              subtitle: Text('Lock app after 5 minutes'),
            ),
            ListTile(
              leading: Icon(Icons.vpn_key, color: Color(0xFF2E7D32)),
              title: Text('Two-Factor Auth'),
              subtitle: Text('Extra security layer'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.agriculture, color: Color(0xFF2E7D32), size: 32),
            SizedBox(width: 12),
            Text('CropAnalyzer'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('AI-Powered Crop Health Analysis'),
            SizedBox(height: 16),
            Text('© 2026 CropAnalyzer Team'),
            SizedBox(height: 8),
            Text('All rights reserved.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rate Our App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enjoying CropAnalyzer?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star, size: 40),
                  color: Colors.amber,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thanks for rating ${index + 1} stars!'),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Share App'),
        content: const Text(
          'Share CropAnalyzer with your fellow farmers and help them grow better crops!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}