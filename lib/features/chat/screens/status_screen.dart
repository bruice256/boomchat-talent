import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../services/chat_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final ChatService _chatService = ChatService();

  void _addTextStatusDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('New Spiritual Status / Story'),
        content: TextField(
          controller: textController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Share a scripture or what God is doing today...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              await _chatService.postStatusStory(text: text, type: 'text');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status updated successfully!')),
                );
              }
            },
            child: const Text('Post Status'),
          ),
        ],
      ),
    );
  }

  void _addImageStatus() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      await _chatService.postStatusStory(
        text: 'Shared a blessed moment',
        mediaFile: file,
        type: 'image',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo status posted!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // My Status ListTile
          ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.darkCard,
                  child: const Icon(Icons.person, color: AppTheme.primaryGold),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppTheme.primaryGold,
                    child: const Icon(Icons.add, size: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Tap to add a 24h status update', style: TextStyle(color: AppTheme.textMuted)),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.darkSurface,
                builder: (ctx) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: AppTheme.primaryGold),
                        title: const Text('Text Status / Scripture'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _addTextStatusDialog();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_camera, color: Colors.purpleAccent),
                        title: const Text('Photo Status'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _addImageStatus();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'RECENT UPDATES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
          ),
          StreamBuilder<List<UserStatusStory>>(
            stream: _chatService.getActiveStatusesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              final statuses = snapshot.data ?? [];
              if (statuses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No recent statuses yet.\nBe the first to share an encouraging word or prayer!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statuses.length,
                itemBuilder: (ctx, idx) {
                  final status = statuses[idx];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryGold, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.darkCard,
                        child: const Icon(Icons.person, color: AppTheme.primaryGold),
                      ),
                    ),
                    title: Text(status.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${status.createdAt.hour.toString().padLeft(2, '0')}:${status.createdAt.minute.toString().padLeft(2, '0')} • ${status.content}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    onTap: () {
                      _showStatusViewDialog(status);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showStatusViewDialog(UserStatusStory status) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status.userName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 16),
              if (status.mediaUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    status.mediaUrl!,
                    fit: BoxFit.cover,
                    height: 220,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                status.content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
