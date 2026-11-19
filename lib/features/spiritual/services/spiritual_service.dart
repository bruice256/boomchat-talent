import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpiritualService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName ?? 'Believer';

  // --- 1. DAILY GUIDED AUDIO PRAYER + TEXT ---
  Future<void> uploadDailyPrayer({
    required String title,
    required String prayerText,
    required File audioFile,
    required int durationSeconds,
  }) async {
    final fileName = 'prayer_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref().child('spiritual/prayers/$fileName');
    final task = await ref.putFile(audioFile);
    final audioUrl = await task.ref.getDownloadURL();

    await _firestore.collection('spiritual_prayers').add({
      'title': title,
      'prayerText': prayerText,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'uploaderId': currentUserId,
      'uploaderName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyPrayersStream() {
    return _firestore.collection('spiritual_prayers').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 2. DAILY GUIDED AUDIO SCRIPTURE + TEXT ---
  Future<void> uploadDailyScripture({
    required String reference, // e.g. John 15:1-8
    required String scriptureText,
    required File audioFile,
    required int durationSeconds,
  }) async {
    final fileName = 'scripture_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref().child('spiritual/scriptures/$fileName');
    final task = await ref.putFile(audioFile);
    final audioUrl = await task.ref.getDownloadURL();

    await _firestore.collection('spiritual_scriptures').add({
      'reference': reference,
      'scriptureText': scriptureText,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'uploaderId': currentUserId,
      'uploaderName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyScripturesStream() {
    return _firestore.collection('spiritual_scriptures').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 3. GODLY TIKTOK-STYLE SHORT VIDEOS (GRACEREELS) ---
  Future<void> uploadGodlyReelVideo({
    required String caption,
    required String scriptureTag,
    required File videoFile,
  }) async {
    final fileName = 'reel_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = _storage.ref().child('spiritual/godly_reels/$fileName');
    final task = await ref.putFile(videoFile);
    final videoUrl = await task.ref.getDownloadURL();

    await _firestore.collection('godly_reels').add({
      'caption': caption,
      'scriptureTag': scriptureTag,
      'videoUrl': videoUrl,
      'likesCount': 0,
      'uploaderId': currentUserId,
      'uploaderName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getGodlyReelsStream() {
    return _firestore.collection('godly_reels').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 4. SPIRITUAL GROWTH VIDEOS (SERMONS / TEACHINGS) ---
  Future<void> uploadSpiritualVideo({
    required String title,
    required String description,
    required File videoFile,
  }) async {
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = _storage.ref().child('spiritual/growth_videos/$fileName');
    final task = await ref.putFile(videoFile);
    final videoUrl = await task.ref.getDownloadURL();

    await _firestore.collection('growth_videos').add({
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'uploaderId': currentUserId,
      'uploaderName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSpiritualVideosStream() {
    return _firestore.collection('growth_videos').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 5. CHRISTIAN MUSIC ONLY (AUDIO ONLY) ---
  Future<void> uploadChristianMusic({
    required String trackTitle,
    required String artistName,
    required File audioFile,
  }) async {
    final fileName = 'music_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final ref = _storage.ref().child('spiritual/christian_music/$fileName');
    final task = await ref.putFile(audioFile);
    final audioUrl = await task.ref.getDownloadURL();

    await _firestore.collection('christian_music').add({
      'trackTitle': trackTitle,
      'artistName': artistName,
      'audioUrl': audioUrl,
      'uploaderId': currentUserId,
      'uploaderName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChristianMusicStream() {
    return _firestore.collection('christian_music').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 6. LIVE BIBLE STUDY SESSIONS ---
  Future<void> createBibleStudyLesson({
    required String topic,
    required String scriptureReference,
    required String scripturePassage,
    required String commentaryLesson,
  }) async {
    await _firestore.collection('bible_studies').add({
      'topic': topic,
      'scriptureReference': scriptureReference,
      'scripturePassage': scripturePassage,
      'commentaryLesson': commentaryLesson,
      'teacherId': currentUserId,
      'teacherName': currentUserName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBibleStudiesStream() {
    return _firestore.collection('bible_studies').orderBy('createdAt', descending: true).snapshots();
  }

  // --- 7. GUIDED DAILY DEVOTIONAL ---
  Future<void> uploadDailyDevotional({
    required String title,
    required String scriptureRef,
    required String devotionalBody,
    required String prayerPoints,
  }) async {
    await _firestore.collection('daily_devotionals').add({
      'title': title,
      'scriptureRef': scriptureRef,
      'devotionalBody': devotionalBody,
      'prayerPoints': prayerPoints,
      'authorId': currentUserId,
      'authorName': currentUserName,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDailyDevotionalsStream() {
    return _firestore.collection('daily_devotionals').orderBy('date', descending: true).snapshots();
  }
}
