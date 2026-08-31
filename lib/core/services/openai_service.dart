import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

/// OpenAI integration for family digest generation and voice sentiment analysis.
class OpenAIService {
  OpenAIService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY');

  final http.Client _client;
  final String _apiKey;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// Turns raw family WhatsApp/email notes into a 2-sentence senior-friendly digest.
  Future<String> generateFamilyDigest(String rawNotes) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': AppConstants.openAiChatModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a warm family assistant. Summarize the following family '
                'updates into exactly 2 short, cheerful sentences suitable for an '
                'elderly parent. Use simple words. No jargon.',
          },
          {'role': 'user', 'content': rawNotes},
        ],
        'max_tokens': 120,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw OpenAIException(
        'Digest generation failed: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    final content =
        (choices.first as Map<String, dynamic>)['message']['content'] as String;
    return content.trim();
  }

  /// Transcribes audio via Whisper, then evaluates sentiment.
  Future<VoiceAnalysisResult> transcribeAndAnalyzeVoice(
    String audioFilePath,
  ) async {
    // Whisper transcription — multipart upload handled in Phase 4.
    throw UnimplementedError(
      'Voice transcription will be implemented in Phase 4.',
    );
  }
}

class VoiceAnalysisResult {
  const VoiceAnalysisResult({
    required this.transcript,
    required this.sentiment,
  });

  final String transcript;
  final String sentiment;
}

class OpenAIException implements Exception {
  OpenAIException(this.message);
  final String message;

  @override
  String toString() => 'OpenAIException: $message';
}
