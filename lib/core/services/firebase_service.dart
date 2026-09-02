import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:sunsafe_checkin/firebase_options.dart';

/// Initializes Firebase for the current platform via FlutterFire config.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static FirebaseOptions get _options => DefaultFirebaseOptions.currentPlatform;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (DefaultFirebaseOptions.isPlaceholderConfig && kDebugMode) {
      debugPrint(
        'FirebaseService: Placeholder config detected. '
        'Run ./scripts/configure_firebase.sh after firebase login.',
      );
    }

    await Firebase.initializeApp(options: _options);
    _initialized = true;
  }

  /// Firebase options for background isolates (WorkManager callback).
  static FirebaseOptions firebaseOptionsForBackground() => _options;
}
