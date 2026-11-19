import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_credentials.dart';
import 'core/permissions/permission_handler_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/chat/screens/chats_list_screen.dart';
import 'features/file_explorer/screens/file_explorer_screen.dart';
import 'features/spiritual/screens/spiritual_hub_screen.dart';
import 'features/developer/developer_info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (safely wrapped so template works immediately)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Request all necessary Android phone permissions
  try {
    await PermissionHandlerService.requestAllAppPermissions();
  } catch (e) {
    debugPrint('Permissions request note: $e');
  }

  runApp(const BoomChatTalentApp());
}

class BoomChatTalentApp extends StatelessWidget {
  const BoomChatTalentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppCredentials.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    if (!user.emailVerified) {
      return const EmailVerificationScreen();
    }

    return FutureBuilder(
      future: AuthService().getUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null || !profile.isProfileComplete) {
          return const ProfileSetupScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatsListScreen(),
    FileExplorerScreen(),
    SpiritualHubScreen(),
    DeveloperInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'BoomChat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            activeIcon: Icon(Icons.folder),
            label: 'Storage & Viewer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories),
            label: 'Spiritual Hub',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified),
            label: 'Credentials',
          ),
        ],
      ),
    );
  }
}
