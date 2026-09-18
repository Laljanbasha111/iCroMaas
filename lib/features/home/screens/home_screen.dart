import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/analysis_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _userName = 'Farmer';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && mounted) {
          setState(() {
            _userName = doc.data()?['name'] ?? 'Farmer';
            _loading = false;
          });
        } else if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _auth.signOut();

      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              // =====================================================
              // REAL-TIME ANALYSIS STATISTICS
              // =====================================================
              _buildQuickStats(),

              const SizedBox(height: 20),

              _buildAnalyzeCard(),

              const SizedBox(height: 16),

              _buildDroneCard(),

              const SizedBox(height: 24),

              _buildFeaturesSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back! 👋',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Notifications
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // REAL-TIME QUICK STATISTICS
  // ===============================================================

  Widget _buildQuickStats() {
    final AnalysisProvider analysisProvider =
    context.watch<AnalysisProvider>();

    final int totalAnalyses =
        analysisProvider.totalAnalyses;

    final int healthyAnalyses =
        analysisProvider.healthyAnalyses;

    final int issueAnalyses =
        analysisProvider.issueAnalyses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // =========================================================
          // TOTAL ANALYSES
          // =========================================================

          Expanded(
            child: _buildStatCard(
              icon: Icons.analytics_outlined,
              title: 'Analyses',
              value: totalAnalyses.toString(),
              color: const Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          // =========================================================
          // HEALTHY
          // =========================================================

          Expanded(
            child: _buildStatCard(
              icon: Icons.verified_outlined,
              title: 'Healthy',
              value: healthyAnalyses.toString(),
              color: const Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(width: 12),

          // =========================================================
          // ISSUES
          // =========================================================

          Expanded(
            child: _buildStatCard(
              icon: Icons.error_outline,
              title: 'Issues',
              value: issueAnalyses.toString(),
              color: const Color(0xFFFFA726),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ANALYZE CARD
  // ===============================================================

  Widget _buildAnalyzeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/quadrat');
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF66BB6A),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Analyze Your Crop',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Take a photo to get instant health analysis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white
                                .withValues(alpha: 0.95),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DRONE CARD
  // ===============================================================

  Widget _buildDroneCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/drone');
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flight,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Drone Control ',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '🚁',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Control your drone for aerial crop monitoring',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white
                                .withValues(alpha: 0.95),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // FEATURES SECTION
  // ===============================================================

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              _buildFeatureCard(
                icon: Icons.history,
                title: 'History',
                color: const Color(0xFF42A5F5),
                onTap: () {
                  context.push('/history');
                },
              ),

              _buildFeatureCard(
                icon: Icons.assessment,
                title: 'Reports',
                color: const Color(0xFFAB47BC),
                onTap: () {
                  context.push('/reports');
                },
              ),

              _buildFeatureCard(
                icon: Icons.compare_arrows,
                title: 'Compare',
                color: const Color(0xFFFF7043),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Compare feature coming soon!',
                      ),
                    ),
                  );
                },
              ),

              _buildFeatureCard(
                icon: Icons.chat,
                title: 'AI Chat',
                color: const Color(0xFF26A69A),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'AI Chat feature coming soon!',
                      ),
                    ),
                  );
                },
              ),

              _buildFeatureCard(
                icon: Icons.wb_sunny,
                title: 'Weather',
                color: const Color(0xFFFFCA28),
                onTap: () {
                  context.push('/weather');
                },
              ),

              _buildFeatureCard(
                icon: Icons.help_outline,
                title: 'Help',
                color: const Color(0xFF5C6BC0),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Help feature coming soon!',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FEATURE CARD
  // ===============================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
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
}