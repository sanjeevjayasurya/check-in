import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

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
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyDigest() async {
    if (_digest == null) return;
    await Clipboard.setData(ClipboardData(text: _digest!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digest copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('AI Family Digest')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste family updates below. We\'ll turn them into a warm '
                'two-sentence digest you can share.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _notesController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Paste family updates here…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryCta(
                label: 'Generate digest',
                isLoading: _isGenerating,
                onPressed: _generate,
              ),
              if (_digest != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      _digest!,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _copyDigest,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy digest'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
