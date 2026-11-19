import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class LiveBibleStudyScreen extends StatefulWidget {
  const LiveBibleStudyScreen({Key? key}) : super(key: key);

  @override
  State<LiveBibleStudyScreen> createState() => _LiveBibleStudyScreenState();
}

class _LiveBibleStudyScreenState extends State<LiveBibleStudyScreen> {
  final SpiritualService _spiritualService = SpiritualService();

  void _createLessonDialog() {
    final topicController = TextEditingController();
    final refController = TextEditingController();
    final passageController = TextEditingController();
    final commentaryController = TextEditingController();

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
                'Teach Bible Study in Bits (Teacher Portal)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: topicController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Lesson Topic', hintText: 'e.g. Walking in the Spirit'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Scripture Reference', hintText: 'e.g. Galatians 5:16-25'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passageController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Scripture Text Passage',
                  hintText: 'Enter the exact passage text to be studied...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentaryController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Teaching Commentary (In Bits Alongside Text)',
                  hintText: 'Break down the verses bit by bit with explanation, greek context, and practical application...',
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  final topic = topicController.text.trim();
                  final ref = refController.text.trim();
                  final passage = passageController.text.trim();
                  final comm = commentaryController.text.trim();

                  if (topic.isEmpty || ref.isEmpty || passage.isEmpty || comm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all lesson fields.')),
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  await _spiritualService.createBibleStudyLesson(
                    topic: topic,
                    scriptureReference: ref,
                    scripturePassage: passage,
                    commentaryLesson: comm,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bible Study Lesson Published!')),
                    );
                  }
                },
                child: const Text('Publish Lesson to Classroom'),
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
        title: const Text('Live Bible Study Classroom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add),
            tooltip: 'Teach Lesson',
            onPressed: _createLessonDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getBibleStudiesStream(),
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
                      child: const Icon(Icons.cast_for_education, size: 54, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Live Bible Study Classroom',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Teach believers the scriptures in bite-sized chunks alongside the sacred text with commentary and notes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Publish First Lesson'),
                      onPressed: _createLessonDialog,
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
              final lesson = docs[idx].data();
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lesson['topic'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lesson['scriptureReference'] ?? '',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Teacher: ${lesson['teacherName'] ?? 'Teacher'}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(height: 14),

                      // Side-by-side or stacked Scripture & Commentary in bits
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_quote, color: AppTheme.primaryGold, size: 18),
                                SizedBox(width: 6),
                                Text('Sacred Scripture Passage:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textLight, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lesson['scripturePassage'] ?? '',
                              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Commentary in bits
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.menu_book, color: AppTheme.primaryGold, size: 18),
                                SizedBox(width: 6),
                                Text('Exposition & Teaching in Bits:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lesson['commentaryLesson'] ?? '',
                              style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      ),
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
