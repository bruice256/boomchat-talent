import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../services/spiritual_service.dart';

class GodlyReelsScreen extends StatefulWidget {
  const GodlyReelsScreen({Key? key}) : super(key: key);

  @override
  State<GodlyReelsScreen> createState() => _GodlyReelsScreenState();
}

class _GodlyReelsScreenState extends State<GodlyReelsScreen> {
  final SpiritualService _spiritualService = SpiritualService();
  final PageController _pageController = PageController();

  void _uploadGodlyReel() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final captionController = TextEditingController();
    final tagController = TextEditingController();

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
              'Upload Godly Short Video (TikTok Style)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Caption / Message', hintText: 'Share a word of encouragement or testimony...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Scripture Reference Tag', hintText: 'e.g. #Philippians413 #Faith #Jesus'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                final caption = captionController.text.trim();
                final tag = tagController.text.trim();
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uploading Godly Video...')),
                );

                await _spiritualService.uploadGodlyReelVideo(
                  caption: caption.isNotEmpty ? caption : 'Godly Word',
                  scriptureTag: tag.isNotEmpty ? tag : '#GodIsGood',
                  videoFile: File(picked.path),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Godly video posted successfully!')),
                  );
                }
              },
              child: const Text('Post to GraceReels'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('GraceReels (Godly Videos)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: AppTheme.primaryGold, size: 28),
            tooltip: 'Upload Godly Video',
            onPressed: _uploadGodlyReel,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _spiritualService.getGodlyReelsStream(),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppTheme.darkCard, shape: BoxShape.circle),
                      child: const Icon(Icons.ondemand_video, size: 64, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Godly Videos Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A clean holy sanctuary where every believer can upload vertical short-form videos to glorify God, share testimonies, and preach the gospel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Upload First Godly Video'),
                      onPressed: _uploadGodlyReel,
                    ),
                  ],
                ),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: docs.length,
            itemBuilder: (ctx, idx) {
              final reel = docs[idx].data();
              return _GodlyReelPlayerItem(reelData: reel);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
        onPressed: _uploadGodlyReel,
      ),
    );
  }
}

class _GodlyReelPlayerItem extends StatefulWidget {
  final Map<String, dynamic> reelData;

  const _GodlyReelPlayerItem({Key? key, required this.reelData}) : super(key: key);

  @override
  State<_GodlyReelPlayerItem> createState() => _GodlyReelPlayerItemState();
}

class _GodlyReelPlayerItemState extends State<_GodlyReelPlayerItem> {
  VideoPlayerController? _controller;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    final url = widget.reelData['videoUrl'];
    if (url != null && url.isNotEmpty) {
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          _controller?.setLooping(true);
          _controller?.play();
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fullscreen Video Player
        if (_controller != null && _controller!.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Right Action Bar (TikTok style)
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                iconSize: 36,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => setState(() => _isLiked = !_isLiked),
              ),
              const Text('Amen', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 20),
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),

        // Bottom Details (Uploader, Caption, Scripture Tag)
        Positioned(
          left: 16,
          bottom: 24,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryGold,
                    child: const Icon(Icons.person, color: Colors.black, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${widget.reelData['uploaderName'] ?? 'Believer'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.reelData['caption'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.reelData['scriptureTag'] ?? '#Grace',
                style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
