import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/models/family_greeting.dart';

class GreetingRepository {
  GreetingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  DocumentReference<Map<String, dynamic>> _greetingDoc(
    String familyId,
    String date,
  ) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.greetingsSubcollection)
        .doc(date);
  }

  Stream<FamilyGreeting?> watchTodayGreeting(String familyId) {
    return _greetingDoc(familyId, _todayKey()).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FamilyGreeting.fromFirestore(doc);
    });
  }

  Future<void> saveGreeting({
    required String familyId,
    required String caregiverId,
    String? message,
    String? photoUrl,
    String? voiceUrl,
  }) async {
    final date = _todayKey();
    final greeting = FamilyGreeting(
      date: date,
      caregiverId: caregiverId,
      createdAt: DateTime.now(),
      message: message,
      photoUrl: photoUrl,
      voiceUrl: voiceUrl,
    );

    await _greetingDoc(familyId, date).set(greeting.toFirestore());
  }
}
