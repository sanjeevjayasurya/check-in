/// A voice note left by the senior for caregivers to review.
class SeniorVoiceNote {
  const SeniorVoiceNote({
    required this.id,
    required this.seniorId,
    required this.voiceUrl,
    required this.createdAt,
    this.localPath,
    this.sentiment,
  });

  final String id;
  final String seniorId;
  final String voiceUrl;
  final DateTime createdAt;
  final String? localPath;
  final String? sentiment;

  factory SeniorVoiceNote.fromFirestore(String id, Map<String, dynamic> data) {
    return SeniorVoiceNote(
      id: id,
      seniorId: data['seniorId'] as String,
      voiceUrl: data['voiceUrl'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      localPath: data['localPath'] as String?,
      sentiment: data['sentiment'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'seniorId': seniorId,
      'voiceUrl': voiceUrl,
      'createdAt': createdAt.toIso8601String(),
      if (localPath != null) 'localPath': localPath,
      if (sentiment != null) 'sentiment': sentiment,
    };
  }
}
