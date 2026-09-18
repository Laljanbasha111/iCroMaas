import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app/theme/app_theme.dart';
import 'core/services/gemini_service.dart';
import 'firebase_options.dart';
import 'providers/analysis_provider.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/chatbot_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/history_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';

import 'features/authentication/screens/change_password_screen.dart';
import 'features/authentication/screens/forgot_password_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/register_screen.dart';
import 'features/analysis/screens/analysis_loading_screen.dart';
import 'features/analysis/screens/comparison_screen.dart';
import 'features/analysis/screens/quadrat_screen.dart';
import 'features/analysis/screens/result_screen.dart';
import 'features/chatbot/screens/chatbot_screen.dart';
import 'features/drone/screens/drone_control_screen.dart';
import 'features/drone/screens/drone_image_crop_screen.dart';
import 'features/help/screens/help_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/reports/screens/pdf_preview_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/weather/screens/weather_screen.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);

        AppLogger.error(
          'Flutter error',
          details.exception,
          details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (
          Object error,
          StackTrace stack,
          ) {
        AppLogger.error(
          'Platform error',
          error,
          stack,
        );

        return true;
      };

      final bool envReady = await _loadEnvironment();

      final bool firebaseReady = await _initializeFirebase();

      final bool geminiReady =
      envReady ? _initializeGemini() : false;

      runApp(
        CropAnalyzerApp(
          firebaseReady: firebaseReady,
          geminiReady: geminiReady,
        ),
      );
    },
        (
        Object error,
        StackTrace stack,
        ) {
      AppLogger.error(
        'Uncaught app error',
        error,
        stack,
      );
    },
  );
}

// ===============================================================
// ENVIRONMENT
// ===============================================================

Future<bool> _loadEnvironment() async {
  try {
    await dotenv.load(
      fileName: '.env',
    );

    AppLogger.info(
      '.env file loaded successfully',
    );

    _verifyEnvKey(
      'GEMINI_API_KEY',
      'Gemini API key',
    );

    _verifyEnvKey(
      'WEATHER_API_KEY',
      'Weather API key',
    );

    return true;
  } catch (error, stack) {
    AppLogger.error(
      'Failed to load .env file',
      error,
      stack,
    );

    return false;
  }
}

void _verifyEnvKey(
    String key,
    String label,
    ) {
  final String value =
      dotenv.env[key]?.trim() ?? '';

  if (value.isEmpty) {
    AppLogger.warning(
      '$label missing in .env',
    );

    return;
  }

  AppLogger.info(
    '$label found: ${_maskSecret(value)}',
  );
}

// ===============================================================
// FIREBASE
// ===============================================================

Future<bool> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    AppLogger.info(
      'Firebase initialized successfully',
    );

    return true;
  } catch (error, stack) {
    AppLogger.error(
      'Firebase initialization failed',
      error,
      stack,
    );

    return false;
  }
}

// ===============================================================
// GEMINI
// ===============================================================

bool _initializeGemini() {
  try {
    if (!GeminiService.isConfigured) {
      AppLogger.warning(
        'Gemini API key missing; AI assistant disabled',
      );

      return false;
    }

    GeminiService.instance;

    AppLogger.info(
      'Gemini AI initialized successfully',
    );

    return true;
  } catch (error, stack) {
    AppLogger.error(
      'Gemini initialization failed',
      error,
      stack,
    );

    return false;
  }
}

// ===============================================================
// HELPERS
// ===============================================================

String _maskSecret(
    String value,
    ) {
  final String clean = value.trim();

  if (clean.isEmpty) {
    return 'empty';
  }

  if (clean.length <= 8) {
    return '****';
  }

  if (clean.length <= 14) {
    return '${clean.substring(0, 4)}...'
        '${clean.substring(clean.length - 2)}';
  }

  return '${clean.substring(0, 12)}...'
      '${clean.substring(clean.length - 4)}';
}

BoxDecoration _cardDecoration(
    double borderRadius,
    ) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(
      borderRadius,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: 0.05,
        ),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ===============================================================
// LOGGER
// ===============================================================

class AppLogger {
  const AppLogger._();

  static void info(
      String message,
      ) {
    if (kDebugMode) {
      debugPrint(
        '✅ $message',
      );
    }
  }

