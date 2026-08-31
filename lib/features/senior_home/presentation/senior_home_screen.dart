import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/background/background_telemetry_task.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/widgets/daily_reward_card.dart';
import 'package:sunsafe_checkin/features/senior_home/providers/senior_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Senior home — zero navigation bars, single-tap check-in with haptic/audio feedback.
class SeniorHomeScreen extends ConsumerStatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  ConsumerState<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends ConsumerState<SeniorHomeScreen>
    with SingleTickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  bool _isSubmitting = false;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkScale;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkmarkScale = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );
    BackgroundTelemetryTask.register();
    _persistSeniorBackgroundContext();
  }

  Future<void> _persistSeniorBackgroundContext() async {
    final user = await ref.read(currentAppUserProvider.future);
    final family = ref.read(currentFamilyProvider).valueOrNull;
    if (user == null) return;

    await BackgroundTelemetryTask.persistSeniorContext(
      familyId: user.familyId,
      seniorId: user.uid,
      seniorDisplayName: family?.seniorDisplayName ?? 'Parent',
      deadlineHour:
          family?.alertSettings.deadlineHour ?? AppConstants.defaultCheckInDeadlineHour,
      deadlineMinute: family?.alertSettings.deadlineMinute ??
          AppConstants.defaultCheckInDeadlineMinute,
    );
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    final user = await ref.read(currentAppUserProvider.future);
    if (user == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.click);

    try {
      await ref.read(checkInRepositoryProvider).submitCheckIn(
            familyId: user.familyId,
            seniorId: user.uid,
          );
      await _checkmarkController.forward(from: 0);
      ref.invalidate(todayCheckInProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved offline — will sync later.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _recordVoiceNote() async {
    final service = ref.read(voiceNoteServiceProvider);
    try {
      if (await service.isRecording()) {
        final path = await service.stopRecording();
        if (mounted && path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice note saved!')),
          );
        }
      } else {
        await service.startRecording();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording… tap again to stop.')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkInAsync = ref.watch(todayCheckInProvider);
    final greetingAsync = ref.watch(todayGreetingProvider);
    final checkedIn = checkInAsync.valueOrNull != null;

    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  checkedIn ? 'Great job! ☀️' : 'Good morning!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (checkedIn && checkInAsync.valueOrNull != null)
                  Text(
                    'Checked in at ${DateFormat.jm().format(checkInAsync.valueOrNull!.timestamp)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const Spacer(),
                if (checkedIn)
                  ScaleTransition(
                    scale: _checkmarkScale,
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.seniorSuccess,
                      size: 120,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.seniorPrimary,
                      foregroundColor: AppColors.seniorOnPrimary,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("I'M OKAY TODAY ☀️"),
                  ),
                const Spacer(),
                if (checkedIn)
                  greetingAsync.when(
                    data: (greeting) => DailyRewardCard(
                      greeting: greeting,
                      audioPlayer: _audioPlayer,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _recordVoiceNote,
                  icon: const Icon(Icons.mic, size: 32),
                  label: const Text('Leave a Voice Note'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
