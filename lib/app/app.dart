import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';

// Providers
import '../providers/analysis_provider.dart';
import '../providers/gallery_provider.dart';

// Theme
import 'theme/app_colors.dart';

// ONLY import the screens that exist
import '../features/authentication/screens/login_screen.dart';

/// Entry point of the Crop Analyzer app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: const CropAnalyzerApp(),
    ),
  );
}

/// Root widget of the Crop Analyzer app.
class CropAnalyzerApp extends StatelessWidget {
  const CropAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final location = state.matchedLocation;

        final isOnSplash = location == '/splash';
        final isOnAuth = location == '/login' ||
            location == '/register' ||
            location == '/forgot-password';

        debugPrint('🔄 Router redirect check:');
        debugPrint('   Current location: $location');
        debugPrint('   User: ${user?.email ?? "None"}');

        // Don't redirect if on splash screen
        if (isOnSplash) {
          debugPrint('   ✅ On splash, no redirect');
          return null;
        }

        // If user is null and not on auth screens, go to login
        if (user == null && !isOnAuth) {
          debugPrint('   ➡️ Redirecting to /login');
          return '/login';
        }

        // If user exists and on auth screens, go to home
        if (user != null && isOnAuth) {
          debugPrint('   ➡️ Redirecting to /home');
          return '/home';
        }

        debugPrint('   ✅ No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/quadrat',
          builder: (context, state) => const QuadratScreen(),
        ),
        GoRoute(
          path: '/loading',
          builder: (context, state) => const LoadingScreen(),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ResultScreen(extra: extra);
          },
        ),
        GoRoute(
          path: '/comparison',
          builder: (context, state) => const ComparisonScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/pdf-preview',
          builder: (context, state) {
            final reportData = (state.extra as Map<String, dynamic>?) ?? {};
            return PdfPreviewScreen(reportData: reportData);
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
        GoRoute(
          path: '/weather',
          builder: (context, state) => const WeatherScreen(),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Crop Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontFamily: 'Poppins',
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: AppColors.primary,
        ),
      ),
      routerConfig: router,
    );
  }
}

// ============================================================================
// PLACEHOLDER SCREENS - Replace these with your actual screens later
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    debugPrint('🔍 Splash: User = ${user?.email ?? "None"}');

    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Crop Analyzer',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Text('Register Screen - Under Development'),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(
        child: Text('Forgot Password Screen - Under Development'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.agriculture, size: 100, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Crop Analyzer!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Logged in as: ${user?.email ?? "Unknown"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/quadrat'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Analysis'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person),
                label: const Text('View Profile'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/history'),
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuadratScreen extends StatelessWidget {
  const QuadratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quadrat Analysis')),
      body: const Center(child: Text('Quadrat Screen - Under Development')),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? extra;
  const ResultScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(child: Text('Result Screen - Data: $extra')),
    );
  }
}

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparison')),
      body: const Center(child: Text('Comparison Screen - Under Development')),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(child: Text('Reports Screen - Under Development')),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;
  const PdfPreviewScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: Center(child: Text('PDF Preview - Data: $reportData')),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(child: Text('History Screen - Under Development')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen - Under Development')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen - Under Development')),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: const Center(child: Text('Change Password - Under Development')),
    );
  }
}

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: const Center(child: Text('Chatbot Screen - Under Development')),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: const Center(child: Text('Weather Screen - Under Development')),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Center(child: Text('Help Screen - Under Development')),
    );
  }
}