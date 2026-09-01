import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  OnboardingPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _seniorCompleteKey = 'senior_onboarding_complete';
  static const _caregiverCompleteKey = 'caregiver_onboarding_complete';
  static const _seniorHighContrastKey = 'senior_high_contrast';

  static Future<OnboardingPrefs> create() async {
    return OnboardingPrefs(await SharedPreferences.getInstance());
  }

  bool get seniorOnboardingComplete =>
      _prefs.getBool(_seniorCompleteKey) ?? false;

  bool get caregiverOnboardingComplete =>
      _prefs.getBool(_caregiverCompleteKey) ?? false;

  bool get seniorHighContrast => _prefs.getBool(_seniorHighContrastKey) ?? false;

  Future<void> setSeniorOnboardingComplete(bool value) =>
      _prefs.setBool(_seniorCompleteKey, value);

  Future<void> setCaregiverOnboardingComplete(bool value) =>
      _prefs.setBool(_caregiverCompleteKey, value);

  Future<void> setSeniorHighContrast(bool value) =>
      _prefs.setBool(_seniorHighContrastKey, value);
}
