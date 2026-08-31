import 'package:cloud_firestore/cloud_firestore.dart';

/// Background telemetry snapshot (battery + motion).
class TelemetryLog {
  const TelemetryLog({
    required this.timestamp,
    required this.batteryLevel,
    required this.isStationary,
    required this.seniorId,
    this.accelerometerMagnitude,
  });

  final DateTime timestamp;
  final int batteryLevel;
  final bool isStationary;
  final String seniorId;
  final double? accelerometerMagnitude;

  factory TelemetryLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TelemetryLog(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      batteryLevel: data['batteryLevel'] as int,
      isStationary: data['isStationary'] as bool,
      seniorId: data['seniorId'] as String,
      accelerometerMagnitude:
          (data['accelerometerMagnitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'batteryLevel': batteryLevel,
      'isStationary': isStationary,
      'seniorId': seniorId,
      if (accelerometerMagnitude != null)
        'accelerometerMagnitude': accelerometerMagnitude,
    };
  }
}
