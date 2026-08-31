import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/check_in_record.dart';
import 'package:sunsafe_checkin/models/family_greeting.dart';

final todayCheckInProvider = StreamProvider<CheckInRecord?>((ref) {
  final userAsync = ref.watch(currentAppUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(checkInRepositoryProvider)
          .watchTodayCheckIn(user.familyId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final todayGreetingProvider = StreamProvider<FamilyGreeting?>((ref) {
  final userAsync = ref.watch(currentAppUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref
          .watch(greetingRepositoryProvider)
          .watchTodayGreeting(user.familyId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
