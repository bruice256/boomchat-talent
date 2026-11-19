import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class SpiritualVideosScreen extends StatefulWidget {
  const SpiritualVideosScreen({Key? key}) : super(key: key);

  @override
  State<SpiritualVideosScreen> createState() => _SpiritualVideosScreenState();
}

class _SpiritualVideosScreenState extends State<SpiritualVideosScreen> {
  final SpiritualService _spiritualService = SpiritualService();

  void _uploadSpiritualVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final titleController = TextEditingController();
    final descController = TextEditingController();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Spiritual Growth Video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Teaching / Sermon Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Description & Scripture Outline'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uploading full-length video...')),
                );

                await _spiritualService.uploadSpiritualVideo(
                  title: title,
                  description: desc,
                  videoFile: File(picked.path),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spiritual Video uploaded!')),
                  );
                }
              },
              child: const Text('Publish Video'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Growth Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _uploadSpiritualVideo,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getSpiritualVideosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppTheme.darkCard, shape: BoxShape.circle),
                      child: const Icon(Icons.ondemand_video, size: 50, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Spiritual Videos Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload expository sermons, Bible teachings, and discipleship videos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Spiritual Video'),
                      onPressed: _uploadSpiritualVideo,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, idx) {
              final data = docs[idx].data();
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(Icons.play_circle_filled, size: 64, color: AppTheme.primaryGold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Speaker: ${data['uploaderName'] ?? 'Teacher'}', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(data['description'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
