import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'profile_setup_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isEmailVerified = _authService.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      // Periodically check email verification status every 3 seconds
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final verified = await _authService.checkEmailVerified();
    if (verified) {
      _timer?.cancel();
      if (!mounted) return;
      setState(() => _isEmailVerified = true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      setState(() => _canResendEmail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification link sent! Please check your inbox.')),
      );
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) setState(() => _canResendEmail = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authService.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _timer?.cancel();
              await _authService.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppTheme.primaryGold),
              const SizedBox(height: 24),
              const Text(
                'Verify Email Address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A verification link has been sent to:\n$userEmail\n\nPlease check your inbox and click the link to activate your account.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Manual Check Button
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('I Have Verified My Email'),
                onPressed: _checkEmailVerified,
              ),
              const SizedBox(height: 16),

              // Resend Email Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGold,
                  side: const BorderSide(color: AppTheme.primaryGold),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Resend Verification Email'),
                onPressed: _canResendEmail ? _resendVerificationEmail : null,
              ),
              const SizedBox(height: 32),

              Center(
                child: Text(
                  '${AppCredentials.appName}\n${AppCredentials.tagline}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
