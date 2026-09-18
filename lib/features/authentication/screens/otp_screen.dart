import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

/// OTP (Email Verification) screen for Crop Analyzer app.
/// Displays verification message, checks verification status periodically,
/// allows manual verification check, and supports resend email with cooldown.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _verificationTimer;
  Timer? _resendCooldownTimer;
  bool _isLoading = false;
  bool _canResend = false;
  int _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    _startResendCooldown();
  }

  /// Starts periodic verification check every 3 seconds.
  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerificationStatus(autoCheck: true);
    });
  }

  /// Starts 60-second cooldown for resend button.
  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendSeconds = 60;
    });
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  /// Checks if the user's email is verified.
  Future<void> _checkVerificationStatus({bool autoCheck = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser != null && refreshedUser.emailVerified) {
        _verificationTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/dashboard');
        }
      } else if (!autoCheck && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Resends verification email with cooldown.
  Future<void> _resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _startResendCooldown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: AppColors.primary),
            const SizedBox(height: 30),
            Text(
              'A verification email has been sent to:',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please verify your email to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),

            // Check Verification Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.verified, color: Colors.white),
                label: const Text(
                  'Check Verification Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () => _checkVerificationStatus(autoCheck: false),
              ),
            ),
            const SizedBox(height: 20),

            // Resend Email Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _canResend ? AppColors.primary : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  _canResend
                      ? 'Resend Verification Email'
                      : 'Resend in ${_resendSeconds}s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: _canResend && !_isLoading
                    ? _resendVerificationEmail
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            // Go Back to Login
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Go back to Login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}