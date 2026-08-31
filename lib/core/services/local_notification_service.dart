import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local notification display for missed check-ins and alerts.
class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Deep-link routing handled in Phase 5.
  }

  static Future<void> showMissedCheckInAlert({
    required String seniorName,
    required int deadlineHour,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'missed_checkin',
      'Missed Check-In Alerts',
      channelDescription: 'Alerts when a senior has not checked in by deadline',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      1,
      'Check-In Missed',
      '$seniorName has not checked in by ${deadlineHour.toString().padLeft(2, '0')}:00.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
