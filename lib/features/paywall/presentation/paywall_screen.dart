import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/services/revenuecat_service.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('SunSafe Premium')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Care with confidence',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Premium helps you understand how your parent is doing — without more phone calls.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _BenefitCard(
                title: 'AI family digest',
                description:
                    'Turn group chat updates into a warm two-sentence summary.',
                icon: Icons.auto_awesome,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _BenefitCard(
                title: 'Voice sentiment',
                description:
                    'Understand mood and tone from your parent\'s voice notes.',
                icon: Icons.psychology,
              ),
              const Spacer(),
              Text(
                'From \$${AppConstants.premiumMonthlyPrice.toStringAsFixed(2)}/month',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryCta(
                label: 'Subscribe',
                onPressed: () => _subscribe(context, ref),
              ),
              TextButton(
                onPressed: () async {
                  await RevenueCatService.restorePurchases();
                  ref.invalidate(premiumStatusProvider);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Restore purchases'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue with free features'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe(BuildContext context, WidgetRef ref) async {
    final offerings = await RevenueCatService.getOfferings();
    final packages = offerings?.current?.availablePackages ?? [];

    if (packages.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Subscriptions are not available yet. Try again later.',
            ),
          ),
        );
      }
      return;
    }

    try {
      await RevenueCatService.purchasePackage(packages.first);
      ref.invalidate(premiumStatusProvider);
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    }
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
