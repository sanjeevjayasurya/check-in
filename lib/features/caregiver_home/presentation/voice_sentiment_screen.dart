import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';

class VoiceSentimentScreen extends ConsumerStatefulWidget {
  const VoiceSentimentScreen({super.key, required this.audioPath});

  final String audioPath;

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
      final result = await ref
          .read(openAiServiceProvider)
          .transcribeAndAnalyzeVoice(widget.audioPath);
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
