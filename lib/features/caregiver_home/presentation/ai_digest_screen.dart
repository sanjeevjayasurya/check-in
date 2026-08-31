import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';

class AiDigestScreen extends ConsumerStatefulWidget {
  const AiDigestScreen({super.key});

  @override
  ConsumerState<AiDigestScreen> createState() => _AiDigestScreenState();
}

class _AiDigestScreenState extends ConsumerState<AiDigestScreen> {
  final _notesController = TextEditingController();
  String? _digest;
  bool _isGenerating = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _digest = null;
    });

    try {
      final digest = await ref
          .read(openAiServiceProvider)
          .generateFamilyDigest(_notesController.text.trim());
      setState(() => _digest = digest);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Family Digest')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste family WhatsApp or email updates below. '
              'We\'ll turn them into a warm 2-sentence digest for your parent.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Paste family updates here…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generate,
              child: _isGenerating
                  ? const CircularProgressIndicator()
                  : const Text('Generate Digest'),
            ),
            if (_digest != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _digest!,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
