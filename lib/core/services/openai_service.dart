import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sunsafe_checkin/core/constants/app_constants.dart';

/// OpenAI integration for family digest generation and voice sentiment analysis.
class OpenAIService {
  OpenAIService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY');

  final http.Client _client;
  final String _apiKey;

  Map<String, String> get _jsonHeaders => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// Turns raw family WhatsApp/email notes into a 2-sentence senior-friendly digest.
  Future<String> generateFamilyDigest(String rawNotes) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
      headers: _jsonHeaders,
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

  /// Transcribes audio via Whisper, then evaluates sentiment with gpt-4o-mini.
  Future<VoiceAnalysisResult> transcribeAndAnalyzeVoice(
    String audioFilePath,
  ) async {
    final file = File(audioFilePath);
    if (!file.existsSync()) {
      throw OpenAIException('Audio file not found: $audioFilePath');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.openAiBaseUrl}/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $_apiKey';
    request.fields['model'] = AppConstants.openAiWhisperModel;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFilePath,
        contentType: MediaType('audio', 'm4a'),
      ),
    );

    final transcriptionResponse = await request.send();
    final transcriptionBody = await transcriptionResponse.stream.bytesToString();

    if (transcriptionResponse.statusCode != 200) {
      throw OpenAIException(
        'Transcription failed: ${transcriptionResponse.statusCode} $transcriptionBody',
      );
    }

    final transcript =
        (jsonDecode(transcriptionBody) as Map<String, dynamic>)['text'] as String;

    final sentimentResponse = await _client.post(
      Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'model': AppConstants.openAiChatModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'Analyze the emotional tone of this voice note transcript. '
                'Reply with one word: positive, neutral, worried, or sad.',
          },
          {'role': 'user', 'content': transcript},
        ],
        'max_tokens': 10,
        'temperature': 0,
      }),
    );

    if (sentimentResponse.statusCode != 200) {
      throw OpenAIException(
        'Sentiment analysis failed: ${sentimentResponse.statusCode}',
      );
    }

    final sentimentData =
        jsonDecode(sentimentResponse.body) as Map<String, dynamic>;
    final choices = sentimentData['choices'] as List<dynamic>;
    final message =
        (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>;
    final sentiment = (message['content'] as String).trim().toLowerCase();

    return VoiceAnalysisResult(transcript: transcript.trim(), sentiment: sentiment);
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
