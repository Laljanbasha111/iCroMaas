import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../providers/analysis_provider.dart';

/// ===============================================================
/// DashboardScreen
///
/// Displays:
/// - User information
/// - REAL SQLite analysis statistics
/// - Total analyses
/// - Healthy analyses
/// - Issue analyses
/// - Feature navigation
/// - Logout
///
/// Statistics are provided by AnalysisProvider and are refreshed
/// automatically whenever AnalysisProvider calls notifyListeners().
/// ===============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // ===============================================================
  // AUTH
  // ===============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _user = _auth.currentUser;

    // Refresh statistics when dashboard is first opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AnalysisProvider>().refreshStatistics();
    });
  }

  // ===============================================================
  // APP LIFECYCLE
  // ===============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes back to foreground, refresh the real
    // statistics from SQLite.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AnalysisProvider>().refreshStatistics();
    }
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _auth.signOut();

      if (!mounted) {
        return;
      }

      context.go('/login');
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ===============================================================
  // REFRESH STATISTICS
  // ===============================================================

  Future<void> _refreshDashboard() async {
    try {
      await context
          .read<AnalysisProvider>()
          .refreshStatistics();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to refresh dashboard: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ===============================================================
  // FEATURE CARD
  // ===============================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        context.go(route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.20),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // FEATURE GRID
  // ===============================================================

  Widget _buildFeatureGrid() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.camera_alt,
        'title': 'Capture Image',
        'route': '/camera',
      },
      {
        'icon': Icons.upload_file,
        'title': 'Upload Image',
        'route': '/upload',
      },
      {
        'icon': Icons.history,
        'title': 'Analysis History',
        'route': '/history',
      },
      {
        'icon': Icons.cloud,
        'title': 'Weather Info',
        'route': '/weather',
      },
      {
        'icon': Icons.description,
        'title': 'Reports',
        'route': '/reports',
      },
      {
        'icon': Icons.chat,
        'title': 'AI Chatbot',
        'route': '/chatbot',
      },
      {
        'icon': Icons.person,
        'title': 'Profile',
        'route': '/profile',
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'route': '/settings',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: features.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        final Map<String, dynamic> feature =
        features[index];

        return _buildFeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          route: feature['route'] as String,
        );
      },
    );
  }

  // ===============================================================
  // STATISTICS CARD
  // ===============================================================

  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required int value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(height: 12),

          // Number
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 2),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // REAL STATISTICS SECTION
  // ===============================================================

  Widget _buildStatisticsSection(
      AnalysisProvider provider,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Analysis Overview',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Refresh button
              IconButton(
                tooltip: 'Refresh statistics',
                onPressed: provider.isLoading
                    ? null
                    : _refreshDashboard,
                icon: provider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Real SQLite indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.green.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storage_rounded,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live statistics from local SQLite database',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildStatisticsCard(
                  icon: Icons.analytics_rounded,
                  title: 'Total',
                  value: provider.totalAnalyses,
                  subtitle: 'Analyses',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildStatisticsCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Healthy',
                  value: provider.healthyAnalyses,
                  subtitle: 'Healthy crops',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildStatisticsCard(
                  icon: Icons.warning_rounded,
                  title: 'Issues',
                  value: provider.issueAnalyses,
                  subtitle: 'Need attention',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final String userName =
        _user?.displayName ?? 'Farmer';

    final String userEmail =
        _user?.email ?? '';

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,

      // ===========================================================
      // APP BAR
      // ===========================================================

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Refresh
          Consumer<AnalysisProvider>(
            builder: (
                BuildContext context,
                AnalysisProvider provider,
                Widget? child,
                ) {
              return IconButton(
                tooltip: 'Refresh dashboard',
                onPressed: provider.isLoading
                    ? null
                    : _refreshDashboard,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              );
            },
          ),

          // Logout
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      // ===========================================================
      // BODY
      // ===========================================================

      body: Consumer<AnalysisProvider>(
        builder: (
            BuildContext context,
            AnalysisProvider provider,
            Widget? child,
            ) {
          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ===================================================
              // WELCOME SECTION
              // ===================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                    Radius.circular(24),
                    bottomRight:
                    Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor:
                      Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color:
                        AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $userName!',
                            style:
                            const TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Colors.white,
                            ),
                          ),

                          if (userEmail
                              .isNotEmpty)
                            Text(
                              userEmail,
                              style:
                              const TextStyle(
                                fontSize: 14,
                                color:
                                Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // REAL STATISTICS
              // ===================================================

              _buildStatisticsSection(
                provider,
              ),

              // ===================================================
              // FEATURE TITLE
              // ===================================================

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  0,
                ),
                child: Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ===================================================
              // FEATURE GRID
              // ===================================================

              Expanded(
                child: _buildFeatureGrid(),
              ),
            ],
          );
        },
      ),

      // ===========================================================
      // FLOATING ACTION BUTTON
      // ===========================================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        AppColors.primary,
        onPressed: () {
          context.go('/camera');
        },
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      ),
    );
  }
}