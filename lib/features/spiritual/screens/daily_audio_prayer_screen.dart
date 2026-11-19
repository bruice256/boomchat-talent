import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class DailyAudioPrayerScreen extends StatefulWidget {
  const DailyAudioPrayerScreen({Key? key}) : super(key: key);

  @override
  State<DailyAudioPrayerScreen> createState() => _DailyAudioPrayerScreenState();
}

class _DailyAudioPrayerScreenState extends State<DailyAudioPrayerScreen> {
  final SpiritualService _spiritualService = SpiritualService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    File? selectedAudioFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  'Upload Daily Guided Audio Prayer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Prayer Title', hintText: 'e.g. Morning Prayer for Peace & Strength'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Corresponding Prayer Text Transcript',
                    hintText: 'Type or paste the matching text of the prayer...',
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.audio_file, color: AppTheme.primaryGold),
                  label: Text(
                    selectedAudioFile != null ? 'Audio Selected: ${selectedAudioFile!.path.split("/").last}' : 'Select Audio File (.mp3, .m4a, .wav)',
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
                  onPressed: () async {
                    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
                    if (res != null && res.files.single.path != null) {
                      setModalState(() => selectedAudioFile = File(res.files.single.path!));
                    }
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final text = textController.text.trim();
                    if (title.isEmpty || text.isEmpty || selectedAudioFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete all fields and attach an audio file.')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Uploading Guided Audio Prayer...')),
                    );
                    await _spiritualService.uploadDailyPrayer(
                      title: title,
                      prayerText: text,
                      audioFile: selectedAudioFile!,
                      durationSeconds: 180,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Guided Audio Prayer uploaded successfully!')),
                      );
                    }
                  },
                  child: const Text('Publish Audio Prayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playPrayer(String id, String url) async {
    if (_currentlyPlayingId == id) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        setState(() {});
      } else {
        await _audioPlayer.play();
        setState(() {});
      }
    } else {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
      setState(() => _currentlyPlayingId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Guided Audio Prayers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Upload Prayer',
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getDailyPrayersStream(),
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
                      child: const Icon(Icons.record_voice_over, size: 50, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Audio Prayers Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload your first daily guided audio prayer with matching text to bless the community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload First Audio Prayer'),
                      onPressed: _showUploadDialog,
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
              final id = docs[idx].id;
              final isPlaying = _currentlyPlayingId == id && _audioPlayer.playing;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'Daily Prayer',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryGold,
                            child: IconButton(
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 20),
                              onPressed: () => _playPrayer(id, data['audioUrl'] ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${data['uploaderName'] ?? 'Believer'}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryGold),
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      const Text(
                        'Matching Prayer Text:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['prayerText'] ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
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
