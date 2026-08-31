/// Caregiver-configured alert thresholds and emergency contacts.
class AlertSettings {
  const AlertSettings({
    required this.deadlineHour,
    required this.deadlineMinute,
    required this.emergencyContacts,
    this.escalationEnabled = true,
    this.lowBatteryAlertsEnabled = true,
  });

  final int deadlineHour;
  final int deadlineMinute;
  final List<String> emergencyContacts;
  final bool escalationEnabled;
  final bool lowBatteryAlertsEnabled;

  static const AlertSettings defaults = AlertSettings(
    deadlineHour: 10,
    deadlineMinute: 0,
    emergencyContacts: [],
  );

  factory AlertSettings.fromMap(Map<String, dynamic> map) {
    return AlertSettings(
      deadlineHour: map['deadlineHour'] as int? ?? 10,
      deadlineMinute: map['deadlineMinute'] as int? ?? 0,
      emergencyContacts: List<String>.from(
        map['emergencyContacts'] as List<dynamic>? ?? [],
      ),
      escalationEnabled: map['escalationEnabled'] as bool? ?? true,
      lowBatteryAlertsEnabled: map['lowBatteryAlertsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deadlineHour': deadlineHour,
      'deadlineMinute': deadlineMinute,
      'emergencyContacts': emergencyContacts,
      'escalationEnabled': escalationEnabled,
      'lowBatteryAlertsEnabled': lowBatteryAlertsEnabled,
    };
  }

  AlertSettings copyWith({
    int? deadlineHour,
    int? deadlineMinute,
    List<String>? emergencyContacts,
    bool? escalationEnabled,
    bool? lowBatteryAlertsEnabled,
  }) {
    return AlertSettings(
      deadlineHour: deadlineHour ?? this.deadlineHour,
      deadlineMinute: deadlineMinute ?? this.deadlineMinute,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      escalationEnabled: escalationEnabled ?? this.escalationEnabled,
      lowBatteryAlertsEnabled:
          lowBatteryAlertsEnabled ?? this.lowBatteryAlertsEnabled,
    );
  }
}
