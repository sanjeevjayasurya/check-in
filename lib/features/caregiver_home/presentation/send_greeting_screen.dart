import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';

class SendGreetingScreen extends ConsumerStatefulWidget {
  const SendGreetingScreen({super.key});

  @override
  ConsumerState<SendGreetingScreen> createState() => _SendGreetingScreenState();
}

class _SendGreetingScreenState extends ConsumerState<SendGreetingScreen> {
  final _messageController = TextEditingController();
  File? _photoFile;
  String? _voicePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
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
          SnackBar(content: Text(error.toString())),
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
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Daily Greeting')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Short message (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Add Photo'),
            subtitle: _photoFile != null ? Text(_photoFile!.path.split('/').last) : null,
            onTap: _pickPhoto,
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Record 15-Second Voice Note'),
            subtitle: _voicePath != null ? const Text('Recording saved') : null,
            onTap: _recordVoice,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text('Send Greeting'),
          ),
        ],
      ),
    );
  }
}