  static void warning(
      String message,
      ) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ $message',
      );
    }
  }

  static void error(
      String message, [
        Object? error,
        StackTrace? stackTrace,
      ]) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '❌ $message',
    );

    if (error != null) {
      debugPrint(
        'Error: $error',
      );
    }

    if (stackTrace != null) {
      debugPrint(
        'Stack trace: $stackTrace',
      );
    }
  }
}

// ===============================================================
// ROOT APP
// ===============================================================

class CropAnalyzerApp extends StatelessWidget {
  const CropAnalyzerApp({
    super.key,
    required this.firebaseReady,
    required this.geminiReady,
  });

  final bool firebaseReady;
  final bool geminiReady;

  @override
  Widget build(
      BuildContext context,
      ) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AppAuthProvider>(
          create: (_) => app_auth.AppAuthProvider(),
        ),
        ChangeNotifierProvider<AnalysisProvider>(
          create: (_) => AnalysisProvider(),
        ),
        ChangeNotifierProvider<GalleryProvider>(
          create: (_) => GalleryProvider(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(),
        ),
        ChangeNotifierProvider<ChatbotProvider>(
          create: (_) => ChatbotProvider(),
        ),
      ],
      child: MyApp(
        firebaseReady: firebaseReady,
        geminiReady: geminiReady,
      ),
    );
  }
}

// ===============================================================
// MATERIAL APP
// ===============================================================

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.firebaseReady,
    required this.geminiReady,
  });

  final bool firebaseReady;
  final bool geminiReady;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = _createRouter(
    firebaseReady: widget.firebaseReady,
    geminiReady: widget.geminiReady,
  );

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp.router(
      title: 'CropAnalyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      routerConfig: _router,
    );
  }
}

// ===============================================================
// ROUTER
// ===============================================================

GoRouter _createRouter({
  required bool firebaseReady,
  required bool geminiReady,
}) {
  return GoRouter(
    initialLocation: AppRoute.authCheck.path,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoute.authCheck.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return AuthCheckScreen(
            firebaseReady: firebaseReady,
          );
        },
      ),
      GoRoute(
        path: AppRoute.login.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoute.register.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoute.signup.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoute.home.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return EnhancedHomeScreen(
            geminiReady: geminiReady,
          );
        },
      ),
      GoRoute(
        path: AppRoute.quadrat.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const QuadratScreen();
        },
      ),
      GoRoute(
        path: AppRoute.loading.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          final String imagePath =
          RouteExtraParser.imagePath(
            state.extra,
          );

          if (imagePath.isEmpty) {
            scheduleMicrotask(() {
              if (context.mounted) {
                context.go(
                  AppRoute.quadrat.path,
                );
              }
            });

            return const MissingImagePathScreen();
          }

          return AnalysisLoadingScreen(
            imagePath: imagePath,
          );
        },
      ),
      GoRoute(
        path: AppRoute.result.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          final Map<String, dynamic> extra =
          RouteExtraParser.map(
            state.extra,
          );

          return ResultScreen(
            extra: extra,
          );
        },
      ),
      GoRoute(
        path: AppRoute.comparison.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ComparisonScreen();
        },
      ),
      GoRoute(
        path: AppRoute.reports.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ReportsScreen();
        },
      ),
      GoRoute(
        path: AppRoute.pdfPreview.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return PdfPreviewScreen(
            reportData: RouteExtraParser.map(
              state.extra,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoute.history.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const HistoryScreen();
        },
      ),
      GoRoute(
        path: AppRoute.profile.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoute.settings.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoute.changePassword.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ChangePasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoute.chatbot.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const ChatbotScreen();
        },
      ),
      GoRoute(
        path: AppRoute.weather.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const WeatherScreen();
        },
      ),
      GoRoute(
        path: AppRoute.help.path,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const HelpScreen();
        },
      ),
      GoRoute(
        path: AppRoute.drone.path,
        name: AppRoute.drone.name,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          return const DroneControlScreen();
        },
      ),
      GoRoute(
        path: AppRoute.droneCrop.path,
        name: AppRoute.droneCrop.name,
        builder: (
            BuildContext context,
            GoRouterState state,
            ) {
          final String imagePath =
          RouteExtraParser.imagePath(
            state.extra,
          );

          if (imagePath.isEmpty) {
            return const MissingImagePathScreen();
          }

          return DroneImageCropScreen(
            imagePath: imagePath,
          );
        },
      ),
    ],
    errorBuilder: (
        BuildContext context,
        GoRouterState state,
        ) {
      return RouteErrorScreen(
        matchedLocation: state.matchedLocation,
      );
    },
  );
}

