import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';
import 'package:sunsafe_checkin/models/telemetry_log.dart';

class CaregiverRepository {
  CaregiverRepository({
    required FirebaseFirestore firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Stream<TelemetryLog?> watchLatestTelemetry(String familyId) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.telemetrySubcollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TelemetryLog.fromFirestore(snapshot.docs.first);
    });
  }

  Future<void> updateAlertSettings({
    required String familyId,
    required AlertSettings settings,
  }) async {
    await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .update({'alertSettings': settings.toMap()});
  }

  Future<String> uploadGreetingPhoto({
    required String familyId,
    required File photoFile,
  }) async {
    final ref = _storage.ref(
      'families/$familyId/greetings/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(photoFile);
    return ref.getDownloadURL();
  }

  Future<String> uploadGreetingVoice({
    required String familyId,
    required File voiceFile,
  }) async {
    final ref = _storage.ref(
      'families/$familyId/greetings/${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await ref.putFile(voiceFile);
    return ref.getDownloadURL();
  }
}
