import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

enum StatusPillVariant { success, warning, error, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
  });

  final String label;
  final StatusPillVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      StatusPillVariant.success => (
          AppColors.statusSuccessBg,
          AppColors.statusSuccessFg,
        ),
      StatusPillVariant.warning => (
          AppColors.statusWarningBg,
          AppColors.statusWarningFg,
        ),
      StatusPillVariant.error => (
          AppColors.statusErrorBg,
          AppColors.statusErrorFg,
        ),
      StatusPillVariant.neutral => (
          AppColors.caregiverBackground,
          AppColors.caregiverTextSecondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
