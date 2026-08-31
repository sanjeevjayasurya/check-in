import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:sunsafe_checkin/core/providers/firebase_providers.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/models/app_user.dart';
import 'package:sunsafe_checkin/models/family.dart';

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).getCurrentAppUser();
});

final familyProvider = StreamProvider.family<Family?, String>((ref, familyId) {
  return ref.watch(authRepositoryProvider).watchFamily(familyId);
});

final currentFamilyProvider = StreamProvider<Family?>((ref) {
  ref.watch(authStateChangesProvider);
  final appUserAsync = ref.watch(currentAppUserProvider);

  return appUserAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(authRepositoryProvider).watchFamily(user.familyId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
