import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/call_service.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final callService = CallService();

    return StreamBuilder<List<CallSession>>(
      stream: callService.getCallHistoryStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
        }

        final calls = snapshot.data ?? [];
        if (calls.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_call, size: 50, color: AppTheme.primaryGold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Call Logs Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To start a voice or video call with fellow believers, open any conversation and tap the phone or camera icon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          itemCount: calls.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
          itemBuilder: (ctx, idx) {
            final call = calls[idx];
            final isVideo = call.type == CallType.video;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.darkCard,
                child: const Icon(Icons.person, color: AppTheme.primaryGold),
              ),
              title: Text(call.receiverName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  Icon(
                    call.status == CallStatus.missed ? Icons.call_missed : Icons.call_made,
                    size: 16,
                    color: call.status == CallStatus.missed ? Colors.redAccent : Colors.greenAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${call.timestamp.hour.toString().padLeft(2, '0')}:${call.timestamp.minute.toString().padLeft(2, '0')} • ${call.status.name}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              trailing: Icon(
                isVideo ? Icons.videocam : Icons.call,
                color: AppTheme.primaryGold,
              ),
            );
          },
        );
      },
    );
  }
}
