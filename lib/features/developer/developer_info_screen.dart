import 'package:flutter/material.dart';
import '../../core/constants/app_credentials.dart';
import '../../core/theme/app_theme.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Credentials')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.darkCard,
                  border: Border.all(color: AppTheme.primaryGold, width: 2.5),
                ),
                child: const Icon(Icons.verified, size: 55, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 20),
              Text(
                AppCredentials.appName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
              const SizedBox(height: 6),
              Text(
                AppCredentials.appVersion,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Developer 1 Card
              _buildDeveloperCard(
                name: AppCredentials.leadDeveloper,
                role: 'Lead Architect & Creator',
                icon: Icons.person_pin,
              ),
              const SizedBox(height: 14),

              // Developer 2 Card
              _buildDeveloperCard(
                name: AppCredentials.coDeveloper,
                role: 'Co-Architect & Spiritual Visionary',
                icon: Icons.shield,
              ),
              const SizedBox(height: 24),

              // Mottos & Creed Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.format_quote, size: 36, color: AppTheme.primaryGold),
                    const SizedBox(height: 8),
                    Text(
                      '"${AppCredentials.tagline}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppCredentials.motto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Text(
                      '"${AppCredentials.spiritualMotto}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.cyanAccent,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  AppCredentials.aboutDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({required String name, required String role, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.darkSurface,
            child: Icon(icon, color: AppTheme.primaryGold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryGold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
