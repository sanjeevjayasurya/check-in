import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_theme.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Caregiver sign-in and registration with family invite code generation.
class CaregiverAuthScreen extends ConsumerStatefulWidget {
  const CaregiverAuthScreen({super.key, this.isSignUp = false});

  final bool isSignUp;

  @override
  ConsumerState<CaregiverAuthScreen> createState() => _CaregiverAuthScreenState();
}

class _CaregiverAuthScreenState extends ConsumerState<CaregiverAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _generatedInviteCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
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

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _generatedInviteCode = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      if (widget.isSignUp) {
        final result = await repo.signUpCaregiver(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isEmpty
              ? 'Caregiver'
              : _nameController.text.trim(),
        );
        setState(() => _generatedInviteCode = result.family.inviteCode);
      } else {
        await repo.signInCaregiver(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      ref.invalidate(currentAppUserProvider);
      if (!mounted) return;

      if (_generatedInviteCode == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AuthGate()),
          (_) => false,
        );
      }
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
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isSignUp ? 'Create Caregiver Account' : 'Caregiver Sign In'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (_generatedInviteCode != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: AppColors.caregiverPrimary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Share this code with your parent:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _generatedInviteCode!,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isSignUp ? 'Create Account' : 'Sign In'),
              ),
              if (_generatedInviteCode != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
                      (_) => false,
                    );
                  },
                  child: const Text('Go to Dashboard'),
                ),
              if (!widget.isSignUp) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithApple,
                  child: const Text('Sign in with Apple'),
                ),
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const CaregiverAuthScreen(isSignUp: true),
                            ),
                          );
                        },
                  child: const Text('Create New Account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
