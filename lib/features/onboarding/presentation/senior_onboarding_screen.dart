import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/onboarding_providers.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/core/widgets/wizard_step_header.dart';
import 'package:sunsafe_checkin/features/auth/presentation/auth_gate.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class SeniorOnboardingScreen extends ConsumerStatefulWidget {
  const SeniorOnboardingScreen({super.key, this.initialStep = 0});

  final int initialStep;

  @override
  ConsumerState<SeniorOnboardingScreen> createState() =>
      _SeniorOnboardingScreenState();
}

class _SeniorOnboardingScreenState extends ConsumerState<SeniorOnboardingScreen> {
  late final PageController _pageController;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _joinFamily() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).joinFamilyAsSenior(
            inviteCode: _codeController.text.trim(),
          );
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

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await _nextPage();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentAppUserProvider.future);
      if (user != null) {
        await ref.read(caregiverRepositoryProvider).updateSeniorDisplayName(
              familyId: user.familyId,
              displayName: name,
            );
        ref.invalidate(currentFamilyProvider);
      }
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

  Future<void> _practiceCheckIn() async {
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That is the sound your family will hear!')),
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await ref.read(onboardingPrefsProvider.future);
    await prefs.setSeniorOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.senior,
      child: Scaffold(
        appBar: AppBar(title: const Text('Welcome')),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomeStep(onContinue: _nextPage),
            _CodeStep(
              controller: _codeController,
              isLoading: _isLoading,
              onContinue: _joinFamily,
            ),
            _NameStep(
              controller: _nameController,
              isLoading: _isLoading,
              onContinue: _saveName,
            ),
            _PracticeStep(
              onPractice: _practiceCheckIn,
              onComplete: _completeOnboarding,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WizardStepHeader(
            step: 1,
            totalSteps: 4,
            title: 'Tap once each day',
            subtitle:
                'So your family knows you are okay — without phone calls every morning.',
          ),
          const Spacer(),
          const Icon(Icons.wb_sunny, size: 96),
          const Spacer(),
          PrimaryCta(
            label: 'Get started',
            size: PrimaryCtaSize.senior,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.controller,
    required this.isLoading,
    required this.onContinue,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WizardStepHeader(
            step: 2,
            totalSteps: 4,
            title: 'Enter your family code',
            subtitle: 'Ask your caregiver for the 6-digit code.',
          ),
          TextField(
            controller: controller,
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
          PrimaryCta(
            label: 'Join family',
            size: PrimaryCtaSize.senior,
            isLoading: isLoading,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.controller,
    required this.isLoading,
    required this.onContinue,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WizardStepHeader(
            step: 3,
            totalSteps: 4,
            title: 'What should we call you?',
            subtitle: 'Your family will see this name on their dashboard.',
          ),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              hintText: 'Margaret',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const Spacer(),
          PrimaryCta(
            label: 'Continue',
            size: PrimaryCtaSize.senior,
            isLoading: isLoading,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _PracticeStep extends StatelessWidget {
  const _PracticeStep({
    required this.onPractice,
    required this.onComplete,
  });

  final VoidCallback onPractice;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WizardStepHeader(
            step: 4,
            totalSteps: 4,
            title: 'Try your check-in button',
            subtitle: 'Tap below to hear and feel what happens when you check in.',
          ),
          PrimaryCta(
            label: "I'M OKAY TODAY",
            size: PrimaryCtaSize.senior,
            onPressed: onPractice,
            semanticsLabel: 'Practice check-in button',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Your family will know you are okay.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          PrimaryCta(
            label: 'Go to my home screen',
            size: PrimaryCtaSize.senior,
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}
