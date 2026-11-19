import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';

class DramatizedAudioBibleScreen extends StatefulWidget {
  const DramatizedAudioBibleScreen({Key? key}) : super(key: key);

  @override
  State<DramatizedAudioBibleScreen> createState() => _DramatizedAudioBibleScreenState();
}

class _DramatizedAudioBibleScreenState extends State<DramatizedAudioBibleScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  String _selectedBook = 'John';
  int _selectedChapter = 1;

  final List<String> _books = [
    'Genesis', 'Exodus', 'Psalms', 'Proverbs', 'Isaiah',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', 'Revelation'
  ];

  // John 1 sample synchronized dramatized passage
  final List<Map<String, dynamic>> _verses = [
    {
      'num': 1,
      'text': 'In the beginning was the Word, and the Word was with God, and the Word was God.',
      'character': 'Narrator'
    },
    {
      'num': 2,
      'text': 'He was in the beginning with God.',
      'character': 'Narrator'
    },
    {
      'num': 3,
      'text': 'All things were made through him, and without him was not any thing made that was made.',
      'character': 'Narrator'
    },
    {
      'num': 4,
      'text': 'In him was life, and the life was the light of men.',
      'character': 'Narrator'
    },
    {
      'num': 5,
      'text': 'The light shines in the darkness, and the darkness has not overcome it.',
      'character': 'Dramatic Voice'
    },
    {
      'num': 6,
      'text': 'There was a man sent from God, whose name was John.',
      'character': 'Narrator'
    },
    {
      'num': 7,
      'text': 'He came as a witness, to bear witness about the light, that all might believe through him.',
      'character': 'Narrator'
    },
    {
      'num': 8,
      'text': 'He was not the light, but came to bear witness about the light.',
      'character': 'Narrator'
    },
    {
      'num': 9,
      'text': 'The true light, which gives light to everyone, was coming into the world.',
      'character': 'Dramatic Voice'
    },
    {
      'num': 14,
      'text': 'And the Word became flesh and dwelt among us, and we have seen his glory, glory as of the only Son from the Father, full of grace and truth.',
      'character': 'Chorus & Narrator'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAudioStreams();
  }

  void _initAudioStreams() {
    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _duration = d);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Dramatized Bible Audio Stream URL (or local asset/cloud link)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Streaming Dramatized Audio Bible...')),
      );
      setState(() => _isPlaying = true);
    }
  }

  void _changeSpeed() {
    final speeds = [0.75, 1.0, 1.25, 1.5];
    final nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    setState(() => _playbackSpeed = speeds[nextIdx]);
    _audioPlayer.setSpeed(_playbackSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dramatized Bible: $_selectedBook $_selectedChapter'),
        actions: [
          TextButton(
            onPressed: _changeSpeed,
            child: Text(
              '${_playbackSpeed}x',
              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<String>(
            color: AppTheme.darkSurface,
            onSelected: (book) => setState(() => _selectedBook = book),
            itemBuilder: (ctx) => _books
                .map((b) => PopupMenuItem(value: b, child: Text(b)))
                .toList(),
            icon: const Icon(Icons.library_books),
          ),
        ],
      ),
      body: Column(
        children: [
          // Synchronized Matching Scripture Text
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _verses.length,
              itemBuilder: (ctx, idx) {
                final v = _verses[idx];
                final isHighlighted = idx == 0 && _isPlaying;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighlighted ? AppTheme.primaryTeal.withOpacity(0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isHighlighted ? Border.all(color: AppTheme.primaryGold) : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${v['num']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v['text'],
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: isHighlighted ? Colors.white : AppTheme.textLight,
                                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Voice: ${v['character']}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Audio Player Controls Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProgressBar(
                    progress: _position,
                    total: _duration > Duration.zero ? _duration : const Duration(minutes: 3, seconds: 45),
                    progressBarColor: AppTheme.primaryGold,
                    baseBarColor: Colors.white24,
                    thumbColor: AppTheme.primaryGold,
                    onSeek: (d) => _audioPlayer.seek(d),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 30, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay_10, size: 28, color: Colors.white),
                        onPressed: () {},
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryGold,
                        child: IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 32),
                          onPressed: _togglePlayback,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, size: 28, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 30, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
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
