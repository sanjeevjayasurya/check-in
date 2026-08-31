import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/senior_home/presentation/senior_home_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Placeholder senior auth — full Firebase auth in Phase 2.
class SeniorAuthScreen extends StatelessWidget {
  const SeniorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        appBar: AppBar(title: const Text('Senior Sign In')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your family invite code',
                style: TextStyle(fontSize: kSeniorMinFontSize),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(fontSize: kSeniorMinFontSize),
                decoration: const InputDecoration(
                  hintText: '6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const SeniorHomeScreen(),
                    ),
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
