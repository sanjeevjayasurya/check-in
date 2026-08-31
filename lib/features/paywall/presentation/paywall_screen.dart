import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/services/revenuecat_service.dart';

/// RevenueCat paywall unlocking AI Digest and Voice Sentiment Tracking.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('SunSafe Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Unlock Premium Care',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${AppConstants.premiumMonthlyPrice.toStringAsFixed(2)}/month',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const _FeatureTile(
              title: 'AI Daily Digest',
              description:
                  'Turn family group chat updates into warm 2-sentence summaries.',
            ),
            const _FeatureTile(
              title: 'Voice Sentiment Tracking',
              description:
                  'Understand how your parent is feeling from voice notes.',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _subscribe(context, ref),
              child: const Text('Subscribe'),
            ),
            TextButton(
              onPressed: () async {
                await RevenueCatService.restorePurchases();
                ref.invalidate(premiumStatusProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Restore Purchases'),
            ),
          ],
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
              'Subscription unavailable. Configure RevenueCat offerings.',
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
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(title),
      subtitle: Text(description),
    );
  }
}
