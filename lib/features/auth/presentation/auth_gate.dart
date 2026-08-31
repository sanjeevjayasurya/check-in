import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/features/auth/presentation/role_selection_screen.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/caregiver_home_screen.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/senior_home_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Routes authenticated users to the correct home screen by role.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);

    return appUserAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => RoleSelectionScreen(errorMessage: '$error'),
      data: (user) {
        if (user == null) {
          return const RoleSelectionScreen();
        }

        switch (user.role) {
          case UserRole.senior:
            return const SeniorHomeScreen();
          case UserRole.caregiver:
            return const CaregiverHomeScreen();
        }
      },
    );
  }
}
