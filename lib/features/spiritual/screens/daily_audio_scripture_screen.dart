import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class DailyAudioScriptureScreen extends StatefulWidget {
  const DailyAudioScriptureScreen({Key? key}) : super(key: key);

  @override
  State<DailyAudioScriptureScreen> createState() => _DailyAudioScriptureScreenState();
}

class _DailyAudioScriptureScreenState extends State<DailyAudioScriptureScreen> {
  final SpiritualService _spiritualService = SpiritualService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showUploadDialog() {
    final refController = TextEditingController();
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
                  'Upload Daily Guided Audio Scripture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: refController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Scripture Reference', hintText: 'e.g. Romans 8:28-39'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Corresponding Scripture Text',
                    hintText: 'Paste the exact scripture text passage here...',
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
                    selectedAudioFile != null ? 'Audio Selected: ${selectedAudioFile!.path.split("/").last}' : 'Select Audio Recording (.mp3, .m4a)',
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
                    final ref = refController.text.trim();
                    final text = textController.text.trim();
                    if (ref.isEmpty || text.isEmpty || selectedAudioFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete all fields and select audio.')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Uploading Audio Scripture...')),
                    );
                    await _spiritualService.uploadDailyScripture(
                      reference: ref,
                      scriptureText: text,
                      audioFile: selectedAudioFile!,
                      durationSeconds: 150,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio Scripture published successfully!')),
                      );
                    }
                  },
                  child: const Text('Publish Audio Scripture'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playScripture(String id, String url) async {
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
        title: const Text('Daily Guided Audio Scripture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Upload Scripture',
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getDailyScripturesStream(),
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
                      child: const Icon(Icons.headphones, size: 50, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Audio Scriptures Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload guided audio scripture passages with corresponding text to inspire brethren worldwide.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload First Audio Scripture'),
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
                              data['reference'] ?? 'Scripture',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryGold,
                            child: IconButton(
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 20),
                              onPressed: () => _playScripture(id, data['audioUrl'] ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Narrated by: ${data['uploaderName'] ?? 'Believer'}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      const Divider(color: Colors.white12, height: 18),
                      Text(
                        data['scriptureText'] ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white),
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
