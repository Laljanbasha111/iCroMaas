import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ Import only screens that exist in your project
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/analysis/screens/analysis_loading_screen.dart';
import '../../features/analysis/screens/result_screen.dart';
import '../../features/drone/screens/drone_control_screen.dart';
import '../../features/quadrat/screens/quadrat_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/chatbot/screens/chatbot_screen.dart';

/// ✅ Production-ready router with real analysis loading and result flow.
class AppRouter {
  // Route Names
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot_password';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String analysisLoading = 'analysis_loading';
  static const String result = 'result';
  static const String droneControl = 'drone_control';
  static const String quadrat = 'quadrat';
  static const String reports = 'reports';
  static const String history = 'history';
  static const String weather = 'weather';
  static const String chatbot = 'chatbot';

  // Route Paths
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String homePath = '/home';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';
  static const String analysisLoadingPath = '/analysis-loading';
  static const String resultPath = '/result';
  static const String droneControlPath = '/drone';
  static const String quadratPath = '/quadrat';
  static const String reportsPath = '/reports';
  static const String historyPath = '/history';
  static const String weatherPath = '/weather';
  static const String chatbotPath = '/chatbot';

  // ============================================================
  // ROUTER CONFIGURATION
  // ============================================================

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: true,
    routes: [
      // ========================================================
      // AUTHENTICATION ROUTES
      // ========================================================
      GoRoute(
        name: splash,
        path: splashPath,
        pageBuilder: (context, state) => _buildPage(const SplashScreen()),
      ),
      GoRoute(
        name: onboarding,
        path: onboardingPath,
        pageBuilder: (context, state) =>
            _buildPage(const OnboardingScreen()),
      ),
      GoRoute(
        name: login,
        path: loginPath,
        pageBuilder: (context, state) => _buildPage(const LoginScreen()),
      ),
      GoRoute(
        name: register,
        path: registerPath,
        pageBuilder: (context, state) => _buildPage(const RegisterScreen()),
      ),
      GoRoute(
        name: forgotPassword,
        path: forgotPasswordPath,
        pageBuilder: (context, state) =>
            _buildPage(const ForgotPasswordScreen()),
      ),

      // ========================================================
      // MAIN APP ROUTES
      // ========================================================
      GoRoute(
        name: home,
        path: homePath,
        pageBuilder: (context, state) => _buildPage(const HomeScreen()),
      ),
      GoRoute(
        name: profile,
        path: profilePath,
        pageBuilder: (context, state) => _buildPage(const ProfileScreen()),
      ),
      GoRoute(
        name: settings,
        path: settingsPath,
        pageBuilder: (context, state) => _buildPage(const SettingsScreen()),
      ),

      // ========================================================
      // ANALYSIS ROUTES
      // ========================================================
      GoRoute(
        name: analysisLoading,
        path: analysisLoadingPath,
        pageBuilder: (context, state) {
          final String imagePath = _extractImagePath(state.extra);

          if (imagePath.isEmpty) {
            debugPrint('⚠️ ROUTER: Missing image path for analysis');
            return _buildPage(const MissingImagePathScreen());
          }

          return _buildPage(
            AnalysisLoadingScreen(imagePath: imagePath),
          );
        },
      ),

      GoRoute(
        name: result,
        path: resultPath,
        pageBuilder: (context, state) {
          final Map<String, dynamic> extra =
          _extractMap(state.extra);

          debugPrint('🔍 ROUTER: Navigating to result screen');
          debugPrint('   Data: $extra');

          return _buildPage(
            ResultScreen(extra: extra),
          );
        },
      ),

      // ========================================================
      // FEATURE ROUTES
      // ========================================================
      GoRoute(
        name: quadrat,
        path: quadratPath,
        pageBuilder: (context, state) => _buildPage(const QuadratScreen()),
      ),
      GoRoute(
        name: droneControl,
        path: droneControlPath,
        pageBuilder: (context, state) =>
            _buildPage(const DroneControlScreen()),
      ),
      GoRoute(
        name: reports,
        path: reportsPath,
        pageBuilder: (context, state) => _buildPage(const ReportsScreen()),
      ),
      GoRoute(
        name: history,
        path: historyPath,
        pageBuilder: (context, state) => _buildPage(const HistoryScreen()),
      ),
      GoRoute(
        name: weather,
        path: weatherPath,
        pageBuilder: (context, state) => _buildPage(const WeatherScreen()),
      ),
      GoRoute(
        name: chatbot,
        path: chatbotPath,
        pageBuilder: (context, state) => _buildPage(const ChatbotScreen()),
      ),
    ],

