import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';

/// Senior home — zero navigation bars, single-tap check-in.
/// Full Firestore integration in Phase 3.
class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  bool _checkedIn = false;

  Future<void> _handleCheckIn() async {
    await HapticFeedback.heavyImpact();
    setState(() => _checkedIn = true);
    // Firestore write + reward fetch — Phase 3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                _checkedIn ? 'Great job! ☀️' : 'Good morning!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(flex: 2),
              if (_checkedIn)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.seniorSuccess,
                  size: 120,
                )
              else
                ElevatedButton(
                  onPressed: _handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.seniorPrimary,
                    foregroundColor: AppColors.seniorOnPrimary,
                  ),
                  child: const Text("I'M OKAY TODAY ☀️"),
                ),
              const Spacer(flex: 2),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic, size: 32),
                label: const Text('Leave a Voice Note'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
