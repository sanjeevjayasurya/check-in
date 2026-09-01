import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Your family loves you!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A message from your family',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (greeting!.message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                greeting!.message!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (greeting!.photoUrl != null) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  greeting!.photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.photo, size: 64),
                ),
              ),
            ],
            if (greeting!.voiceUrl != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () =>
                    audioPlayer.play(UrlSource(greeting!.voiceUrl!)),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play voice message'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, kSeniorMinTouchTarget),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
