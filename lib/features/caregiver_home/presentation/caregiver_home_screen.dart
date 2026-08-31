import 'package:flutter/material.dart';

/// Caregiver dashboard — real-time status, greetings, AI digest.
/// Full Firestore streams in Phase 4.
class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parent Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const _StatusRow(
                    icon: Icons.check_circle_outline,
                    label: 'Last check-in',
                    value: 'Waiting for data…',
                  ),
                  const _StatusRow(
                    icon: Icons.battery_std,
                    label: 'Battery',
                    value: '—',
                  ),
                  const _StatusRow(
                    icon: Icons.directions_run,
                    label: 'Status',
                    value: 'Unknown',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Send Daily Greeting'),
            subtitle: const Text('Photo or 15-second voice note'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('AI Family Digest'),
            subtitle: const Text('Premium — \$7.99/month'),
            trailing: const Icon(Icons.lock),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Alert Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
