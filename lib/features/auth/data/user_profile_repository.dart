import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/services/fcm_service.dart';

/// Persists caregiver FCM tokens and handles alert-related user metadata.
class UserProfileRepository {
  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> saveFcmToken(String uid) async {
    final token = await FcmService.getToken();
    if (token == null) return;

    await _firestore.collection(AppConstants.usersCollection).doc(uid).set(
      {'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }
}
