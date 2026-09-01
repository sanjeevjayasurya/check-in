import 'package:sunsafe_checkin/models/check_in_record.dart';

enum ParentCheckInStatus { checkedIn, approachingDeadline, missed, unknown }

class CheckInStatusHelper {
  CheckInStatusHelper._();

  static ParentCheckInStatus resolve({
    required CheckInRecord? todayCheckIn,
    required int deadlineHour,
    required int deadlineMinute,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final deadline = DateTime(
      current.year,
      current.month,
      current.day,
      deadlineHour,
      deadlineMinute,
    );

    if (todayCheckIn != null &&
        _isSameDay(todayCheckIn.timestamp, current)) {
      return ParentCheckInStatus.checkedIn;
    }

    if (current.isAfter(deadline)) {
      return ParentCheckInStatus.missed;
    }

    final twoHoursBefore = deadline.subtract(const Duration(hours: 2));
    if (current.isAfter(twoHoursBefore)) {
      return ParentCheckInStatus.approachingDeadline;
    }

    return ParentCheckInStatus.unknown;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
