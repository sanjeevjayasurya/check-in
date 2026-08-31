import 'package:flutter/material.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/features/caregiver_home/presentation/caregiver_home_screen.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Placeholder caregiver auth — full Firebase auth in Phase 2.
class CaregiverAuthScreen extends StatelessWidget {
  const CaregiverAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Caregiver Sign In')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const CaregiverHomeScreen(),
                    ),
                  );
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Sign in with Apple'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
