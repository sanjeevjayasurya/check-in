/// AI-generated family digest for the senior's morning reward screen.
class DailyDigest {
  const DailyDigest({
    required this.id,
    required this.summary,
    required this.createdAt,
    required this.caregiverId,
    this.rawNotes,
    this.isPremium = false,
  });

  final String id;
  final String summary;
  final DateTime createdAt;
  final String caregiverId;
  final String? rawNotes;
  final bool isPremium;

  factory DailyDigest.fromJson(Map<String, dynamic> json) {
    return DailyDigest(
      id: json['id'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      caregiverId: json['caregiverId'] as String,
      rawNotes: json['rawNotes'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'caregiverId': caregiverId,
      if (rawNotes != null) 'rawNotes': rawNotes,
      'isPremium': isPremium,
    };
  }
}
