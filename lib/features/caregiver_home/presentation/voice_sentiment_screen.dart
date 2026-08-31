import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';

class VoiceSentimentScreen extends ConsumerStatefulWidget {
  const VoiceSentimentScreen({
    super.key,
    required this.audioPath,
    this.isRemoteUrl = false,
  });

  final String audioPath;
  final bool isRemoteUrl;

  @override
  ConsumerState<VoiceSentimentScreen> createState() =>
      _VoiceSentimentScreenState();
}

class _VoiceSentimentScreenState extends ConsumerState<VoiceSentimentScreen> {
  String? _transcript;
  String? _sentiment;
  bool _isAnalyzing = false;

  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    try {
      final localPath = widget.isRemoteUrl
          ? await _downloadRemoteFile(widget.audioPath)
          : widget.audioPath;
      final result = await ref
          .read(openAiServiceProvider)
          .transcribeAndAnalyzeVoice(localPath);
      setState(() {
        _transcript = result.transcript;
        _sentiment = result.sentiment;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<String> _downloadRemoteFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/voice_analysis_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await File(filePath).writeAsBytes(response.bodyBytes);
    return filePath;
  }

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Sentiment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isAnalyzing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_sentiment != null)
                    Card(
                      child: ListTile(
                        leading: Icon(_sentimentIcon(_sentiment!)),
                        title: Text('Sentiment: $_sentiment'),
                      ),
                    ),
                  if (_transcript != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _transcript!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  IconData _sentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Icons.sentiment_satisfied_alt;
      case 'worried':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
