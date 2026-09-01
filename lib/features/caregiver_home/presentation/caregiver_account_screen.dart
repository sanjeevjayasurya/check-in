import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class CaregiverAccountScreen extends ConsumerWidget {
  const CaregiverAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);
    final family = ref.watch(currentFamilyProvider).valueOrNull;

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Account & Family')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ListTile(
              title: const Text('Your profile'),
              subtitle: Text(userAsync.valueOrNull?.displayName ?? 'Caregiver'),
            ),
            ListTile(
              title: const Text('Parent name'),
              subtitle: Text(family?.seniorDisplayName ?? 'Not linked yet'),
            ),
            ListTile(
              title: const Text('Family invite code'),
              subtitle: Text(family?.inviteCode ?? '—'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
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
