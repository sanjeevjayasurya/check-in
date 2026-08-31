import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Senior onboarding via 6-digit family invite code (anonymous auth).
class SeniorAuthScreen extends ConsumerStatefulWidget {
  const SeniorAuthScreen({super.key});

  @override
  ConsumerState<SeniorAuthScreen> createState() => _SeniorAuthScreenState();
}

class _SeniorAuthScreenState extends ConsumerState<SeniorAuthScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinFamily() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).joinFamilyAsSenior(
            inviteCode: _codeController.text.trim(),
          );
      ref.invalidate(currentAppUserProvider);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        appBar: AppBar(title: const Text('Join Your Family')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the 6-digit code from your caregiver',
                style: TextStyle(fontSize: kSeniorMinFontSize),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: AppConstants.inviteCodeLength,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinFamily,
                child: _isLoading
                    ? const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
