import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';

class GreetingCardWidget extends StatelessWidget {
  const GreetingCardWidget({
    super.key,
    required this.fromName,
    required this.message,
    this.photoUrl,
    this.localPhoto,
    this.onPlayVoice,
    this.onViewPhoto,
  });

  final String fromName;
  final String? message;
  final String? photoUrl;
  final File? localPhoto;
  final VoidCallback? onPlayVoice;
  final VoidCallback? onViewPhoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.seniorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.seniorPrimary.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message from $fromName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (localPhoto != null) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  localPhoto!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (photoUrl != null) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (onPlayVoice != null)
                  Expanded(
                    child: PrimaryCta(
                      label: 'Play voice',
                      icon: Icons.volume_up,
                      size: PrimaryCtaSize.caregiver,
                      onPressed: onPlayVoice,
                    ),
                  ),
                if (onPlayVoice != null && onViewPhoto != null)
                  const SizedBox(width: AppSpacing.sm),
                if (onViewPhoto != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewPhoto,
                      icon: const Icon(Icons.photo),
                      label: const Text('See photo'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