// ===============================================================
// ROUTES
// ===============================================================

enum AppRoute {
  authCheck('/auth-check'),
  login('/login'),
  register('/register'),
  signup('/signup'),
  forgotPassword('/forgot-password'),
  home('/home'),
  quadrat('/quadrat'),
  loading('/loading'),
  result('/result'),
  comparison('/comparison'),
  reports('/reports'),
  pdfPreview('/pdf-preview'),
  history('/history'),
  profile('/profile'),
  settings('/settings'),
  changePassword('/change-password'),
  chatbot('/chatbot'),
  weather('/weather'),
  help('/help'),
  drone('/drone'),
  droneCrop('/drone-crop');

  const AppRoute(
      this.path,
      );

  final String path;
}

// ===============================================================
// ROUTE EXTRA PARSER
// ===============================================================

class RouteExtraParser {
  const RouteExtraParser._();

  static Map<String, dynamic> map(
      Object? extra,
      ) {
    if (extra is Map<String, dynamic>) {
      return extra;
    }

    if (extra is Map) {
      return extra.map(
            (
            key,
            value,
            ) {
          return MapEntry<String, dynamic>(
            key.toString(),
            value,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  static String imagePath(
      Object? extra,
      ) {
    if (extra is String) {
      return extra.trim();
    }

    final Map<String, dynamic> data =
    map(extra);

    final Object? value =
        data['imagePath'] ??
            data['path'] ??
            data['filePath'] ??
            data['image'];

    return value?.toString().trim() ?? '';
  }
}

// ===============================================================
// AUTH CHECK SCREEN
// ===============================================================

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({
    super.key,
    required this.firebaseReady,
  });

  final bool firebaseReady;

  @override
  State<AuthCheckScreen> createState() =>
      _AuthCheckScreenState();
}

class _AuthCheckScreenState
    extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 800,
      ),
    );

    if (!mounted) {
      return;
    }

    if (!widget.firebaseReady ||
        Firebase.apps.isEmpty) {
      setState(() {});

      return;
    }

    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (!mounted) {
        return;
      }

      if (user != null) {
        context.go(
          AppRoute.home.path,
        );
      } else {
        context.go(
          AppRoute.login.path,
        );
      }
    } catch (error, stack) {
      AppLogger.error(
        'Auth check failed',
        error,
        stack,
      );

      if (!mounted) {
        return;
      }

      context.go(
        AppRoute.login.path,
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (!widget.firebaseReady ||
        Firebase.apps.isEmpty) {
      return const BootstrapErrorScreen();
    }

    return const SplashScreen();
  }
}

// ===============================================================
// SPLASH SCREEN
// ===============================================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
              Color(0xFF81C784),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: 1,
                ),
                duration: const Duration(
                  milliseconds: 600,
                ),
                curve: Curves.easeOutBack,
                builder: (
                    BuildContext context,
                    double value,
                    Widget? child,
                    ) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CropAnalyzer',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-Powered Crop Health Analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(
                    alpha: 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// BOOTSTRAP ERROR SCREEN
// ===============================================================

