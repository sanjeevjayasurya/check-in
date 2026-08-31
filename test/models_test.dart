import 'package:flutter_test/flutter_test.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';

void main() {
  group('AlertSettings', () {
    test('defaults to 10:00 deadline', () {
      expect(AlertSettings.defaults.deadlineHour, 10);
      expect(AlertSettings.defaults.deadlineMinute, 0);
    });

    test('round-trips through map serialization', () {
      const settings = AlertSettings(
        deadlineHour: 9,
        deadlineMinute: 30,
        emergencyContacts: ['555-0100'],
        escalationEnabled: false,
      );

      final restored = AlertSettings.fromMap(settings.toMap());
      expect(restored.deadlineHour, 9);
      expect(restored.deadlineMinute, 30);
      expect(restored.emergencyContacts, ['555-0100']);
      expect(restored.escalationEnabled, false);
    });
  });

  group('AppConstants', () {
    test('defines required collection paths', () {
      expect(AppConstants.familiesCollection, 'families');
      expect(AppConstants.voiceNotesSubcollection, 'voice_notes');
      expect(AppConstants.inviteCodeLength, 6);
    });
  });
}
