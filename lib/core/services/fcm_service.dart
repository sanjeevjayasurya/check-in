import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase Cloud Messaging for caregiver alert push notifications.
class FcmService {
  FcmService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    _initialized = true;
  }

  static Future<String?> getToken() async {
    if (kIsWeb) return null;
    return FirebaseMessaging.instance.getToken();
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.notification?.title}');
}
