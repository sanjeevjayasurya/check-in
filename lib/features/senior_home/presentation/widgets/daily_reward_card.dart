import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/models/family_greeting.dart';

/// Shows the caregiver's daily photo/voice/message reward after check-in.
class DailyRewardCard extends StatelessWidget {
  const DailyRewardCard({
    super.key,
    required this.greeting,
    required this.audioPlayer,
  });

  final FamilyGreeting? greeting;
  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    if (greeting == null || !greeting!.hasContent) {
      return Card(
        color: AppColors.seniorSurface,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Your family loves you! ☀️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: kSeniorMinFontSize),
          ),
        ),
      );
    }

    return Card(
      color: AppColors.seniorSurface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'A message from your family 💛',
              style: TextStyle(
                fontSize: kSeniorMinFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (greeting!.message != null) ...[
              const SizedBox(height: 12),
              Text(
                greeting!.message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: kSeniorMinFontSize),
              ),
            ],
            if (greeting!.photoUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  greeting!.photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 64),
                ),
              ),
            ],
            if (greeting!.voiceUrl != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => audioPlayer.play(UrlSource(greeting!.voiceUrl!)),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Voice Message'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
