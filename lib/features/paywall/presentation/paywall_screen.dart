import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/services/revenuecat_service.dart';

/// RevenueCat paywall for premium features.
/// Full purchase flow in Phase 6.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                final offerings = await RevenueCatService.getOfferings();
                if (offerings == null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to load subscription options.'),
                    ),
                  );
                }
              },
              child: const Text('Subscribe'),
            ),
            TextButton(
              onPressed: () => RevenueCatService.restorePurchases(),
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
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
