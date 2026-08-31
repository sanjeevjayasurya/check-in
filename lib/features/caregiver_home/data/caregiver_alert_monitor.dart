import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sunsafe_checkin/core/services/local_notification_service.dart';
import 'package:sunsafe_checkin/features/senior_home/data/check_in_repository.dart';
import 'package:sunsafe_checkin/models/family.dart';

/// Watches for missed senior check-ins and notifies the caregiver locally.
class CaregiverAlertMonitor {
  CaregiverAlertMonitor({
    required CheckInRepository checkInRepository,
  }) : _checkInRepository = checkInRepository;

  final CheckInRepository _checkInRepository;
  Timer? _timer;
  bool _alertSentToday = false;

  void startMonitoring(Family family) {
    _timer?.cancel();
    _alertSentToday = false;

    _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _evaluate(family);
    });

    _evaluate(family);
  }

  Future<void> _evaluate(Family family) async {
    final settings = family.alertSettings;
    final now = DateTime.now();
    final deadline = DateTime(
      now.year,
      now.month,
      now.day,
      settings.deadlineHour,
      settings.deadlineMinute,
    );

    if (now.isBefore(deadline) || _alertSentToday) return;

    final hasCheckedIn =
        await _checkInRepository.hasCheckedInToday(family.id);
    if (hasCheckedIn) return;

    _alertSentToday = true;
    await LocalNotificationService.showMissedCheckInAlert(
      seniorName: family.seniorDisplayName,
      deadlineHour: settings.deadlineHour,
    );

    if (kDebugMode) {
      debugPrint(
        'CaregiverAlertMonitor: missed check-in alert for ${family.seniorDisplayName}',
      );
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
