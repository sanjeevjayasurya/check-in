import 'package:cloud_firestore/cloud_firestore.dart';

/// A single daily check-in event from the senior.
class CheckInRecord {
  const CheckInRecord({
    required this.date,
    required this.timestamp,
    required this.seniorId,
    this.synced = true,
    this.note,
  });

  final String date;
  final DateTime timestamp;
  final String seniorId;
  final bool synced;
  final String? note;

  factory CheckInRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CheckInRecord(
      date: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      seniorId: data['seniorId'] as String,
      synced: data['synced'] as bool? ?? true,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'seniorId': seniorId,
      'synced': synced,
      if (note != null) 'note': note,
    };
  }

  CheckInRecord copyWith({
    String? date,
    DateTime? timestamp,
    String? seniorId,
    bool? synced,
    String? note,
  }) {
    return CheckInRecord(
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      seniorId: seniorId ?? this.seniorId,
      synced: synced ?? this.synced,
      note: note ?? this.note,
    );
  }
}
