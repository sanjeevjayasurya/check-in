import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/senior_voice_note.dart';

final seniorVoiceNotesProvider = StreamProvider<List<SeniorVoiceNote>>((ref) {
  final familyAsync = ref.watch(currentFamilyProvider);
  return familyAsync.when(
    data: (family) {
      if (family == null) return Stream.value([]);
      return ref
          .watch(voiceNoteRepositoryProvider)
          .watchVoiceNotes(family.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
