import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/core/widgets/role_selection_card.dart';
import 'package:sunsafe_checkin/features/onboarding/presentation/caregiver_onboarding_screen.dart';
import 'package:sunsafe_checkin/features/onboarding/presentation/senior_onboarding_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Onboarding entry point: "Who is using this phone?"
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        backgroundColor: AppColors.seniorCreamBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'SunSafe Check-In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.seniorCreamTextPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  '☀️',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Who is using this phone?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: kSeniorMinFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.seniorCreamTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Your parent controls what they share.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.seniorCreamTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.seniorError,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                RoleSelectionCard(
                  label: 'Me — Senior Mode',
                  subtitle: 'Simple daily check-in',
                  icon: Icons.wb_sunny_outlined,
                  isSeniorRole: true,
                  onTap: () => _navigateToOnboarding(context, UserRole.senior),
                ),
                const SizedBox(height: AppSpacing.lg),
                RoleSelectionCard(
                  label: 'My Parent — Caregiver Mode',
                  subtitle: 'Monitor and send love',
                  icon: Icons.family_restroom,
                  isSeniorRole: false,
                  onTap: () => _navigateToOnboarding(context, UserRole.caregiver),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context, UserRole role) {
    final screen = role == UserRole.senior
        ? const SeniorOnboardingScreen()
        : const CaregiverOnboardingScreen();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
