import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/services/firebase_service.dart';
import 'package:sunsafe_checkin/features/background/telemetry_service.dart';

const _familyIdKey = 'senior_family_id';
const _seniorIdKey = 'senior_uid';
const _seniorNameKey = 'senior_display_name';
const _deadlineHourKey = 'checkin_deadline_hour';
const _deadlineMinuteKey = 'checkin_deadline_minute';

/// Registers and executes hourly background telemetry checks.
class BackgroundTelemetryTask {
  BackgroundTelemetryTask._();

  static Future<void> register() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      AppConstants.backgroundTelemetryTaskName,
      AppConstants.backgroundTelemetryTaskName,
      frequency: Duration(
        minutes: AppConstants.backgroundTelemetryIntervalMinutes,
      ),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(
      AppConstants.backgroundTelemetryTaskName,
    );
  }

  static Future<void> persistSeniorContext({
    required String familyId,
    required String seniorId,
    required String seniorDisplayName,
    required int deadlineHour,
    required int deadlineMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_familyIdKey, familyId);
    await prefs.setString(_seniorIdKey, seniorId);
    await prefs.setString(_seniorNameKey, seniorDisplayName);
    await prefs.setInt(_deadlineHourKey, deadlineHour);
    await prefs.setInt(_deadlineMinuteKey, deadlineMinute);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != AppConstants.backgroundTelemetryTaskName) {
      return Future.value(true);
    }

    try {
      await Firebase.initializeApp(
        options: FirebaseService.firebaseOptionsForBackground(),
      );
    } catch (_) {
      // Already initialized.
    }

    final prefs = await SharedPreferences.getInstance();
    final familyId = prefs.getString(_familyIdKey);
    final seniorId = prefs.getString(_seniorIdKey);
    if (familyId == null || seniorId == null) return Future.value(true);

    final telemetryService = TelemetryService();
    await telemetryService.collectTelemetry(
      familyId: familyId,
      seniorId: seniorId,
    );

    await telemetryService.evaluateMissedCheckIn(
      familyId: familyId,
      seniorDisplayName: prefs.getString(_seniorNameKey) ?? 'Parent',
      deadlineHour:
          prefs.getInt(_deadlineHourKey) ?? AppConstants.defaultCheckInDeadlineHour,
      deadlineMinute: prefs.getInt(_deadlineMinuteKey) ??
          AppConstants.defaultCheckInDeadlineMinute,
    );

    return Future.value(true);
  });
}