class BootstrapErrorScreen
    extends StatelessWidget {
  const BootstrapErrorScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Firebase Initialization Failed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'A valid Firebase configuration is required for app startup.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// MISSING IMAGE SCREEN
// ===============================================================

class MissingImagePathScreen
    extends StatelessWidget {
  const MissingImagePathScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Image Path Missing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Crop analysis requires a valid image file path.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// ROUTE ERROR SCREEN
// ===============================================================

class RouteErrorScreen
    extends StatelessWidget {
  const RouteErrorScreen({
    super.key,
    required this.matchedLocation,
  });

  final String matchedLocation;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Page Not Found',
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Route Not Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                matchedLocation.isEmpty
                    ? 'Requested page is unavailable.'
                    : 'Requested page is unavailable: '
                    '$matchedLocation',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.go(
                    AppRoute.home.path,
                  );
                },
                icon: const Icon(
                  Icons.home_outlined,
                ),
                label: const Text(
                  'Go to Home',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// HOME SCREEN
// ===============================================================

class EnhancedHomeScreen
    extends StatelessWidget {
  const EnhancedHomeScreen({
    super.key,
    required this.geminiReady,
  });

  final bool geminiReady;

  @override
  Widget build(
      BuildContext context,
      ) {
    final User? user = Firebase.apps.isNotEmpty
        ? FirebaseAuth.instance.currentUser
        : null;

    final String displayName =
    user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first.trim().isNotEmpty ==
        true
        ? user!.email!.split('@').first.trim()
        : 'User';

    final String avatarLetter =
    displayName.isEmpty
        ? 'U'
        : displayName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back! 👋',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Notifications',
                              icon: const Icon(
                                Icons.notifications_outlined,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No new notifications',
                                    ),
                                    behavior:
                                    SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              customBorder:
                              const CircleBorder(),
                              onTap: () {
                                context.push(
                                  AppRoute.profile.path,
                                );
                              },
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                const Color(0xFF2E7D32),
                                child: Text(
                                  avatarLetter,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: _cardDecoration(16),
                      child: TextField(
                        textInputAction:
                        TextInputAction.search,
                        decoration: InputDecoration(
                          hintText:
                          'Search crops, diseases...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.eco,
                            title: 'Analyses',
                            value: '24',
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle,
                            title: 'Healthy',
                            value: '18',
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.warning,
                            title: 'Issues',
                            value: '6',
                            color: Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    HomeActionCard(
                      icon: Icons.camera_alt,
                      title: 'Crop Analysis',
                      subtitle:
                      'Analyze crop images using API analysis',
                      colors: const [
                        Color(0xFF2E7D32),
                        Color(0xFF66BB6A),
                      ],
                      backgroundIcon: Icons.camera_alt,
                      onTap: () {
                        context.push(
                          AppRoute.quadrat.path,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    HomeActionCard(
                      icon: Icons.flight,
                      title: 'Drone Control 🚁',
                      subtitle:
                      'Aerial crop monitoring and field image capture',
                      colors: const [
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ],
                      backgroundIcon: Icons.flight,
                      onTap: () {
                        context.push(
                          AppRoute.drone.path,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    HomeActionCard(
                      icon: Icons.psychology,
                      title: geminiReady
                          ? 'Gemini AI Assistant'
                          : 'Gemini AI Assistant Offline',
                      subtitle: geminiReady
                          ? 'Agricultural advice, pest control, '
                          'disease guidance, and crop support'
                          : 'Gemini API configuration not available',
                      colors: geminiReady
                          ? const [
                        Color(0xFF00695C),
                        Color(0xFF26A69A),
                      ]
                          : const [
                        Color(0xFF757575),
                        Color(0xFF9E9E9E),
                      ],
                      backgroundIcon: Icons.psychology,
                      onTap: () {
                        context.push(
                          AppRoute.chatbot.path,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24,
              ),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate(
                  [
                    FeatureCard(
                      icon: Icons.history,
                      title: 'History',
                      color: Colors.blue,
                      onTap: () {
                        context.push(
                          AppRoute.history.path,
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.assessment,
                      title: 'Reports',
                      color: Colors.purple,
                      onTap: () {
                        context.push(
                          AppRoute.reports.path,
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.compare,
                      title: 'Compare',
                      color: Colors.orange,
                      onTap: () {
                        context.push(
                          AppRoute.comparison.path,
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.chat_bubble,
                      title: 'AI Chat',
                      color: Colors.teal,
                      onTap: () {
                        context.push(
                          AppRoute.chatbot.path,
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.wb_sunny,
                      title: 'Weather',
                      color: Colors.amber,
                      onTap: () {
                        context.push(
                          AppRoute.weather.path,
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.help,
                      title: 'Help',
                      color: Colors.indigo,
                      onTap: () {
                        context.push(
                          AppRoute.help.path,
                        );
                      },
                    ),
                  ],
                ),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// STAT CARD
// ===============================================================

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HOME ACTION CARD
// ===============================================================

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.backgroundIcon,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData backgroundIcon;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(
                  alpha: 0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  backgroundIcon,
                  size: 140,
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// FEATURE CARD
// ===============================================================

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(16),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}