import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/auth/presentation/caregiver_auth_screen.dart';
import 'package:sunsafe_checkin/features/auth/presentation/senior_auth_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Onboarding entry point: "Who is using this phone?"
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.seniorBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                '☀️ SunSafe\nCheck-In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.seniorPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Who is using this phone?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: kSeniorMinFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.seniorTextPrimary,
                ),
              ),
              const Spacer(flex: 2),
              _RoleButton(
                label: 'Me — Senior Mode',
                subtitle: 'Simple daily check-in',
                icon: Icons.wb_sunny_outlined,
                onTap: () => _navigateToAuth(context, UserRole.senior),
              ),
              const SizedBox(height: 20),
              _RoleButton(
                label: 'My Parent — Caregiver Mode',
                subtitle: 'Monitor & send greetings',
                icon: Icons.family_restroom,
                onTap: () => _navigateToAuth(context, UserRole.caregiver),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, UserRole role) {
    final screen = role == UserRole.senior
        ? const SeniorAuthScreen()
        : const CaregiverAuthScreen();

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.seniorSurface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: kSeniorMinTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Icon(icon, size: 40, color: AppColors.seniorPrimary),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: kSeniorMinFontSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.seniorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.seniorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.seniorTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
