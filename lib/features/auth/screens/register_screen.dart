import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join ${AppCredentials.appName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up with your email to start your secure messaging and spiritual growth journey.',
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 28),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGold),
                  labelText: 'Email Address',
                  hintText: 'e.g. name@example.com',
                ),
              ),
              const SizedBox(height: 18),

              // Password Input
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
                  hintText: 'Minimum 6 characters',
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password Input
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_reset, color: AppTheme.primaryGold),
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                      )
                    : const Text('Register & Verify Email'),
              ),
              const SizedBox(height: 20),

              // Developer Credentials Quote
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '"${AppCredentials.spiritualMotto}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryGold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '- ${AppCredentials.leadDeveloper} (${AppCredentials.tagline})',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
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
