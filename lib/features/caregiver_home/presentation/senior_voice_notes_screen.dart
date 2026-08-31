import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/voice_sentiment_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/providers/voice_note_providers.dart';
import 'package:sunsafe_checkin/features/paywall/presentation/paywall_screen.dart';
import 'package:sunsafe_checkin/models/senior_voice_note.dart';

/// Lists senior voice notes with optional premium sentiment analysis.
class SeniorVoiceNotesScreen extends ConsumerWidget {
  const SeniorVoiceNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(seniorVoiceNotesProvider);
    final isPremium = ref.watch(premiumStatusProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Voice Notes')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('No voice notes yet from your parent.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return _VoiceNoteTile(
                note: notes[index],
                isPremium: isPremium,
              );
            },
          );
        },
      ),
    );
  }
}

class _VoiceNoteTile extends StatelessWidget {
  const _VoiceNoteTile({
    required this.note,
    required this.isPremium,
  });

  final SeniorVoiceNote note;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.yMMMd().add_jm().format(note.createdAt);

    return ListTile(
      leading: const Icon(Icons.mic),
      title: Text('Voice note — $timeLabel'),
      subtitle: note.sentiment != null
          ? Text('Sentiment: ${note.sentiment}')
          : const Text('Tap to analyze sentiment (Premium)'),
      trailing: Icon(isPremium ? Icons.psychology : Icons.lock),
      onTap: () {
        if (isPremium) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VoiceSentimentScreen(
                audioPath: note.voiceUrl,
                isRemoteUrl: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PaywallScreen(),
            ),
          );
        }
      },
    );
  }
}
