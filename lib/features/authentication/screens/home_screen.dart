import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/test_results_database.dart';
import '../../../models/test_result_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // ================================================================
  // DATABASE
  // ================================================================

  final TestResultsDatabase _database = TestResultsDatabase.instance;

  ValueListenable<Box<TestResult>>? _testResultsListenable;
  bool _isDatabaseReady = false;
  String? _statsError;

  // ================================================================
  // LIFECYCLE
  // ================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _database.init();

      if (!mounted) return;

      setState(() {
        _testResultsListenable = _database.listenable();
        _isDatabaseReady = true;
        _statsError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDatabaseReady = false;
        _statsError = e.toString();
      });
    }
  }

  // ================================================================
  // APP LIFECYCLE
  // ================================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  // ================================================================
  // REFRESH STATISTICS
  // ================================================================

  Future<void> _refreshStatistics() async {
    if (!_database.isInitialized) {
      await _initializeDatabase();
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Lucky';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // ============================================================
      // APP BAR / HEADER ZONE
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back! 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onPressed: () {
                      // Notification functionality.
                    },
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      context.push('/profile');
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green[700],
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'L',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: RefreshIndicator(
        onRefresh: _refreshStatistics,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // SEARCH BAR
              // ========================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.green,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search crops, diseases...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          // Add search functionality.
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ========================================================
              // REAL-TIME STATISTICS SECTION
              // ========================================================

              _buildStatisticsSection(),

              const SizedBox(height: 22),

              // ========================================================
              // CROP ANALYSIS
              // ========================================================

              _buildActionCard(
                title: 'Crop Analysis',
                subtitle: 'Analyze crop images with local TFLite models',
                icon: Icons.camera_alt,
                gradient: LinearGradient(
                  colors: [
                    Colors.green[700]!,
                    Colors.green[500]!,
                  ],
                ),
                onTap: () async {
                  await context.push('/quadrat');
                  await _refreshStatistics();
                },
              ),

              const SizedBox(height: 14),

              // ========================================================
              // DRONE CONTROL
              // ========================================================

              _buildActionCard(
                title: 'Drone Control 🚁',
                subtitle: 'Aerial crop monitoring and field image capture',
                icon: Icons.flight_takeoff,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[400]!,
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Drone Control - Coming Soon!'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // ========================================================
              // GEMINI AI ASSISTANT
              // ========================================================

              _buildActionCard(
                title: 'Gemini AI Assistant',
                subtitle:
                'Agricultural advice, pest control, disease guidance, and crop support',
                icon: Icons.psychology_outlined,
                gradient: LinearGradient(
                  colors: [
                    Colors.teal[700]!,
                    Colors.teal[500]!,
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Assistant - Coming Soon!'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ========================================================
              // FEATURES / QUICK ACTIONS HEADER
              // ========================================================

              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.history,
                      label: 'History',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('History - Coming Soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      onTap: () {
                        context.push('/profile');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // REAL-TIME STATISTICS SECTION
  // ====================================================================

  Widget _buildStatisticsSection() {
    if (_statsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics unavailable',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unable to read the local analysis database.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _refreshStatistics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (!_isDatabaseReady || _testResultsListenable == null) {
      return Row(
        children: [
          _buildLoadingStatCard(),
          _buildLoadingStatCard(),
          _buildLoadingStatCard(),
        ],
      );
    }

    return ValueListenableBuilder<Box<TestResult>>(
      valueListenable: _testResultsListenable!,
      builder: (context, box, _) {
        final stats = _database.getStatistics();

        final int total =
        stats['total_tests'] is int ? stats['total_tests'] as int : 0;

        final int healthy = stats['healthy_count'] is int
            ? stats['healthy_count'] as int
            : 0;

        final int issues =
        stats['issue_count'] is int ? stats['issue_count'] as int : 0;

        return Column(
          children: [
            // -------------------------------------------------------------
            // LIVE STATUS BAR
            // -------------------------------------------------------------
            Padding(
              padding:
              const EdgeInsets.only(bottom: 8.0, left: 2.5, right: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Real-time data • Updates automatically',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _refreshStatistics,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.refresh,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------------
            // STAT CARDS
            // -------------------------------------------------------------
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.eco,
                  iconColor: Colors.green[700]!,
                  title: 'Analyses',
                  count: total,
                  subtitle: 'Total Analyses',
                  trend: 'Live',
                  trendColor: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green[700]!,
                  title: 'Healthy',
                  count: healthy,
                  subtitle: 'Healthy Crops',
                  trend: 'Live',
                  trendColor: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange[800]!,
                  title: 'Issues',
                  count: issues,
                  subtitle: 'Issues Detected',
                  trend: 'Live',
                  trendColor: Colors.red,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ====================================================================
  // STAT CARD
  // ====================================================================

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required String subtitle,
    required String trend,
    required Color trendColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                '$count',
                key: ValueKey<int>(count),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 10,
                  color: trendColor,
                ),
                const SizedBox(width: 2),
                Text(
                  trend,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // LOADING STAT CARD
  // ====================================================================

  Widget _buildLoadingStatCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // ACTION CARD
  // ====================================================================

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // QUICK ACTION BUTTON
  // ====================================================================

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // DISPOSE
  // ====================================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}