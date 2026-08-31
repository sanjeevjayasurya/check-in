import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/services/local_notification_service.dart';
import 'package:sunsafe_checkin/models/telemetry_log.dart';

/// Reads device battery and motion, writes telemetry, and checks missed check-ins.
class TelemetryService {
  TelemetryService({
    FirebaseFirestore? firestore,
    Battery? battery,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _battery = battery ?? Battery();

  final FirebaseFirestore _firestore;
  final Battery _battery;

  Future<TelemetryLog> collectTelemetry({
    required String familyId,
    required String seniorId,
  }) async {
    final batteryLevel = await _battery.batteryLevel;
    final magnitude = await _readAccelerometerMagnitude();
    final isStationary =
        magnitude < AppConstants.stationaryAccelerometerThreshold;

    final log = TelemetryLog(
      timestamp: DateTime.now(),
      batteryLevel: batteryLevel,
      isStationary: isStationary,
      seniorId: seniorId,
      accelerometerMagnitude: magnitude,
    );

    await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.telemetrySubcollection)
        .add(log.toFirestore());

    if (batteryLevel <= AppConstants.lowBatteryThresholdPercent) {
      await LocalNotificationService.showMissedCheckInAlert(
        seniorName: 'Parent',
        deadlineHour: AppConstants.defaultCheckInDeadlineHour,
      );
    }

    return log;
  }

  Future<void> evaluateMissedCheckIn({
    required String familyId,
    required String seniorDisplayName,
    required int deadlineHour,
    required int deadlineMinute,
  }) async {
    final now = DateTime.now();
    final deadline = DateTime(
      now.year,
      now.month,
      now.day,
      deadlineHour,
      deadlineMinute,
    );

    if (now.isBefore(deadline)) return;

    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final checkInDoc = await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.checkInsSubcollection)
        .doc(todayKey)
        .get();

    if (checkInDoc.exists) return;

    final latestTelemetry = await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.telemetrySubcollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    final isStationary = latestTelemetry.docs.isEmpty
        ? true
        : (latestTelemetry.docs.first.data()['isStationary'] as bool? ?? true);

    if (isStationary) {
      await LocalNotificationService.showMissedCheckInAlert(
        seniorName: seniorDisplayName,
        deadlineHour: deadlineHour,
      );
    }
  }

  Future<double> _readAccelerometerMagnitude() async {
    try {
      final event = await accelerometerEventStream().first.timeout(
            const Duration(seconds: 2),
          );
      return sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
    } catch (_) {
      return 0;
    }
  }
}
