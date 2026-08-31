import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/models/check_in_record.dart';

class CheckInException implements Exception {
  CheckInException(this.message);
  final String message;

  @override
  String toString() => 'CheckInException: $message';
}

/// Persists check-ins to Firestore with Hive offline queue fallback.
class CheckInRepository {
  CheckInRepository({
    required FirebaseFirestore firestore,
    required Box<Map<dynamic, dynamic>> checkInBox,
  })  : _firestore = firestore,
        _checkInBox = checkInBox;

  final FirebaseFirestore _firestore;
  final Box<Map<dynamic, dynamic>> _checkInBox;

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  DocumentReference<Map<String, dynamic>> _checkInDoc(
    String familyId,
    String date,
  ) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.checkInsSubcollection)
        .doc(date);
  }

  Stream<CheckInRecord?> watchTodayCheckIn(String familyId) {
    return _checkInDoc(familyId, _todayKey()).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CheckInRecord.fromFirestore(doc);
    });
  }

  Stream<CheckInRecord?> watchLatestCheckIn(String familyId) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.checkInsSubcollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CheckInRecord.fromFirestore(snapshot.docs.first);
    });
  }

  Future<CheckInRecord> submitCheckIn({
    required String familyId,
    required String seniorId,
    String? note,
  }) async {
    final date = _todayKey();
    final record = CheckInRecord(
      date: date,
      timestamp: DateTime.now(),
      seniorId: seniorId,
      note: note,
    );

    try {
      await _checkInDoc(familyId, date).set(record.toFirestore());
      await _removePendingCheckIn(familyId, date);
      return record.copyWith(synced: true);
    } catch (_) {
      await _queuePendingCheckIn(familyId, record);
      return record.copyWith(synced: false);
    }
  }

  Future<void> syncPendingCheckIns(String familyId) async {
    final pending = _checkInBox.values.where(
      (entry) => entry['familyId'] == familyId,
    );

    for (final entry in pending) {
      final date = entry['date'] as String;
      final record = CheckInRecord(
        date: date,
        timestamp: DateTime.parse(entry['timestamp'] as String),
        seniorId: entry['seniorId'] as String,
        note: entry['note'] as String?,
        synced: false,
      );

      try {
        await _checkInDoc(familyId, date).set(record.toFirestore());
        await _removePendingCheckIn(familyId, date);
      } catch (_) {
        // Remain queued until connectivity returns.
      }
    }
  }

  Future<bool> hasCheckedInToday(String familyId) async {
    final doc = await _checkInDoc(familyId, _todayKey()).get();
    return doc.exists;
  }

  Future<void> _queuePendingCheckIn(String familyId, CheckInRecord record) async {
    final key = '${familyId}_${record.date}';
    await _checkInBox.put(key, {
      'familyId': familyId,
      'date': record.date,
      'timestamp': record.timestamp.toIso8601String(),
      'seniorId': record.seniorId,
      'note': record.note,
    });
  }

  Future<void> _removePendingCheckIn(String familyId, String date) async {
    await _checkInBox.delete('${familyId}_$date');
  }
}
