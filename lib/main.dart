import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/services/firebase_service.dart';
import 'package:sunsafe_checkin/core/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();
  await LocalNotificationService.initialize();

  runApp(
    const ProviderScope(
      child: SunSafeApp(),
    ),
  );
}
