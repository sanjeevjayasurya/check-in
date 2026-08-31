import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/services/fcm_service.dart';
import 'package:sunsafe_checkin/core/services/firebase_service.dart';
import 'package:sunsafe_checkin/core/services/hive_service.dart';
import 'package:sunsafe_checkin/core/services/local_notification_service.dart';
import 'package:sunsafe_checkin/core/services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.initialize();
  await FirebaseService.initialize();
  await FcmService.initialize();
  await LocalNotificationService.initialize();

  const revenueCatKey = String.fromEnvironment('REVENUECAT_API_KEY');
  if (revenueCatKey.isNotEmpty) {
    await RevenueCatService.initialize(apiKey: revenueCatKey);
  }

  runApp(
    const ProviderScope(
      child: SunSafeApp(),
    ),
  );
}
