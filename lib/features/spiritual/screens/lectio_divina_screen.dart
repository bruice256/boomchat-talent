import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_credentials.dart';
import '../../../core/theme/app_theme.dart';

class LectioDivinaScreen extends StatefulWidget {
  const LectioDivinaScreen({Key? key}) : super(key: key);

  @override
  State<LectioDivinaScreen> createState() => _LectioDivinaScreenState();
}

class _LectioDivinaScreenState extends State<LectioDivinaScreen> {
  int _currentStep = 0;
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes per step default
  bool _isTimerRunning = false;
  final TextEditingController _journalController = TextEditingController();

  final List<Map<String, String>> _steps = [
    {
      'name': '1. Silencio (Stillness)',
      'subtitle': 'Quiet your heart and mind. Let go of distractions.',
      'instruction': 'Take a deep breath. Sit comfortably. Acknowledge God’s presence with you right now in this very room.',
      'scripture': '"Be still, and know that I am God." — Psalm 46:10',
    },
    {
      'name': '2. Lectio (Read)',
      'subtitle': 'Read the sacred scripture slowly and with reverence.',
      'instruction': 'Read the passage out loud or in your mind. Do not rush to analyze. Listen for a word or phrase that resonates.',
      'scripture': '"Your word is a lamp to my feet and a light to my path." — Psalm 119:105\n\n'
          'Passage: "Abide in me, and I in you. As the branch cannot bear fruit by itself, unless it abides in the vine, neither can you, unless you abide in me." — John 15:4',
    },
    {
      'name': '3. Meditatio (Reflect)',
      'subtitle': 'Meditate on what God is saying through this word.',
      'instruction': 'Why did that specific phrase stand out to you? What area of your life does it speak into today?',
      'scripture': '"I will meditate on your precepts and fix my eyes on your ways." — Psalm 119:15',
    },
    {
      'name': '4. Oratio (Pray)',
      'subtitle': 'Talk directly with God as a friend.',
      'instruction': 'Respond honestly to what God showed you. Express your gratitude, repentance, needs, and surrender.',
      'scripture': '"Do not be anxious about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God." — Philippians 4:6',
    },
    {
      'name': '5. Contemplatio (Rest)',
      'subtitle': 'Rest silently in God’s loving embrace.',
      'instruction': 'Release all words. Simply be with God. Rest in His unshakeable grace, mercy, and peace.',
      'scripture': '"The Lord is my shepherd; I shall not want. He makes me lie down in green pastures." — Psalm 23:1-2',
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _journalController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          t.cancel();
          setState(() => _isTimerRunning = false);
          _goToNextStep();
        }
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _secondsRemaining = 120;
        _isTimerRunning = false;
      });
      _timer?.cancel();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Prayer Completed', style: TextStyle(color: AppTheme.primaryGold)),
        content: const Text(
          'Grace and peace be multiplied unto you. You have walked through the sacred rhythm of Lectio Divina.\n\n'
          'Go forth living rightly with God and fellow people.',
          style: TextStyle(color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Amen'),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectio Divina & Prayer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGold),
              ),
              const SizedBox(height: 16),

              // Step Title & Subtitle
              Text(
                step['name']!,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 4),
              Text(step['subtitle']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 20),

              // Scripture & Instructions Card
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: AppTheme.primaryGold, size: 20),
                                SizedBox(width: 8),
                                Text('Guidance:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(step['instruction']!, style: const TextStyle(color: AppTheme.textLight, height: 1.5)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                step['scripture']!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.primaryGold,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentStep == 3) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _journalController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Your Prayer Response (Journal)',
                            hintText: 'Write down your heartfelt prayer to God...',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Meditation Timer Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isTimerRunning ? Icons.hourglass_top : Icons.hourglass_empty,
                          color: AppTheme.primaryGold,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatTimer(_secondsRemaining),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(_isTimerRunning ? Icons.pause_circle : Icons.play_circle, color: AppTheme.primaryGold, size: 36),
                      onPressed: _toggleTimer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryGold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                            _secondsRemaining = 120;
                            _isTimerRunning = false;
                          });
                          _timer?.cancel();
                        },
                        child: const Text('Back', style: TextStyle(color: AppTheme.primaryGold)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
                      child: Text(_currentStep < _steps.length - 1 ? 'Next Step' : 'Complete Prayer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
