import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MessageType {
  text,
  voice,
  image,
  video,
  document,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final int? mediaDurationSeconds;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.mediaDurationSeconds,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'mediaDurationSeconds': mediaDurationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      mediaUrl: map['mediaUrl'],
      mediaDurationSeconds: map['mediaDurationSeconds'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class UserStatusStory {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content; // text or caption
  final String? mediaUrl;
  final String type; // text, image, video
  final DateTime createdAt;
  final DateTime expiresAt;

  UserStatusStory({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.mediaUrl,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'mediaUrl': mediaUrl,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory UserStatusStory.fromMap(Map<String, dynamic> map, String id) {
    return UserStatusStory(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      type: map['type'] ?? 'text',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : DateTime.now(),
    );
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName ?? 'BoomChat User';

  // Stream of conversation list for the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationsStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Stream of messages in a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), doc.id)).toList());
  }

  // Send Text Message
  Future<void> sendTextMessage({
    required String conversationId,
    required String text,
    required List<String> participants,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final msgRef = _firestore.collection('conversations').doc(conversationId).collection('messages').doc();
    final message = ChatMessage(
      id: msgRef.id,
      senderId: uid,
      senderName: currentUserName ?? 'User',
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await msgRef.set(message.toMap());

    await _firestore.collection('conversations').doc(conversationId).set({
      'id': conversationId,
      'participants': participants,
      'lastMessage': text,
      'lastMessageSenderId': uid,
      'lastMessageTime': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Send Voice Note
  Future<void> sendVoiceNote({
    required String conversationId,
    required File audioFile,
    required int durationSeconds,
    required List<String> participants,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    // Upload audio file to Firebase Storage
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref().child('chats/$conversationId/voices/$fileName');
    final uploadTask = await ref.putFile(audioFile);
    final mediaUrl = await uploadTask.ref.getDownloadURL();

    final msgRef = _firestore.collection('conversations').doc(conversationId).collection('messages').doc();
    final message = ChatMessage(
      id: msgRef.id,
      senderId: uid,
      senderName: currentUserName ?? 'User',
      content: 'Voice Message ($durationSeconds s)',
      type: MessageType.voice,
      mediaUrl: mediaUrl,
      mediaDurationSeconds: durationSeconds,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await msgRef.set(message.toMap());

    await _firestore.collection('conversations').doc(conversationId).set({
      'id': conversationId,
      'participants': participants,
      'lastMessage': '🎤 Voice Message',
      'lastMessageSenderId': uid,
      'lastMessageTime': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Send File or Media (Photos, Videos, Documents)
  Future<void> sendMediaFile({
    required String conversationId,
    required File file,
    required MessageType type,
    required String caption,
    required List<String> participants,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final fileName = '${type.name}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}';
    final ref = _storage.ref().child('chats/$conversationId/media/$fileName');
    final uploadTask = await ref.putFile(file);
    final mediaUrl = await uploadTask.ref.getDownloadURL();

    final msgRef = _firestore.collection('conversations').doc(conversationId).collection('messages').doc();
    final message = ChatMessage(
      id: msgRef.id,
      senderId: uid,
      senderName: currentUserName ?? 'User',
      content: caption.isNotEmpty ? caption : file.path.split("/").last,
      type: type,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await msgRef.set(message.toMap());

    await _firestore.collection('conversations').doc(conversationId).set({
      'id': conversationId,
      'participants': participants,
      'lastMessage': caption.isNotEmpty ? caption : '📎 Sent a file',
      'lastMessageSenderId': uid,
      'lastMessageTime': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Post Status / Story (Expires in 24 hours)
  Future<void> postStatusStory({
    required String text,
    File? mediaFile,
    required String type,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    String? mediaUrl;
    if (mediaFile != null) {
      final fileName = 'status_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('statuses/$uid/$fileName');
      final uploadTask = await ref.putFile(mediaFile);
      mediaUrl = await uploadTask.ref.getDownloadURL();
    }

    final docRef = _firestore.collection('statuses').doc();
    final story = UserStatusStory(
      id: docRef.id,
      userId: uid,
      userName: currentUserName ?? 'User',
      content: text,
      mediaUrl: mediaUrl,
      type: type,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await docRef.set(story.toMap());
  }

  // Stream active 24-hour statuses
  Stream<List<UserStatusStory>> getActiveStatusesStream() {
    final now = DateTime.now().toIso8601String();
    return _firestore
        .collection('statuses')
        .where('expiresAt', isGreaterThan: now)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserStatusStory.fromMap(doc.data(), doc.id)).toList());
  }
}
