import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/ai_digest_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/alert_settings_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/send_greeting_screen.dart';
import 'package:sunsafe_checkin/features/caregiver_home/providers/caregiver_providers.dart';
import 'package:sunsafe_checkin/features/paywall/presentation/paywall_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Caregiver dashboard with real-time parent status from Firestore streams.
class CaregiverHomeScreen extends ConsumerWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(currentFamilyProvider);
    final checkInAsync = ref.watch(latestCheckInProvider);
    final telemetryAsync = ref.watch(latestTelemetryProvider);
    final premiumAsync = ref.watch(premiumStatusProvider);

    final family = familyAsync.valueOrNull;
    final checkIn = checkInAsync.valueOrNull;
    final telemetry = telemetryAsync.valueOrNull;
    final isPremium = premiumAsync.valueOrNull ?? false;

    final checkInText = checkIn != null
        ? '${family?.seniorDisplayName ?? 'Parent'} checked in at ${DateFormat.jm().format(checkIn.timestamp)}'
        : 'No check-in yet today';

    final batteryText =
        telemetry != null ? '${telemetry.batteryLevel}%' : '—';

    final statusText = telemetry == null
        ? 'Unknown'
        : telemetry.isStationary
            ? 'Stationary'
            : 'Active';

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Caregiver Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.invalidate(currentAppUserProvider);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (family != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Family code: ${family.inviteCode}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parent Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _StatusRow(
                      icon: Icons.check_circle_outline,
                      label: 'Last check-in',
                      value: checkInText,
                    ),
                    _StatusRow(
                      icon: Icons.battery_std,
                      label: 'Battery',
                      value: batteryText,
                    ),
                    _StatusRow(
                      icon: Icons.directions_run,
                      label: 'Status',
                      value: statusText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Send Daily Greeting'),
              subtitle: const Text('Photo or 15-second voice note'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SendGreetingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('AI Family Digest'),
              subtitle: Text(
                isPremium ? 'Generate warm summaries' : 'Premium — \$7.99/month',
              ),
              trailing: Icon(isPremium ? Icons.chevron_right : Icons.lock),
              onTap: () {
                if (isPremium) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AiDigestScreen(),
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
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Alert Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AlertSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
