import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';

class WizardStepHeader extends StatelessWidget {
  const WizardStepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    this.subtitle,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of $totalSteps',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge),
        ],
        const SizedBox(height: AppSpacing.lg),
        LinearProgressIndicator(
          value: step / totalSteps,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
