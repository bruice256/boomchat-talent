import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class DailyDevotionalScreen extends StatefulWidget {
  const DailyDevotionalScreen({Key? key}) : super(key: key);

  @override
  State<DailyDevotionalScreen> createState() => _DailyDevotionalScreenState();
}

class _DailyDevotionalScreenState extends State<DailyDevotionalScreen> {
  final SpiritualService _spiritualService = SpiritualService();

  void _uploadDevotionalDialog() {
    final titleController = TextEditingController();
    final refController = TextEditingController();
    final bodyController = TextEditingController();
    final prayerController = TextEditingController();

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Publish Guided Daily Devotional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Devotional Title', hintText: 'e.g. Walking in Unfailing Grace'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Scripture of the Day', hintText: 'e.g. 2 Corinthians 12:9'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Devotional Message & Application',
                  hintText: 'Share the guided reflection and message for today...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prayerController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prayer Points & Declaration',
                  hintText: 'Today’s closing prayer and blessing...',
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final ref = refController.text.trim();
                  final body = bodyController.text.trim();
                  final prayer = prayerController.text.trim();

                  if (title.isEmpty || ref.isEmpty || body.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please complete all required fields.')),
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  await _spiritualService.uploadDailyDevotional(
                    title: title,
                    scriptureRef: ref,
                    devotionalBody: body,
                    prayerPoints: prayer,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily Devotional Published!')),
                    );
                  }
                },
                child: const Text('Publish Devotional'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Daily Devotionals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Publish Devotional',
            onPressed: _uploadDevotionalDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getDailyDevotionalsStream(),
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
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(color: AppTheme.darkCard, shape: BoxShape.circle),
                      child: const Icon(Icons.wb_sunny_outlined, size: 54, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Devotionals Published Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to publish a guided daily devotional with scripture, deep meditation, and prayer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Publish First Devotional'),
                      onPressed: _uploadDevotionalDialog,
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
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? '',
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                            ),
                          ),
                          Text(
                            data['scriptureRef'] ?? '',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('By ${data['authorName'] ?? 'Author'}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      const Divider(color: Colors.white12, height: 20),
                      Text(
                        data['devotionalBody'] ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white),
                      ),
                      if (data['prayerPoints'] != null && data['prayerPoints'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Today’s Prayer & Declaration:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(data['prayerPoints'], style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