    // ============================================================
    // ERROR HANDLING
    // ============================================================
    errorBuilder: (context, state) {
      debugPrint('❌ ROUTER ERROR: ${state.error}');
      return ErrorPage(error: state.error?.toString() ?? 'Unknown error');
    },

    // ============================================================
    // AUTHENTICATION REDIRECT
    // ============================================================
    redirect: (context, state) {
      final bool isLoggedIn = _isAuthenticated();
      final String location = state.matchedLocation;

      debugPrint('🔍 ROUTER: Checking auth for $location');
      debugPrint('   Logged in: $isLoggedIn');

      // Always allow splash.
      if (location == splashPath) return null;

      const List<String> publicRoutes = <String>[
        loginPath,
        registerPath,
        onboardingPath,
        forgotPasswordPath,
      ];

      if (!isLoggedIn && !publicRoutes.contains(location)) {
        debugPrint('⚠️ ROUTER: Redirecting to login');
        return loginPath;
      }

      if (isLoggedIn && publicRoutes.contains(location)) {
        debugPrint('⚠️ ROUTER: Redirecting to home');
        return homePath;
      }

      return null;
    },
  );

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static bool _isAuthenticated() {
    try {
      if (Firebase.apps.isEmpty) {
        return false;
      }
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static CustomTransitionPage<void> _buildPage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Map<String, dynamic> _extractMap(Object? extra) {
    if (extra is Map<String, dynamic>) return extra;

    if (extra is Map) {
      return extra.map(
            (key, value) => MapEntry<String, dynamic>(
          key.toString(),
          value,
        ),
      );
    }

    return <String, dynamic>{};
  }

  static String _extractImagePath(Object? extra) {
    if (extra is String) {
      return extra.trim();
    }

    final Map<String, dynamic> data = _extractMap(extra);
    final Object? value = data['imagePath'] ??
        data['path'] ??
        data['filePath'] ??
        data['image'];

    return value?.toString().trim() ?? '';
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

  /// Navigate to result screen with analysis data.
  static void navigateToResult(
      BuildContext context, {
        required String imagePath,
        required String cropType,
        required double nitrogen,
        required double biomass,
        required double confidence,
      }) {
    debugPrint('🚀 ROUTER: Navigating to result with data:');
    debugPrint('   Crop: $cropType');
    debugPrint('   Nitrogen: $nitrogen%');
    debugPrint('   Biomass: $biomass g/m²');
    debugPrint('   Confidence: $confidence%');

    context.go(
      resultPath,
      extra: <String, dynamic>{
        'imagePath': imagePath,
        'cropType': cropType,
        'cropName': cropType,
        'nitrogen': nitrogen,
        'predictedNitrogen': nitrogen,
        'biomass': biomass,
        'predictedBiomass': biomass,
        'confidence': confidence,
        'overallAccuracy': confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'prediction': <String, dynamic>{
          'cropName': cropType,
          'predictedNitrogen': nitrogen,
          'predictedBiomass': biomass,
          'confidence': confidence,
        },
      },
    );
  }

  static void navigateToAnalysisLoading(
      BuildContext context,
      String imagePath,
      ) {
    debugPrint('🚀 ROUTER: Navigating to analysis loading');
    context.go(
      analysisLoadingPath,
      extra: imagePath,
    );
  }

  static void navigateToHome(BuildContext context) {
    debugPrint('🚀 ROUTER: Navigating to home');
    context.go(homePath);
  }

  static void navigateToLogin(BuildContext context) {
    debugPrint('🚀 ROUTER: Navigating to login');
    context.go(loginPath);
  }

  static Future<void> logout(BuildContext context) async {
    debugPrint('🚪 ROUTER: Logging out');
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go(loginPath);
    }
  }
}

// ============================================================
// ERROR PAGE
// ============================================================

class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.homePath),
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go(AppRouter.homePath);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MISSING IMAGE PATH SCREEN
// ============================================================

class MissingImagePathScreen extends StatelessWidget {
  const MissingImagePathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Missing Image Path',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please select an image before starting analysis.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRouter.quadratPath),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Go to Quadrat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}