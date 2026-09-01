import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/onboarding_providers.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/core/widgets/wizard_step_header.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class CaregiverOnboardingScreen extends ConsumerStatefulWidget {
  const CaregiverOnboardingScreen({
    super.key,
    this.initialStep = 0,
    this.inviteCode,
  });

  final int initialStep;
  final String? inviteCode;

  @override
  ConsumerState<CaregiverOnboardingScreen> createState() =>
      _CaregiverOnboardingScreenState();
}

class _CaregiverOnboardingScreenState
    extends ConsumerState<CaregiverOnboardingScreen> {
  late final PageController _pageController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = true;
  String? _inviteCode;
  int _deadlineHour = AlertSettings.defaults.deadlineHour;
  int _deadlineMinute = AlertSettings.defaults.deadlineMinute;

  @override
  void initState() {
    super.initState();
    _inviteCode = widget.inviteCode;
    _pageController = PageController(initialPage: widget.initialStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isSignUp) {
        final result = await repo.signUpCaregiver(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isEmpty
              ? 'Caregiver'
              : _nameController.text.trim(),
        );
        setState(() => _inviteCode = result.family.inviteCode);
      } else {
        await repo.signInCaregiver(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final user = await ref.read(currentAppUserProvider.future);
        if (user != null) {
          final family =
              await ref.read(authRepositoryProvider).getFamily(user.familyId);
          _inviteCode = family?.inviteCode;
        }
      }
      ref.invalidate(currentAppUserProvider);
      await _nextPage();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _copyInviteCode() async {
    if (_inviteCode == null) return;
    await Clipboard.setData(ClipboardData(text: _inviteCode!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family code copied!')),
      );
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _deadlineHour, minute: _deadlineMinute),
    );
    if (picked != null) {
      setState(() {
        _deadlineHour = picked.hour;
        _deadlineMinute = picked.minute;
      });
    }
  }

  Future<void> _saveDeadlineAndFinish() async {
    setState(() => _isLoading = true);
    try {
      final family = ref.read(currentFamilyProvider).valueOrNull;
      if (family != null) {
        await ref.read(caregiverRepositoryProvider).updateAlertSettings(
              familyId: family.id,
              settings: family.alertSettings.copyWith(
                deadlineHour: _deadlineHour,
                deadlineMinute: _deadlineMinute,
              ),
            );
      }
      final prefs = await ref.read(onboardingPrefsProvider.future);
      await prefs.setCaregiverOnboardingComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineLabel =
        '${_deadlineHour.toString().padLeft(2, '0')}:${_deadlineMinute.toString().padLeft(2, '0')}';

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Caregiver Setup')),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 1,
                    totalSteps: 4,
                    title: 'Know Mom is okay',
                    subtitle:
                        'Without calling every day. SunSafe keeps you gently in the loop.',
                  ),
                  const Spacer(),
                  PrimaryCta(label: 'Continue', onPressed: _nextPage),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WizardStepHeader(
                    step: 2,
                    totalSteps: 4,
                    title: _isSignUp ? 'Create your account' : 'Sign in',
                    subtitle: 'One caregiver account per family.',
                  ),
                  if (_isSignUp)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (_isSignUp) const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : 'Need an account? Sign up',
                    ),
                  ),
                  const Spacer(),
                  PrimaryCta(
                    label: _isSignUp ? 'Create account' : 'Sign in',
                    isLoading: _isLoading,
                    onPressed: _submitAuth,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 3,
                    totalSteps: 4,
                    title: 'Share this code with your parent',
                    subtitle: 'They enter it once on their phone to join your family.',
                  ),
                  if (_inviteCode != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          _inviteCode!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 10,
                          ),
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _copyInviteCode,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy code'),
                  ),
                  const Spacer(),
                  PrimaryCta(label: 'Continue', onPressed: _nextPage),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 4,
                    totalSteps: 4,
                    title: 'When should we alert you?',
                    subtitle: 'If your parent has not checked in by this time.',
                  ),
                  ListTile(
                    title: const Text('Check-in deadline'),
                    subtitle: Text(deadlineLabel),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickDeadline,
                  ),
                  const Spacer(),
                  PrimaryCta(
                    label: 'Go to dashboard',
                    isLoading: _isLoading,
                    onPressed: _saveDeadlineAndFinish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
