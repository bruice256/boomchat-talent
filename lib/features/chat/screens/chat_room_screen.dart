import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../services/chat_service.dart';
import '../services/call_service.dart';
import 'active_call_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String recipientId;
  final String recipientName;

  const ChatRoomScreen({
    Key? key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final _callService = CallService();
  late final AudioRecorder _audioRecorder;
  final AudioPlayer _bubbleAudioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    _bubbleAudioPlayer.dispose();
    super.dispose();
  }

  void _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final participants = [_chatService.currentUserId ?? '', widget.recipientId];
    await _chatService.sendTextMessage(
      conversationId: widget.conversationId,
      text: text,
      participants: participants,
    );
  }

  void _startVoiceRecording() async {
    final hasPerm = await _audioRecorder.hasPermission();
    if (!hasPerm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required for voice notes.')),
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordingPath = path;
      _recordingStartTime = DateTime.now();
    });
  }

  void _stopAndSendVoiceRecording() async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    final duration = DateTime.now().difference(_recordingStartTime ?? DateTime.now()).inSeconds;

    setState(() => _isRecording = false);

    if (path != null && duration >= 1) {
      final file = File(path);
      final participants = [_chatService.currentUserId ?? '', widget.recipientId];
      await _chatService.sendVoiceNote(
        conversationId: widget.conversationId,
        audioFile: file,
        durationSeconds: duration,
        participants: participants,
      );
    }
  }

  void _cancelVoiceRecording() async {
    await _audioRecorder.stop();
    setState(() => _isRecording = false);
  }

  void _pickAndSendMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.purpleAccent),
              title: const Text('Photos & Images'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  _uploadMedia(File(picked.path), MessageType.image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.pinkAccent),
              title: const Text('Videos'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickVideo(source: ImageSource.gallery);
                if (picked != null) {
                  _uploadMedia(File(picked.path), MessageType.video);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
              title: const Text('Documents (PDF, Word, Excel)'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  _uploadMedia(File(result.files.single.path!), MessageType.document);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadMedia(File file, MessageType type) async {
    final participants = [_chatService.currentUserId ?? '', widget.recipientId];
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading attachment...')),
    );
    await _chatService.sendMediaFile(
      conversationId: widget.conversationId,
      file: file,
      type: type,
      caption: '',
      participants: participants,
    );
  }

  void _startCall(CallType type) async {
    try {
      final callId = await _callService.initiateCall(
        receiverId: widget.recipientId,
        receiverName: widget.recipientName,
        type: type,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveCallScreen(
            callId: callId,
            contactName: widget.recipientName,
            isCaller: true,
            callType: type,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Call could not be started: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _chatService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.darkCard,
              child: const Icon(Icons.person, color: AppTheme.primaryGold, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Online • Living rightly with God', style: TextStyle(fontSize: 11, color: AppTheme.primaryGold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
            onPressed: () => _startCall(CallType.audio),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
            onPressed: () => _startCall(CallType.video),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessagesStream(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock, size: 48, color: AppTheme.primaryGold),
                          const SizedBox(height: 12),
                          const Text(
                            'End-to-End Encrypted',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textLight),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Say hello to ${widget.recipientName} or send a voice message to encourage them in faith!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, idx) {
                    final msg = messages[idx];
                    final isMe = msg.senderId == currentUid;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),

          // Bottom Input Bar with Voice Notes & Attachments
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryTeal : AppTheme.darkCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.type == MessageType.voice)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: AppTheme.primaryGold),
                    onPressed: () async {
                      if (msg.mediaUrl != null) {
                        await _bubbleAudioPlayer.setUrl(msg.mediaUrl!);
                        _bubbleAudioPlayer.play();
                      }
                    },
                  ),
                  const Expanded(
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryGold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${msg.mediaDurationSeconds ?? 0}s', style: const TextStyle(fontSize: 11)),
                ],
              )
            else if (msg.type == MessageType.image)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      msg.mediaUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                  if (msg.content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(msg.content, style: const TextStyle(color: Colors.white)),
                  ],
                ],
              )
            else
              Text(
                msg.content,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.white60),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: AppTheme.primaryGold),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: AppTheme.darkSurface,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppTheme.primaryGold),
              onPressed: _pickAndSendMedia,
            ),
            Expanded(
              child: _isRecording
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.mic, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Recording voice note...', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    )
                  : TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            if (_isRecording) ...[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _cancelVoiceRecording,
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primaryGold),
                onPressed: _stopAndSendVoiceRecording,
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.mic, color: AppTheme.primaryGold),
                onPressed: _startVoiceRecording,
              ),
              CircleAvatar(
                backgroundColor: AppTheme.primaryGold,
                radius: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.send, color: Colors.black, size: 18),
                  onPressed: _sendTextMessage,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
