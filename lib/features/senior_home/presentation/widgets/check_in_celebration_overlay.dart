import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

class CheckInCelebrationOverlay extends StatelessWidget {
  const CheckInCelebrationOverlay({
    super.key,
    required this.caregiverName,
  });

  final String caregiverName;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.seniorPrimary.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 120, color: AppColors.seniorOnPrimary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$caregiverName knows you are okay',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: kSeniorHeadlineFontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.seniorOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
