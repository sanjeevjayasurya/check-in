import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/onboarding_providers.dart';
import 'package:sunsafe_checkin/features/auth/presentation/role_selection_screen.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/caregiver_home_screen.dart';
import 'package:sunsafe_checkin/features/onboarding/presentation/caregiver_onboarding_screen.dart';
import 'package:sunsafe_checkin/features/onboarding/presentation/senior_onboarding_screen.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/senior_home_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Routes authenticated users to the correct home screen by role.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);
    final onboardingPrefsAsync = ref.watch(onboardingPrefsProvider);

    return appUserAsync.when(
      loading: () => onboardingPrefsAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const RoleSelectionScreen(),
        data: (_) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => RoleSelectionScreen(errorMessage: '$error'),
      data: (user) {
        if (user == null) {
          return const RoleSelectionScreen();
        }

        return onboardingPrefsAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => _homeForRole(user.role),
          data: (prefs) {
            switch (user.role) {
              case UserRole.senior:
                if (!prefs.seniorOnboardingComplete) {
                  return const SeniorOnboardingScreen(initialStep: 2);
                }
                return const SeniorHomeScreen();
              case UserRole.caregiver:
                if (!prefs.caregiverOnboardingComplete) {
                  return const CaregiverOnboardingScreen(initialStep: 2);
                }
                return const CaregiverHomeScreen();
            }
          },
        );
      },
    );
  }

  Widget _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.senior:
        return const SeniorHomeScreen();
      case UserRole.caregiver:
        return const CaregiverHomeScreen();
    }
  }
}
