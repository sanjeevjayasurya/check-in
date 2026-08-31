import 'package:cloud_firestore/cloud_firestore.dart';

/// Daily greeting reward shown to the senior after check-in.
class FamilyGreeting {
  const FamilyGreeting({
    required this.date,
    required this.caregiverId,
    required this.createdAt,
    this.message,
    this.photoUrl,
    this.voiceUrl,
  });

  final String date;
  final String caregiverId;
  final DateTime createdAt;
  final String? message;
  final String? photoUrl;
  final String? voiceUrl;

  bool get hasContent =>
      (message != null && message!.isNotEmpty) ||
      photoUrl != null ||
      voiceUrl != null;

  factory FamilyGreeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return FamilyGreeting(
      date: doc.id,
      caregiverId: data['caregiverId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      message: data['message'] as String?,
      photoUrl: data['photoUrl'] as String?,
      voiceUrl: data['voiceUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caregiverId': caregiverId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (message != null) 'message': message,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (voiceUrl != null) 'voiceUrl': voiceUrl,
    };
  }
}
