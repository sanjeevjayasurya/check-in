import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';

/// Family group linking one senior with one or more caregivers.
class Family {
  const Family({
    required this.id,
    required this.inviteCode,
    required this.caregiverIds,
    this.seniorId,
    this.alertSettings = AlertSettings.defaults,
    this.seniorDisplayName = 'Parent',
  });

  final String id;
  final String inviteCode;
  final List<String> caregiverIds;
  final String? seniorId;
  final AlertSettings alertSettings;
  final String seniorDisplayName;

  factory Family.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Family(
      id: doc.id,
      inviteCode: data['inviteCode'] as String,
      caregiverIds: List<String>.from(data['caregiverIds'] as List<dynamic>),
      seniorId: data['seniorId'] as String?,
      alertSettings: data['alertSettings'] != null
          ? AlertSettings.fromMap(data['alertSettings'] as Map<String, dynamic>)
          : AlertSettings.defaults,
      seniorDisplayName: data['seniorDisplayName'] as String? ?? 'Parent',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inviteCode': inviteCode,
      'caregiverIds': caregiverIds,
      if (seniorId != null) 'seniorId': seniorId,
      'alertSettings': alertSettings.toMap(),
      'seniorDisplayName': seniorDisplayName,
    };
  }

  Family copyWith({
    String? id,
    String? inviteCode,
    List<String>? caregiverIds,
    String? seniorId,
    AlertSettings? alertSettings,
    String? seniorDisplayName,
  }) {
    return Family(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      caregiverIds: caregiverIds ?? this.caregiverIds,
      seniorId: seniorId ?? this.seniorId,
      alertSettings: alertSettings ?? this.alertSettings,
      seniorDisplayName: seniorDisplayName ?? this.seniorDisplayName,
    );
  }
}
