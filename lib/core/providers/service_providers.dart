import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';
import 'package:sunsafe_checkin/core/providers/firebase_providers.dart';
import 'package:sunsafe_checkin/core/services/openai_service.dart';
import 'package:sunsafe_checkin/core/services/revenuecat_service.dart';
import 'package:sunsafe_checkin/features/auth/data/auth_repository.dart';
import 'package:sunsafe_checkin/features/auth/data/user_profile_repository.dart';
import 'package:sunsafe_checkin/features/caregiver_home/data/caregiver_alert_monitor.dart';
import 'package:sunsafe_checkin/features/caregiver_home/data/caregiver_repository.dart';
import 'package:sunsafe_checkin/features/senior_home/data/check_in_repository.dart';
import 'package:sunsafe_checkin/features/senior_home/data/greeting_repository.dart';
import 'package:sunsafe_checkin/features/senior_home/data/voice_note_repository.dart';
import 'package:sunsafe_checkin/features/senior_home/data/voice_note_service.dart';

final openAiServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository(
    firestore: ref.watch(firestoreProvider),
    checkInBox: Hive.box<Map<dynamic, dynamic>>(AppConstants.hiveBoxCheckIns),
  );
});

final greetingRepositoryProvider = Provider<GreetingRepository>((ref) {
  return GreetingRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final caregiverRepositoryProvider = Provider<CaregiverRepository>((ref) {
  return CaregiverRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final voiceNoteRepositoryProvider = Provider<VoiceNoteRepository>((ref) {
  return VoiceNoteRepository(
    firestore: ref.watch(firestoreProvider),
    voiceNoteBox:
        Hive.box<Map<dynamic, dynamic>>(AppConstants.hiveBoxVoiceNotes),
  );
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final caregiverAlertMonitorProvider = Provider<CaregiverAlertMonitor>((ref) {
  return CaregiverAlertMonitor(
    checkInRepository: ref.watch(checkInRepositoryProvider),
  );
});

final voiceNoteServiceProvider = Provider<VoiceNoteService>((ref) {
  return VoiceNoteService();
});

final premiumStatusProvider = FutureProvider<bool>((ref) async {
  return RevenueCatService.isPremiumActive();
});
