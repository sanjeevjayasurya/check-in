import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/greeting_card.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/core/widgets/wizard_step_header.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

class SendGreetingScreen extends ConsumerStatefulWidget {
  const SendGreetingScreen({super.key});

  @override
  ConsumerState<SendGreetingScreen> createState() => _SendGreetingScreenState();
}

class _SendGreetingScreenState extends ConsumerState<SendGreetingScreen> {
  final _pageController = PageController();
  final _messageController = TextEditingController();
  File? _photoFile;
  String? _voicePath;
  bool _isSaving = false;

  static const _prompts = ['Thinking of you', 'Love you', 'Hope you have a sunny day'];

  @override
  void dispose() {
    _pageController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _photoFile = File(image.path));
    }
  }

  Future<void> _recordVoice() async {
    final service = ref.read(voiceNoteServiceProvider);
    try {
      final path = await service.recordGreeting();
      setState(() => _voicePath = path);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final user = await ref.read(currentAppUserProvider.future);
      if (user == null) return;

      String? photoUrl;
      String? voiceUrl;

      if (_photoFile != null) {
        photoUrl = await ref.read(caregiverRepositoryProvider).uploadGreetingPhoto(
              familyId: user.familyId,
              photoFile: _photoFile!,
            );
      }

      if (_voicePath != null) {
        voiceUrl = await ref.read(caregiverRepositoryProvider).uploadGreetingVoice(
              familyId: user.familyId,
              voiceFile: File(_voicePath!),
            );
      }

      await ref.read(greetingRepositoryProvider).saveGreeting(
            familyId: user.familyId,
            caregiverId: user.uid,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
            photoUrl: photoUrl,
            voiceUrl: voiceUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greeting sent!')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(currentAppUserProvider).valueOrNull?.displayName ?? 'You';

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Send love')),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 1,
                    totalSteps: 3,
                    title: 'Write a short message',
                    subtitle: 'Keep it warm and simple.',
                  ),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _prompts
                        .map(
                          (prompt) => ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              _messageController.text = prompt;
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Your message…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  PrimaryCta(label: 'Continue', onPressed: _nextPage),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 2,
                    totalSteps: 3,
                    title: 'Add a photo or voice (optional)',
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Take photo'),
                    onTap: () => _pickPhoto(ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () => _pickPhoto(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Record 15-second voice'),
                    subtitle: _voicePath != null ? const Text('Recording saved') : null,
                    onTap: _recordVoice,
                  ),
                  const Spacer(),
                  PrimaryCta(label: 'Preview', onPressed: _nextPage),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WizardStepHeader(
                    step: 3,
                    totalSteps: 3,
                    title: 'Preview as your parent will see it',
                  ),
                  GreetingCardWidget(
                    fromName: userName,
                    message: _messageController.text.trim().isEmpty
                        ? null
                        : _messageController.text.trim(),
                    localPhoto: _photoFile,
                    onPlayVoice: _voicePath != null ? () {} : null,
                  ),
                  const Spacer(),
                  PrimaryCta(
                    label: 'Send greeting',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
