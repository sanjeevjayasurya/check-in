/// Application-wide constants for SunSafe Check-In.
class AppConstants {
  AppConstants._();

  // ── Asset paths ──────────────────────────────────────────────────────────
  static const String assetCheckInSuccessSound =
      'assets/sounds/check_in_success.mp3';
  static const String assetCheckInSuccessAnimation =
      'assets/images/check_in_success.gif';
  static const String assetAppLogo = 'assets/images/sunsafe_logo.png';
  static const String assetSunIcon = 'assets/images/sun_icon.png';

  // ── Firestore collection paths ───────────────────────────────────────────
  static const String familiesCollection = 'families';
  static const String checkInsSubcollection = 'checkins';
  static const String greetingsSubcollection = 'greetings';
  static const String telemetrySubcollection = 'telemetry';
  static const String usersCollection = 'users';

  // ── Check-in & telemetry thresholds ──────────────────────────────────────
  /// Default morning check-in deadline (24-hour format).
  static const int defaultCheckInDeadlineHour = 10;
  static const int defaultCheckInDeadlineMinute = 0;

  /// Accelerometer magnitude below which the device is considered stationary.
  static const double stationaryAccelerometerThreshold = 0.5;

  /// Minimum battery percentage before a low-battery alert is sent.
  static const int lowBatteryThresholdPercent = 15;

  /// Background workmanager task identifier.
  static const String backgroundTelemetryTaskName = 'telemetryCheckTask';

  /// How often background telemetry runs (in minutes).
  static const int backgroundTelemetryIntervalMinutes = 60;

  // ── Voice & greeting limits ──────────────────────────────────────────────
  static const int maxGreetingVoiceDurationSeconds = 15;
  static const int maxVoiceNoteDurationSeconds = 60;

  // ── RevenueCat ─────────────────────────────────────────────────────────────
  static const String revenueCatEntitlementPremium = 'premium';
  static const String revenueCatOfferingId = 'default';
  static const double premiumMonthlyPrice = 7.99;

  // ── OpenAI ─────────────────────────────────────────────────────────────────
  static const String openAiChatModel = 'gpt-4o-mini';
  static const String openAiWhisperModel = 'whisper-1';
  static const String openAiBaseUrl = 'https://api.openai.com/v1';

  // ── Invite code ────────────────────────────────────────────────────────────
  static const int inviteCodeLength = 6;

  // ── Hive box names ─────────────────────────────────────────────────────────
  static const String hiveBoxCheckIns = 'pending_checkins';
  static const String hiveBoxSettings = 'app_settings';
}
