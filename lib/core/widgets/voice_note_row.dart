import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

class VoiceNoteRow extends StatelessWidget {
  const VoiceNoteRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlay,
    this.onAnalyze,
    this.isPremium = false,
    this.isPlaying = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPlay;
  final VoidCallback? onAnalyze;
  final bool isPremium;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.caregiverPrimary.withValues(alpha: 0.12),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.caregiverPrimary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Play voice note',
              onPressed: onPlay,
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            ),
            if (onAnalyze != null)
              IconButton(
                tooltip: isPremium ? 'Analyze sentiment' : 'Premium sentiment',
                onPressed: onAnalyze,
                icon: Icon(
                  isPremium ? Icons.psychology : Icons.lock,
                  color: isPremium
                      ? AppColors.caregiverPrimary
                      : AppColors.caregiverTextSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
