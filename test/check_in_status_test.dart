import 'package:sunsafe_checkin/core/utils/check_in_status.dart';
import 'package:sunsafe_checkin/models/check_in_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckInStatusHelper', () {
    final deadlineHour = 18;
    final deadlineMinute = 0;
    final today = DateTime(2026, 9, 1, 8, 30);

    test('returns checkedIn when check-in is today', () {
      final status = CheckInStatusHelper.resolve(
        todayCheckIn: CheckInRecord(
          date: '2026-09-01',
          seniorId: 's1',
          timestamp: DateTime(2026, 9, 1, 8, 0),
        ),
        deadlineHour: deadlineHour,
        deadlineMinute: deadlineMinute,
        now: today,
      );

      expect(status, ParentCheckInStatus.checkedIn);
    });

    test('returns approachingDeadline within two hours', () {
      final status = CheckInStatusHelper.resolve(
        todayCheckIn: null,
        deadlineHour: deadlineHour,
        deadlineMinute: deadlineMinute,
        now: DateTime(2026, 9, 1, 16, 30),
      );

      expect(status, ParentCheckInStatus.approachingDeadline);
    });

    test('returns missed after deadline', () {
      final status = CheckInStatusHelper.resolve(
        todayCheckIn: null,
        deadlineHour: deadlineHour,
        deadlineMinute: deadlineMinute,
        now: DateTime(2026, 9, 1, 19, 0),
      );

      expect(status, ParentCheckInStatus.missed);
    });
  });
}
