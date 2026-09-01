import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunsafe_checkin/app.dart';
import 'package:sunsafe_checkin/core/providers/service_providers.dart';
import 'package:sunsafe_checkin/core/theme/app_spacing.dart';
import 'package:sunsafe_checkin/core/utils/user_friendly_error.dart';
import 'package:sunsafe_checkin/core/widgets/primary_cta.dart';
import 'package:sunsafe_checkin/features/auth/providers/auth_providers.dart';
import 'package:sunsafe_checkin/models/alert_settings.dart';
import 'package:sunsafe_checkin/models/user_role.dart';

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
  late List<String> _contacts;
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
    _contacts = List<String>.from(settings.emergencyContacts);
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
      if (family == null) return;

      await ref.read(caregiverRepositoryProvider).updateAlertSettings(
            familyId: family.id,
            settings: AlertSettings(
              deadlineHour: _deadlineHour,
              deadlineMinute: _deadlineMinute,
              emergencyContacts: _contacts,
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

  void _addContact() {
    final value = _contactController.text.trim();
    if (value.isEmpty || _contacts.contains(value)) return;
    setState(() {
      _contacts.add(value);
      _contactController.clear();
    });
  }

  void _removeContact(String contact) {
    setState(() => _contacts.remove(contact));
  }

  @override
  Widget build(BuildContext context) {
    final deadlineLabel =
        '${_deadlineHour.toString().padLeft(2, '0')}:${_deadlineMinute.toString().padLeft(2, '0')}';

    return RoleThemedScope(
      role: UserRole.caregiver,
      child: Scaffold(
        appBar: AppBar(title: const Text('Alert Settings')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ListTile(
              title: const Text('Check-in deadline'),
              subtitle: Text('Alert if not checked in by $deadlineLabel'),
              trailing: const Icon(Icons.schedule),
              onTap: _pickDeadline,
            ),
            SwitchListTile(
              title: const Text('Escalation alerts'),
              subtitle: const Text('Notify emergency contacts if check-in is missed'),
              value: _escalationEnabled,
              onChanged: (value) => setState(() => _escalationEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Low battery alerts'),
              value: _lowBatteryAlerts,
              onChanged: (value) => setState(() => _lowBatteryAlerts = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Emergency contacts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (_contacts.isEmpty)
              const Text('Add a phone number your parent can call for help.'),
            ..._contacts.map(
              (contact) => ListTile(
                title: Text(contact),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeContact(contact),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _addContact,
                  child: const Text('Add'),
                ),
              ],
            ),
            if (_contacts.isNotEmpty && _escalationEnabled) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'If ${_contacts.first} is unavailable, we notify the next contact in order.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryCta(
              label: 'Save settings',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
