import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

enum PrimaryCtaSize { senior, caregiver }

class PrimaryCta extends StatelessWidget {
  const PrimaryCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PrimaryCtaSize.caregiver,
    this.icon,
    this.isLoading = false,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryCtaSize size;
  final IconData? icon;
  final bool isLoading;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isSenior = size == PrimaryCtaSize.senior;
    final height = isSenior ? kSeniorCheckInButtonHeight : 52.0;
    final fontSize = isSenior ? kSeniorHeadlineFontSize : 16.0;

    final child = isLoading
        ? SizedBox(
            height: isSenior ? 32 : 24,
            width: isSenior ? 32 : 24,
            child: CircularProgressIndicator(
              strokeWidth: isSenior ? 3 : 2,
              color: isSenior
                  ? AppColors.seniorOnPrimary
                  : AppColors.caregiverOnPrimary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSenior ? 32 : 22),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSenior
                ? AppColors.seniorPrimary
                : AppColors.caregiverPrimary,
            foregroundColor: isSenior
                ? AppColors.seniorOnPrimary
                : AppColors.caregiverOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSenior ? 20 : 14),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
