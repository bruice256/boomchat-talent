import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../../developer/developer_info_screen.dart';

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Developer Profile Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.darkCard,
              child: const Icon(Icons.person, size: 36, color: AppTheme.primaryGold),
            ),
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text(AppCredentials.spiritualMotto, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            trailing: const Icon(Icons.qr_code, color: AppTheme.primaryGold),
          ),
          const Divider(color: Colors.white12),

          ListTile(
            leading: const Icon(Icons.key, color: AppTheme.primaryGold),
            title: const Text('Account & Security'),
            subtitle: const Text('Security notifications, change number, delete account', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryGold),
            title: const Text('Privacy'),
            subtitle: const Text('Block contacts, disappearing messages, read receipts', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: AppTheme.primaryGold),
            title: const Text('Chats'),
            subtitle: const Text('Theme, wallpapers, chat history, font size', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppTheme.primaryGold),
            title: const Text('Notifications'),
            subtitle: const Text('Message tones, group tones, call alerts', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.data_usage, color: AppTheme.primaryGold),
            title: const Text('Storage and Data'),
            subtitle: const Text('Network usage, auto-download settings for media', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.primaryGold),
            title: const Text('Help & App Info'),
            subtitle: const Text('Help center, contact us, privacy policy', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            onTap: () {},
          ),
          const Divider(color: Colors.white12),

          // Developer & Spiritual Calling section
          ListTile(
            leading: const Icon(Icons.verified, color: Colors.amber),
            title: const Text('Developer Credentials', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
            subtitle: const Text('${AppCredentials.leadDeveloper} • ${AppCredentials.coDeveloper}', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeveloperInfoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
