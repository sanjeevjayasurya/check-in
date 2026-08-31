import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

class VoiceNoteService {
  VoiceNoteService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _currentPath =
          '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentPath!,
      );
    } else {
      throw VoiceNoteException('Microphone permission denied.');
    }
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path ?? _currentPath;
  }

  Future<String?> recordGreeting({int maxSeconds = AppConstants.maxGreetingVoiceDurationSeconds}) async {
    await startRecording();
    await Future<void>.delayed(Duration(seconds: maxSeconds));
    return stopRecording();
  }

  Future<bool> isRecording() => _recorder.isRecording();

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

class VoiceNoteException implements Exception {
  VoiceNoteException(this.message);
  final String message;

  @override
  String toString() => 'VoiceNoteException: $message';
}
