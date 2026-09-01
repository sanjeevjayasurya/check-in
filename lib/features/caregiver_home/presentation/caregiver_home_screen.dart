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
import 'package:sunsafe_checkin/core/utils/check_in_status.dart';
import 'package:sunsafe_checkin/core/widgets/quick_action_tile.dart';
import 'package:sunsafe_checkin/core/widgets/status_pill.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/caregiver_home/data/caregiver_alert_monitor.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/ai_digest_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/alert_settings_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/caregiver_account_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/send_greeting_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/senior_voice_notes_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/providers/caregiver_providers.dart';
import 'package:sunsafe_checkin/features/paywall/presentation/paywall_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class CaregiverHomeScreen extends ConsumerStatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  ConsumerState<CaregiverHomeScreen> createState() =>
      _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends ConsumerState<CaregiverHomeScreen> {
  CaregiverAlertMonitor? _alertMonitor;

  @override
  void initState() {
    super.initState();
    _alertMonitor = ref.read(caregiverAlertMonitorProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCaregiver());
  }

  Future<void> _initializeCaregiver() async {
    final user = await ref.read(currentAppUserProvider.future);
    if (user == null) return;

    await ref.read(userProfileRepositoryProvider).saveFcmToken(user.uid);

    final family = ref.read(currentFamilyProvider).valueOrNull;
    if (family != null) {
      _alertMonitor?.startMonitoring(family);
    }
  }

  @override
  void dispose() {
    _alertMonitor?.dispose();
    super.dispose();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      RolePageRoute<void>(role: UserRole.caregiver, builder: (_) => screen),
    );
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family code copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentFamilyProvider, (previous, next) {
      final family = next.valueOrNull;
      if (family != null) {
        _alertMonitor?.startMonitoring(family);
      }
    });

    final familyAsync = ref.watch(currentFamilyProvider);
    final checkInAsync = ref.watch(latestCheckInProvider);
    final telemetryAsync = ref.watch(latestTelemetryProvider);
    final premiumAsync = ref.watch(premiumStatusProvider);

    final family = familyAsync.valueOrNull;
    final checkIn = checkInAsync.valueOrNull;
    final telemetry = telemetryAsync.valueOrNull;
    final isPremium = premiumAsync.valueOrNull ?? false;
    final seniorName = family?.seniorDisplayName ?? 'Parent';

    final status = CheckInStatusHelper.resolve(
      todayCheckIn: checkIn,
      deadlineHour: family?.alertSettings.deadlineHour ??
          AppConstants.defaultCheckInDeadlineHour,
      deadlineMinute: family?.alertSettings.deadlineMinute ??
          AppConstants.defaultCheckInDeadlineMinute,
    );

    final (pillLabel, pillVariant, pillIcon) = switch (status) {
      ParentCheckInStatus.checkedIn => (
          'Checked in · ${DateFormat.jm().format(checkIn!.timestamp)}',
          StatusPillVariant.success,
          Icons.check_circle,
        ),
      ParentCheckInStatus.approachingDeadline => (
          'No check-in yet — deadline soon',
          StatusPillVariant.warning,
          Icons.schedule,
        ),
      ParentCheckInStatus.missed => (
          'Missed check-in today',
          StatusPillVariant.error,
          Icons.warning_amber,
        ),
      ParentCheckInStatus.unknown => (
          'Waiting for check-in',
          StatusPillVariant.neutral,
          Icons.hourglass_empty,
        ),
    };

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Is $seniorName okay?'),
          actions: [
            IconButton(
              tooltip: 'Account',
              icon: const Icon(Icons.person),
              onPressed: () => _push(const CaregiverAccountScreen()),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              AppColors.caregiverPrimary.withValues(alpha: 0.15),
                          child: Text(
                            seniorName.characters.first.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.caregiverPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            seniorName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StatusPill(label: pillLabel, variant: pillVariant, icon: pillIcon),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Battery ${telemetry?.batteryLevel ?? '—'}% · ${telemetry == null ? 'Unknown' : telemetry.isStationary ? 'Stationary' : 'Active'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.2,
              children: [
                QuickActionTile(
                  icon: Icons.favorite,
                  label: 'Send love',
                  subtitle: 'Photo or voice',
                  onTap: () => _push(const SendGreetingScreen()),
                ),
                QuickActionTile(
                  icon: Icons.mic,
                  label: 'Voice notes',
                  subtitle: 'Listen free',
                  onTap: () => _push(const SeniorVoiceNotesScreen()),
                ),
                QuickActionTile(
                  icon: Icons.notifications_active,
                  label: 'Alerts',
                  onTap: () => _push(const AlertSettingsScreen()),
                ),
                QuickActionTile(
                  icon: Icons.auto_awesome,
                  label: 'Family digest',
                  subtitle: isPremium ? 'AI summary' : 'Premium',
                  isLocked: !isPremium,
                  onTap: () {
                    if (isPremium) {
                      _push(const AiDigestScreen());
                    } else {
                      _push(const PaywallScreen());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Today', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (checkIn != null)
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.statusSuccessFg),
                title: Text('$seniorName checked in'),
                subtitle: Text(DateFormat.jm().format(checkIn.timestamp)),
              )
            else
              const ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text('No check-in yet today'),
              ),
            if (family != null) ...[
              const Divider(),
              ListTile(
                title: const Text('Family invite code'),
                subtitle: Text(family.inviteCode),
                trailing: TextButton(
                  onPressed: () => _copyInviteCode(family.inviteCode),
                  child: const Text('Copy'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
