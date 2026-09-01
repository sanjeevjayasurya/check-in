import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/navigation/role_page_route.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/core/utils/greeting_utils.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/offline_banner.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/background/background_telemetry_task.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/senior_settings_screen.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/widgets/check_in_celebration_overlay.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/widgets/daily_reward_card.dart';
import 'package:sunsafe_checkin/features/senior_home/providers/senior_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';
import 'package:url_launcher/url_launcher.dart';

class SeniorHomeScreen extends ConsumerStatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  ConsumerState<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends ConsumerState<SeniorHomeScreen>
    with SingleTickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  bool _isSubmitting = false;
  bool _isRecording = false;
  bool _showCelebration = false;
  bool _showOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    BackgroundTelemetryTask.register();
    _initializeSeniorSession();
  }

  Future<void> _initializeSeniorSession() async {
    final user = await ref.read(currentAppUserProvider.future);
    if (user == null) return;

    await ref
        .read(checkInRepositoryProvider)
        .syncPendingCheckIns(user.familyId);
    await ref.read(voiceNoteRepositoryProvider).syncPendingVoiceNotes(
          user.familyId,
          user.uid,
        );

    final family = ref.read(currentFamilyProvider).valueOrNull;
    await BackgroundTelemetryTask.persistSeniorContext(
      familyId: user.familyId,
      seniorId: user.uid,
      seniorDisplayName: family?.seniorDisplayName ?? 'Parent',
      deadlineHour: family?.alertSettings.deadlineHour ??
          AppConstants.defaultCheckInDeadlineHour,
      deadlineMinute: family?.alertSettings.deadlineMinute ??
          AppConstants.defaultCheckInDeadlineMinute,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCheckInConfirmation() async {
    await HapticFeedback.heavyImpact();
    try {
      await _audioPlayer.play(AssetSource('sounds/check_in_success.wav'));
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _handleCheckIn() async {
    final user = await ref.read(currentAppUserProvider.future);
    if (user == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await _playCheckInConfirmation();

    try {
      await ref.read(checkInRepositoryProvider).submitCheckIn(
            familyId: user.familyId,
            seniorId: user.uid,
          );
      ref.invalidate(todayCheckInProvider);
      setState(() => _showCelebration = true);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showCelebration = false);
    } catch (error) {
      if (mounted) {
        setState(() => _showOfflineBanner = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
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
        setState(() => _isRecording = false);
        if (path == null) return;

        final user = await ref.read(currentAppUserProvider.future);
        if (user != null) {
          await ref.read(voiceNoteRepositoryProvider).uploadVoiceNote(
                familyId: user.familyId,
                seniorId: user.uid,
                localPath: path,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice note sent to your family!')),
          );
        }
      } else {
        await service.startRecording();
        setState(() => _isRecording = true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    }
  }

  Future<void> _callForHelp() async {
    final family = ref.read(currentFamilyProvider).valueOrNull;
    final contacts = family?.alertSettings.emergencyContacts ?? [];
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contact set yet. Ask your caregiver.'),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need help?'),
        content: Text('Call ${contacts.first}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Call now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final uri = Uri(scheme: 'tel', path: contacts.first);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final checkInAsync = ref.watch(todayCheckInProvider);
    final greetingAsync = ref.watch(todayGreetingProvider);
    final family = ref.watch(currentFamilyProvider).valueOrNull;
    final seniorName = family?.seniorDisplayName ?? 'Friend';
    final checkedIn = checkInAsync.valueOrNull != null;
    final clockText = DateFormat('EEE, MMM d · h:mm a').format(now);
    final greeting = GreetingUtils.timeAwareGreeting(now: now);

    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clockText,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '$greeting, $seniorName',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: () {
                            Navigator.of(context).push(
                              RolePageRoute<void>(
                                role: UserRole.senior,
                                builder: (_) => const SeniorSettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                    if (_showOfflineBanner) const OfflineBanner(),
                    const SizedBox(height: AppSpacing.lg),
                    if (checkedIn)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccessBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.statusSuccessFg),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Checked in at ${DateFormat.jm().format(checkInAsync.valueOrNull!.timestamp)}',
                                style: const TextStyle(
                                  fontSize: kSeniorMinFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.statusSuccessFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      PrimaryCta(
                        label: "I'M OKAY TODAY",
                        size: PrimaryCtaSize.senior,
                        isLoading: _isSubmitting,
                        onPressed: _handleCheckIn,
                        semanticsLabel: 'Check in for today',
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    greetingAsync.when(
                      data: (value) => DailyRewardCard(
                        greeting: value,
                        audioPlayer: _audioPlayer,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: _recordVoiceNote,
                      icon: Icon(
                        _isRecording ? Icons.stop_circle : Icons.mic,
                        size: 32,
                      ),
                      label: Text(
                        _isRecording
                            ? 'Recording… tap to stop'
                            : 'Leave a voice note',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, kSeniorMinTouchTarget),
                        backgroundColor: _isRecording
                            ? AppColors.seniorError
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _callForHelp,
                      icon: const Icon(Icons.phone_in_talk),
                      label: const Text('Need help?'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, kSeniorMinTouchTarget),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showCelebration)
              CheckInCelebrationOverlay(caregiverName: 'Your family'),
          ],
        ),
      ),
    );
  }
}
