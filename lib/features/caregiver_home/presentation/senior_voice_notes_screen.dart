import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/navigation/role_page_route.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/widgets/voice_note_row.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/voice_sentiment_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/providers/voice_note_providers.dart';
import 'package:sunsafe_checkin/features/paywall/presentation/paywall_screen.dart';
import 'package:sunsafe_checkin/models/senior_voice_note.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class SeniorVoiceNotesScreen extends ConsumerStatefulWidget {
  const SeniorVoiceNotesScreen({super.key});

  @override
  ConsumerState<SeniorVoiceNotesScreen> createState() =>
      _SeniorVoiceNotesScreenState();
}

class _SeniorVoiceNotesScreenState extends ConsumerState<SeniorVoiceNotesScreen> {
  final _player = AudioPlayer();
  String? _playingUrl;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(SeniorVoiceNote note) async {
    if (_playingUrl == note.voiceUrl) {
      await _player.stop();
      setState(() => _playingUrl = null);
      return;
    }

    await _player.play(UrlSource(note.voiceUrl));
    setState(() => _playingUrl = note.voiceUrl);
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(seniorVoiceNotesProvider);
    final isPremium = ref.watch(premiumStatusProvider).valueOrNull ?? false;

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Parent Voice Notes')),
        body: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (notes) {
            if (notes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No voice notes yet from your parent.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final note = notes[index];
                final timeLabel = DateFormat.yMMMd().add_jm().format(note.createdAt);
                return VoiceNoteRow(
                  title: 'Voice note',
                  subtitle: timeLabel,
                  isPlaying: _playingUrl == note.voiceUrl,
                  isPremium: isPremium,
                  onPlay: () => _togglePlay(note),
                  onAnalyze: () {
                    if (isPremium) {
                      Navigator.of(context).push(
                        RolePageRoute<void>(
                          role: UserRole.caregiver,
                          builder: (_) => VoiceSentimentScreen(
                            audioPath: note.voiceUrl,
                            isRemoteUrl: true,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        RolePageRoute<void>(
                          role: UserRole.caregiver,
                          builder: (_) => const PaywallScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
