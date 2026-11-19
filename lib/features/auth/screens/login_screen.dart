import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'email_verification_screen.dart';
import 'profile_setup_screen.dart';
import '../../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = await _authService.signInWithEmail(email: email, password: password);
      final user = cred.user;

      if (user != null && !user.emailVerified) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
        return;
      }

      if (user != null) {
        final profile = await _authService.getUserProfile(user.uid);
        if (!mounted) return;
        if (profile == null || !profile.isProfileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo and Credentials
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGold, width: 2),
                    ),
                    child: const Icon(Icons.church_rounded, size: 48, color: AppTheme.primaryGold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppCredentials.appName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppCredentials.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primaryGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppCredentials.spiritualMotto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 36),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGold),
                    labelText: 'Email Address',
                    hintText: 'Enter your registered email',
                  ),
                ),
                const SizedBox(height: 18),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGold),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 28),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Text('Sign In to BoomChat'),
                ),
                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: AppTheme.textMuted)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Developer Footnote
                Center(
                  child: Text(
                    'Developer: ${AppCredentials.leadDeveloper} & ${AppCredentials.coDeveloper}\n${AppCredentials.motto}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
