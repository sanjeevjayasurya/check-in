import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/models/senior_voice_note.dart';

/// Uploads senior voice notes with Hive offline queue fallback.
class VoiceNoteRepository {
  VoiceNoteRepository({
    required FirebaseFirestore firestore,
    required Box<Map<dynamic, dynamic>> voiceNoteBox,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _voiceNoteBox = voiceNoteBox,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final Box<Map<dynamic, dynamic>> _voiceNoteBox;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _voiceNotes(String familyId) {
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.voiceNotesSubcollection);
  }

  Stream<List<SeniorVoiceNote>> watchVoiceNotes(String familyId) {
    return _voiceNotes(familyId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SeniorVoiceNote.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> uploadVoiceNote({
    required String familyId,
    required String seniorId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      final ref = _storage.ref(
        'families/$familyId/voice_notes/${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      await ref.putFile(file);
      final voiceUrl = await ref.getDownloadURL();

      final note = SeniorVoiceNote(
        id: '',
        seniorId: seniorId,
        voiceUrl: voiceUrl,
        createdAt: DateTime.now(),
        localPath: localPath,
      );

      await _voiceNotes(familyId).add(note.toFirestore());
      await _removePending(localPath);
    } catch (_) {
      await _queuePending(familyId, seniorId, localPath);
    }
  }

  Future<void> syncPendingVoiceNotes(String familyId, String seniorId) async {
    final pending = _voiceNoteBox.values.where(
      (entry) =>
          entry['familyId'] == familyId && entry['seniorId'] == seniorId,
    );

    for (final entry in pending) {
      await uploadVoiceNote(
        familyId: familyId,
        seniorId: seniorId,
        localPath: entry['localPath'] as String,
      );
    }
  }

  Future<void> _queuePending(
    String familyId,
    String seniorId,
    String localPath,
  ) async {
    await _voiceNoteBox.put(localPath, {
      'familyId': familyId,
      'seniorId': seniorId,
      'localPath': localPath,
    });
  }

  Future<void> _removePending(String localPath) async {
    await _voiceNoteBox.delete(localPath);
  }
}
