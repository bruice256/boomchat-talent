import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';
import 'lectio_divina_screen.dart';
import 'dramatized_audio_bible_screen.dart';
import 'daily_audio_prayer_screen.dart';
import 'daily_audio_scripture_screen.dart';
import 'godly_reels_screen.dart';
import 'spiritual_videos_screen.dart';
import 'christian_music_screen.dart';
import 'live_bible_study_screen.dart';
import 'daily_devotional_screen.dart';

class SpiritualHubScreen extends StatelessWidget {
  const SpiritualHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Growth Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Spiritual Header with Developer Motto
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF134E4A), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_stories, color: AppTheme.primaryGold, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Spiritual Growth Sanctuary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '"${AppCredentials.spiritualMotto}"',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primaryGold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppCredentials.tagline} • ${AppCredentials.motto}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'DAILY DISCIPLINES & PRAYER',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          // 1. Lectio Divina
          _buildHubCard(
            context: context,
            title: 'Lectio Divina & Guided Prayer',
            subtitle: '5-step contemplative prayer rhythm: Silencio, Lectio, Meditatio, Oratio, Contemplatio.',
            icon: Icons.self_improvement,
            iconColor: Colors.amber,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LectioDivinaScreen())),
          ),

          // 2. Dramatized Audio Bible + Matching Text
          _buildHubCard(
            context: context,
            title: 'Dramatized Audio Bible & Text',
            subtitle: 'Rich spoken word with character voices alongside synchronized scripture verses.',
            icon: Icons.menu_book,
            iconColor: Colors.lightBlueAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DramatizedAudioBibleScreen())),
          ),

          // 3. Daily Guided Audio Prayer + Text
          _buildHubCard(
            context: context,
            title: 'Daily Guided Audio Prayer',
            subtitle: 'Upload and listen to daily guided prayers with matching prayer text transcripts.',
            icon: Icons.record_voice_over,
            iconColor: Colors.tealAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyAudioPrayerScreen())),
          ),

          // 4. Daily Guided Audio Scripture + Text
          _buildHubCard(
            context: context,
            title: 'Daily Guided Audio Scripture',
            subtitle: 'Upload and meditate upon daily audio scripture alongside accompanying text.',
            icon: Icons.headphones,
            iconColor: Colors.deepPurpleAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyAudioScriptureScreen())),
          ),

          const SizedBox(height: 18),
          const Text(
            'MEDIA & COMMUNITY EDIFICATION',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          // 5. Godly TikTok Short Videos
          _buildHubCard(
            context: context,
            title: 'GraceReels (Godly Short Videos)',
            subtitle: 'Swipe vertical short-form videos focused on Christ, testimonies, and biblical truth.',
            icon: Icons.play_arrow_rounded,
            iconColor: Colors.pinkAccent,
            badgeText: 'TIKTOK STYLE',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GodlyReelsScreen())),
          ),

          // 6. Spiritual Growth Videos
          _buildHubCard(
            context: context,
            title: 'Spiritual Growth Videos',
            subtitle: 'Full-length sermons, expository teachings, and deep spiritual lessons.',
            icon: Icons.ondemand_video,
            iconColor: Colors.redAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualVideosScreen())),
          ),

          // 7. Christian Music Only (Audio Only)
          _buildHubCard(
            context: context,
            title: 'Christian Music Only (Audio Only)',
            subtitle: 'Pure worship, praise, and hymns without text distractions. Stream and upload audio.',
            icon: Icons.library_music,
            iconColor: Colors.orangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChristianMusicScreen())),
          ),

          // 8. Live Bible Study Room
          _buildHubCard(
            context: context,
            title: 'Live Bible Study Room',
            subtitle: 'Teach and learn the Bible in bits alongside the text with interactive student notes.',
            icon: Icons.cast_for_education,
            iconColor: Colors.greenAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveBibleStudyScreen())),
          ),

          // 9. Guided Daily Devotional
          _buildHubCard(
            context: context,
            title: 'Guided Daily Devotionals',
            subtitle: 'Scripture of the day, reflective application, and prayer points. Upload or read.',
            icon: Icons.wb_sunny_outlined,
            iconColor: Colors.amberAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyDevotionalScreen())),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.darkSurface,
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.3)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
