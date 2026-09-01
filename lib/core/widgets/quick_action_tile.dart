import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isLocked = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.caregiverSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.caregiverBackground),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.caregiverPrimary, size: 28),
                  const Spacer(),
                  if (isLocked)
                    const Icon(Icons.lock, size: 18, color: AppColors.caregiverTextSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
