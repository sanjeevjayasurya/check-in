import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/onboarding_providers.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class SeniorSettingsScreen extends ConsumerWidget {
  const SeniorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highContrast = ref.watch(seniorHighContrastProvider);
    final family = ref.watch(currentFamilyProvider).valueOrNull;

    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ListTile(
              title: const Text('Your name'),
              subtitle: Text(family?.seniorDisplayName ?? 'Parent'),
            ),
            SwitchListTile(
              title: const Text('High contrast mode'),
              subtitle: const Text('Easier to read in bright light'),
              value: highContrast,
              onChanged: (value) {
                ref.read(seniorHighContrastProvider.notifier).setHighContrast(value);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Switch user'),
              subtitle: const Text('Hand this phone to someone else'),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.invalidate(currentAppUserProvider);
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const AuthGate()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
