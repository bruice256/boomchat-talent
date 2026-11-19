import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CallType {
  audio,
  video,
}

enum CallStatus {
  ringing,
  connected,
  ended,
  rejected,
  missed,
}

class CallSession {
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final CallType type;
  final CallStatus status;
  final DateTime timestamp;

  CallSession({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CallSession.fromMap(Map<String, dynamic> map, String id) {
    return CallSession(
      callId: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] == 'video' ? CallType.video : CallType.audio,
      status: CallStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CallStatus.ringing,
      ),
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Create an outgoing call session
  Future<String> initiateCall({
    required String receiverId,
    required String receiverName,
    required CallType type,
  }) async {
    final callerId = currentUserId;
    final callerName = _auth.currentUser?.displayName ?? 'User';
    if (callerId == null) throw Exception('Not authenticated');

    final callRef = _firestore.collection('calls').doc();
    final session = CallSession(
      callId: callRef.id,
      callerId: callerId,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      type: type,
      status: CallStatus.ringing,
      timestamp: DateTime.now(),
    );

    await callRef.set(session.toMap());
    return callRef.id;
  }

  // Answer call
  Future<void> answerCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.connected.name,
    });
  }

  // End or reject call
  Future<void> endCall(String callId, {bool isReject = false}) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': isReject ? CallStatus.rejected.name : CallStatus.ended.name,
    });
  }

  // Listen to incoming calls for current user
  Stream<CallSession?> getIncomingCallStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return CallSession.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
          }
          return null;
        });
  }

  // Call history logs
  Stream<List<CallSession>> getCallHistoryStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('calls')
        .where('callerId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CallSession.fromMap(d.data(), d.id)).toList());
  }
}
