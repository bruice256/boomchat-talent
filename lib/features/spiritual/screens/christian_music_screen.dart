import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class ChristianMusicScreen extends StatefulWidget {
  const ChristianMusicScreen({Key? key}) : super(key: key);

  @override
  State<ChristianMusicScreen> createState() => _ChristianMusicScreenState();
}

class _ChristianMusicScreenState extends State<ChristianMusicScreen> {
  final SpiritualService _spiritualService = SpiritualService();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  String? _currentTrackTitle;
  String? _currentArtist;

  @override
  void initState() {
    super.initState();
    _musicPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _musicPlayer.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duration = d);
    });
    _musicPlayer.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }

  void _uploadChristianTrack() async {
    final titleController = TextEditingController();
    final artistController = TextEditingController();
    File? selectedMusicFile;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Christian Music (Audio Only)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Song Title', hintText: 'e.g. Amazing Grace'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: artistController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Artist / Choir / Worship Leader'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryGold),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.music_note, color: AppTheme.primaryGold),
                label: Text(
                  selectedMusicFile != null
                      ? 'Music Attached: ${selectedMusicFile!.path.split("/").last}'
                      : 'Select Audio Song (.mp3, .wav, .flac)',
                  style: const TextStyle(color: AppTheme.textLight),
                ),
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(type: FileType.audio);
                  if (res != null && res.files.single.path != null) {
                    setModalState(() => selectedMusicFile = File(res.files.single.path!));
                  }
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final artist = artistController.text.trim();
                  if (title.isEmpty || selectedMusicFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter track title and attach music file.')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uploading Christian Music...')),
                  );
                  await _spiritualService.uploadChristianMusic(
                    trackTitle: title,
                    artistName: artist.isNotEmpty ? artist : 'Worship Artist',
                    audioFile: selectedMusicFile!,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Christian Music added to Sanctuary!')),
                    );
                  }
                },
                child: const Text('Add Track to Sanctuary'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playTrack(String url, String title, String artist) async {
    setState(() {
      _currentTrackTitle = title;
      _currentArtist = artist;
    });
    await _musicPlayer.setUrl(url);
    _musicPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Christian Music Sanctuary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.music_note),
            tooltip: 'Upload Music',
            onPressed: _uploadChristianTrack,
          ),
        ],
      ),
      body: Column(
        children: [
          // Music List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _spiritualService.getChristianMusicStream(),
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
                            child: const Icon(Icons.library_music, size: 54, color: AppTheme.primaryGold),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Pure Worship Music',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pure audio Christian music only without text distractions. Uplift your soul with gospel worship and hymns.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.library_add),
                            label: const Text('Upload Christian Music'),
                            onPressed: _uploadChristianTrack,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (ctx, idx) {
                    final track = docs[idx].data();
                    final title = track['trackTitle'] ?? 'Track';
                    final artist = track['artistName'] ?? 'Artist';
                    final url = track['audioUrl'] ?? '';
                    final isCurrent = _currentTrackTitle == title;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? AppTheme.primaryGold : AppTheme.darkCard,
                        child: Icon(
                          Icons.music_note,
                          color: isCurrent ? Colors.black : AppTheme.primaryGold,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? AppTheme.primaryGold : Colors.white,
                        ),
                      ),
                      subtitle: Text(artist, style: const TextStyle(color: AppTheme.textMuted)),
                      trailing: IconButton(
                        icon: Icon(
                          isCurrent && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: AppTheme.primaryGold,
                          size: 32,
                        ),
                        onPressed: () {
                          if (isCurrent) {
                            if (_isPlaying) {
                              _musicPlayer.pause();
                            } else {
                              _musicPlayer.play();
                            }
                          } else {
                            _playTrack(url, title, artist);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Persistent Now Playing Bottom Audio Bar
          if (_currentTrackTitle != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.album, size: 40, color: AppTheme.primaryGold),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentTrackTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(_currentArtist ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryGold,
                          child: IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black),
                            onPressed: () {
                              if (_isPlaying) {
                                _musicPlayer.pause();
                              } else {
                                _musicPlayer.play();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ProgressBar(
                      progress: _position,
                      total: _duration,
                      progressBarColor: AppTheme.primaryGold,
                      baseBarColor: Colors.white24,
                      thumbColor: AppTheme.primaryGold,
                      onSeek: (d) => _musicPlayer.seek(d),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
