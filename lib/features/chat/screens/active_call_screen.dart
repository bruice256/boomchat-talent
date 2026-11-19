import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/call_service.dart';

class ActiveCallScreen extends StatefulWidget {
  final String callId;
  final String contactName;
  final bool isCaller;
  final CallType callType;

  const ActiveCallScreen({
    Key? key,
    required this.callId,
    required this.contactName,
    required this.isCaller,
    required this.callType,
  }) : super(key: key);

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  final _callService = CallService();
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoOff = false;

  void _endCall() async {
    await _callService.endCall(widget.callId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.callType == CallType.video && !_isVideoOff;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Video placeholder or voice background
            if (isVideo)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam, size: 80, color: AppTheme.primaryGold),
                      const SizedBox(height: 16),
                      Text(
                        'Video Call with ${widget.contactName}',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text('WebRTC Video Stream Active', style: TextStyle(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: AppTheme.darkCard,
                      child: const Icon(Icons.person, size: 75, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.contactName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'BoomChat Secure Calling...',
                      style: TextStyle(color: AppTheme.primaryGold, fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Controls bottom panel
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 28,
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                    if (widget.callType == CallType.video)
                      IconButton(
                        iconSize: 28,
                        icon: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                        onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                      ),
                    IconButton(
                      iconSize: 28,
                      icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down, color: Colors.white),
                      onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.redAccent,
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white),
                        onPressed: _endCall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
