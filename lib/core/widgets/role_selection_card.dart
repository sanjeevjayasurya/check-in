import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isSeniorRole,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSeniorRole;

  @override
  Widget build(BuildContext context) {
    final background = isSeniorRole
        ? AppColors.seniorPrimary.withValues(alpha: 0.25)
        : AppColors.caregiverPrimary.withValues(alpha: 0.12);
    final border = isSeniorRole
        ? AppColors.seniorPrimary
        : AppColors.caregiverPrimary;
    final textColor = isSeniorRole
        ? AppColors.seniorTextPrimary
        : AppColors.caregiverTextPrimary;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: kSeniorMinTouchTarget * 2),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                Icon(icon, size: 40, color: border),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: kSeniorMinFontSize,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
