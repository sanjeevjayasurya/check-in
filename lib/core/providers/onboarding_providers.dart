import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/services/onboarding_prefs.dart';

final onboardingPrefsProvider = FutureProvider<OnboardingPrefs>((ref) async {
  return OnboardingPrefs.create();
});

final seniorHighContrastProvider =
    StateNotifierProvider<SeniorHighContrastNotifier, bool>((ref) {
  return SeniorHighContrastNotifier(ref);
});

class SeniorHighContrastNotifier extends StateNotifier<bool> {
  SeniorHighContrastNotifier(this._ref) : super(false) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await _ref.read(onboardingPrefsProvider.future);
    state = prefs.seniorHighContrast;
  }

  Future<void> setHighContrast(bool value) async {
    state = value;
    final prefs = await _ref.read(onboardingPrefsProvider.future);
    await prefs.setSeniorHighContrast(value);
  }
}
