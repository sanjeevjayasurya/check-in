import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';

class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() =>
      _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  late int _deadlineHour;
  late int _deadlineMinute;
  late bool _escalationEnabled;
  late bool _lowBatteryAlerts;
  final _contactController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings =
        ref.read(currentFamilyProvider).valueOrNull?.alertSettings ??
            AlertSettings.defaults;
    _deadlineHour = settings.deadlineHour;
    _deadlineMinute = settings.deadlineMinute;
    _escalationEnabled = settings.escalationEnabled;
    _lowBatteryAlerts = settings.lowBatteryAlertsEnabled;
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final family = ref.read(currentFamilyProvider).valueOrNull;
      final user = await ref.read(currentAppUserProvider.future);
      if (family == null || user == null) return;

      final contacts = List<String>.from(family.alertSettings.emergencyContacts);
      final newContact = _contactController.text.trim();
      if (newContact.isNotEmpty && !contacts.contains(newContact)) {
        contacts.add(newContact);
      }

      await ref.read(caregiverRepositoryProvider).updateAlertSettings(
            familyId: family.id,
            settings: AlertSettings(
              deadlineHour: _deadlineHour,
              deadlineMinute: _deadlineMinute,
              emergencyContacts: contacts,
              escalationEnabled: _escalationEnabled,
              lowBatteryAlertsEnabled: _lowBatteryAlerts,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert settings saved.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _deadlineHour, minute: _deadlineMinute),
    );
    if (picked != null) {
      setState(() {
        _deadlineHour = picked.hour;
        _deadlineMinute = picked.minute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineLabel =
        '${_deadlineHour.toString().padLeft(2, '0')}:${_deadlineMinute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Check-in Deadline'),
            subtitle: Text('Alert if not checked in by $deadlineLabel'),
            trailing: const Icon(Icons.schedule),
            onTap: _pickDeadline,
          ),
          SwitchListTile(
            title: const Text('Escalation Alerts'),
            subtitle: const Text('Notify emergency contacts if check-in missed'),
            value: _escalationEnabled,
            onChanged: (value) => setState(() => _escalationEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Low Battery Alerts'),
            value: _lowBatteryAlerts,
            onChanged: (value) => setState(() => _lowBatteryAlerts = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactController,
            decoration: const InputDecoration(
              labelText: 'Add Emergency Contact (phone)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
