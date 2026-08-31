import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

/// Authenticated user profile stored in Firestore `users/{uid}`.
class AppUser {
  const AppUser({
    required this.uid,
    required this.role,
    required this.familyId,
    this.email,
    this.displayName,
  });

  final String uid;
  final UserRole role;
  final String familyId;
  final String? email;
  final String? displayName;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      role: UserRole.fromString(data['role'] as String),
      familyId: data['familyId'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role.value,
      'familyId': familyId,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
    };
  }
}
