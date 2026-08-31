import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase for the current platform.
///
/// Platform-specific config files (google-services.json, GoogleService-Info.plist)
/// must be added before running on device.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await Firebase.initializeApp(
      options: firebaseOptionsFromEnvironment(),
    );
    _initialized = true;
  }

  /// Firebase options for background isolates (WorkManager callback).
  static FirebaseOptions firebaseOptionsForBackground() {
    return firebaseOptionsFromEnvironment();
  }

  static FirebaseOptions firebaseOptionsFromEnvironment() {
    // Replace with real values via --dart-define or flutter_dotenv in production.
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const messagingSenderId =
        String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

    if (apiKey.isEmpty || appId.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'FirebaseService: Missing dart-define credentials. '
          'Pass FIREBASE_* values at build time.',
        );
      }
    }

    return FirebaseOptions(
      apiKey: apiKey.isNotEmpty ? apiKey : 'placeholder-api-key',
      appId: appId.isNotEmpty ? appId : '1:000000000000:android:placeholder',
      messagingSenderId:
          messagingSenderId.isNotEmpty ? messagingSenderId : '000000000000',
      projectId: projectId.isNotEmpty ? projectId : 'sunsafe-checkin-dev',
    );
  }
}
