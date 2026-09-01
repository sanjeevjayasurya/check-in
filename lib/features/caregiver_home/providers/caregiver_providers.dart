import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/check_in_record.dart';
import 'package:sunsafe_checkin/models/telemetry_log.dart';

final latestCheckInProvider = StreamProvider<CheckInRecord?>((ref) {
  final familyAsync = ref.watch(currentFamilyProvider);
  return familyAsync.when(
    data: (family) {
      if (family == null) return Stream.value(null);
      return ref
          .watch(checkInRepositoryProvider)
          .watchTodayCheckIn(family.id);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final latestTelemetryProvider = StreamProvider<TelemetryLog?>((ref) {
  final familyAsync = ref.watch(currentFamilyProvider);
  return familyAsync.when(
    data: (family) {
      if (family == null) return Stream.value(null);
      return ref
          .watch(caregiverRepositoryProvider)
          .watchLatestTelemetry(family.id);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
