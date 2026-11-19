import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/chat_service.dart';
import 'chat_room_screen.dart';
import 'status_screen.dart';
import 'calls_screen.dart';
import 'chat_settings_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({Key? key}) : super(key: key);

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startNewConversationDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Start New Chat', style: TextStyle(color: AppTheme.textLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the email address of the person you want to chat with:',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'User Email',
                prefixIcon: Icon(Icons.person_search, color: AppTheme.primaryGold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final targetEmail = emailController.text.trim();
              if (targetEmail.isEmpty) return;
              Navigator.pop(ctx);

              // Query user by email
              final userQuery = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: targetEmail)
                  .limit(1)
                  .get();

              if (!mounted) return;
              if (userQuery.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No user found with that email address.')),
                );
                return;
              }

              final targetUser = userQuery.docs.first;
              final targetUid = targetUser.id;
              final targetName = targetUser.data()['displayName'] ?? 'BoomChat User';
              final currentUid = _chatService.currentUserId;

              if (currentUid == null) return;

              // Conversation ID deterministically composed of both UIDs sorted
              final ids = [currentUid, targetUid]..sort();
              final convId = ids.join('_');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    conversationId: convId,
                    recipientId: targetUid,
                    recipientName: targetName,
                  ),
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppCredentials.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Chat Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatSettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. CHATS TAB
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _chatService.getConversationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                // Pure clean template state as requested
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_outline, size: 54, color: AppTheme.primaryGold),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Messages Yet',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a fresh template ready for your first conversations. Tap the button below to start messaging with fellow believers.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Start First Chat'),
                          onPressed: _startNewConversationDialog,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                itemBuilder: (ctx, idx) {
                  final data = docs[idx].data();
                  final convId = docs[idx].id;
                  final participants = List<String>.from(data['participants'] ?? []);
                  final currentUid = _chatService.currentUserId;
                  final otherUid = participants.firstWhere((id) => id != currentUid, orElse: () => '');
                  final lastMessage = data['lastMessage'] ?? '';
                  final lastMessageTime = data['lastMessageTime'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.darkCard,
                      child: const Icon(Icons.person, color: AppTheme.primaryGold),
                    ),
                    title: Text(
                      'User ($otherUid)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    trailing: Text(
                      lastMessageTime.isNotEmpty
                          ? lastMessageTime.substring(11, 16)
                          : '',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: convId,
                            recipientId: otherUid,
                            recipientName: 'User',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          // 2. STATUS TAB
          const StatusScreen(),

          // 3. CALLS TAB
          const CallsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.chat, color: Colors.black),
        onPressed: _startNewConversationDialog,
      ),
    );
  }
}
