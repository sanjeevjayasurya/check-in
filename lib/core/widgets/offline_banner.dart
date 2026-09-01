import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: AppColors.statusWarningBg,
      content: Text(
        message ?? 'Saved offline — will send when you\'re back online.',
        style: const TextStyle(color: AppColors.statusWarningFg),
      ),
      leading: const Icon(Icons.cloud_off, color: AppColors.statusWarningFg),
      actions: const [SizedBox.shrink()],
    );
  }
}
