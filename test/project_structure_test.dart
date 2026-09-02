import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

void main() {
  test('required asset files exist', () {
    expect(
      File(AppConstants.assetCheckInSuccessSound).existsSync(),
      isTrue,
      reason: 'Check-in success sound must be bundled for senior feedback',
    );
  });

  test('feature-first lib structure contains required modules', () {
    const requiredPaths = [
      'lib/core/theme/app_theme.dart',
      'lib/firebase_options.dart',
      'lib/features/auth/presentation/auth_gate.dart',
      'lib/features/senior_home/presentation/senior_home_screen.dart',
      'lib/features/caregiver_home/presentation/caregiver_home_screen.dart',
      'lib/features/background/background_telemetry_task.dart',
      'lib/features/paywall/presentation/paywall_screen.dart',
      'lib/models/user_role.dart',
      'firebase/firestore.rules',
      'android/app/google-services.json',
      'ios/Runner/GoogleService-Info.plist',
    ];

    for (final path in requiredPaths) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing $path');
    }
  });
}
