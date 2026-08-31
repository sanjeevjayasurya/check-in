import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

/// Initializes Hive boxes used for offline caching.
class HiveService {
  HiveService._();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.hiveBoxCheckIns);
    await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.hiveBoxVoiceNotes);
    await Hive.openBox(AppConstants.hiveBoxSettings);
  }
}
