import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../../../main.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _mottoController = TextEditingController(text: AppCredentials.spiritualMotto);
  final _authService = AuthService();
  bool _isLoading = false;

  void _completeSetup() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final motto = _mottoController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name or display name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.setupUserProfile(
        displayName: name,
        bio: bio.isNotEmpty ? bio : 'Growing in Christ and connecting in love.',
        spiritualMotto: motto.isNotEmpty ? motto : AppCredentials.spiritualMotto,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile setup failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.darkCard,
                      child: const Icon(Icons.person, size: 55, color: AppTheme.primaryGold),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryGold,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar image picker ready for cloud upload.')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Welcome to BoomChat Talent! Set up your identity to connect with brethren, explore files, and access spiritual resources.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 32),

              // Full Name / Display Name
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryGold),
                  labelText: 'Display Name / Full Name *',
                  hintText: 'e.g. Talent Bruice',
                ),
              ),
              const SizedBox(height: 18),

              // Bio
              TextField(
                controller: _bioController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.info_outline, color: AppTheme.primaryGold),
                  labelText: 'Bio & Calling',
                  hintText: 'Share a brief intro about yourself and your faith...',
                ),
              ),
              const SizedBox(height: 18),

              // Spiritual Motto
              TextField(
                controller: _mottoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.format_quote, color: AppTheme.primaryGold),
                  labelText: 'Spiritual Motto / Guiding Scripture',
                ),
              ),
              const SizedBox(height: 36),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _completeSetup,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                      )
                    : const Text('Enter BoomChat Talent'),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  '${AppCredentials.appName}\n${AppCredentials.spiritualMotto}\n${AppCredentials.motto}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
