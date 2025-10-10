import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import 'privacy_policy_page.dart';
import '../../services/notification_service.dart';
import 'package:hive/hive.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _analyticsEnabled = false;
  bool _crashReportsEnabled = false;
  bool _remindersEnabled = false;
  int _reminderDay = 5; // Friday
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _remindersEnabled = box.get('remindersEnabled', defaultValue: false);
      _reminderDay = box.get('reminderDay', defaultValue: 5);
      final hour = box.get('reminderHour', defaultValue: 18);
      final minute = box.get('reminderMinute', defaultValue: 0);
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }
  
  Future<void> _saveReminderSettings() async {
    final box = await Hive.openBox('settings');
    await box.put('remindersEnabled', _remindersEnabled);
    await box.put('reminderDay', _reminderDay);
    await box.put('reminderHour', _reminderTime.hour);
    await box.put('reminderMinute', _reminderTime.minute);
    
    final notificationService = ref.read(notificationServiceProvider);
    if (_remindersEnabled) {
      final hasPermission = await notificationService.requestPermissions();
      if (hasPermission) {
        await notificationService.scheduleWeeklyReminder(
          dayOfWeek: _reminderDay,
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder scheduled')),
          );
        }
      } else {
        setState(() => _remindersEnabled = false);
        await box.put('remindersEnabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission required')),
          );
        }
      }
    } else {
      await notificationService.cancelWeeklyReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder cancelled')),
        );
      }
    }
  }
  
  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• All reflections\n'
          '• All CPD entries\n'
          '• All year configurations\n'
          '• Your profile\n\n'
          'This action CANNOT be undone.\n\n'
          'Your account will remain active, but all data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final repo = ref.read(profileRepositoryProvider);
      final years = await repo.listYears();
      
      // Delete all years (includes reflections and CPD)
      for (final year in years) {
        await repo.deleteYear(year);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• Your account\n'
          '• All reflections\n'
          '• All CPD entries\n'
          '• All year configurations\n'
          '• Your profile\n\n'
          'This action CANNOT be undone.\n\n'
          'You will need to create a new account to use Metanoia again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // Delete all data first
      await _deleteAllData();
      
      // Delete account
      final authService = ref.read(authServiceProvider);
      await authService.deleteAccount();
      
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }
  
  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          // Account section
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            subtitle: Text(user?.email ?? 'Not logged in'),
          ),
          const Divider(),
          
          // Privacy & Data section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Privacy & Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.analytics),
            title: const Text('Anonymous Analytics'),
            subtitle: const Text('Help improve Metanoia with usage data'),
            value: _analyticsEnabled,
            onChanged: (value) {
              setState(() => _analyticsEnabled = value);
              // TODO: Save preference
            },
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.bug_report),
            title: const Text('Crash Reports'),
            subtitle: const Text('Send anonymous crash reports'),
            value: _crashReportsEnabled,
            onChanged: (value) {
              setState(() => _crashReportsEnabled = value);
              // TODO: Save preference and configure Sentry
            },
          ),
          
          const Divider(),
          
          // Reminders section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Reminders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Weekly Reflection Reminder'),
            subtitle: _remindersEnabled
                ? Text('${_getDayName(_reminderDay)} at ${_reminderTime.format(context)}')
                : const Text('Never miss a reflection'),
            value: _remindersEnabled,
            onChanged: (value) {
              setState(() => _remindersEnabled = value);
              _saveReminderSettings();
            },
          ),
          
          if (_remindersEnabled) ...[
            ListTile(
              leading: const SizedBox(width: 40),
              title: const Text('Reminder Day'),
              trailing: DropdownButton<int>(
                value: _reminderDay,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reminderDay = value);
                    _saveReminderSettings();
                  }
                },
              ),
            ),
            ListTile(
              leading: const SizedBox(width: 40),
              title: const Text('Reminder Time'),
              trailing: TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (time != null) {
                    setState(() => _reminderTime = time);
                    _saveReminderSettings();
                  }
                },
                child: Text(_reminderTime.format(context)),
              ),
            ),
          ],
          
          const Divider(),
          
          // Data management
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export All Data'),
            subtitle: const Text('Download your complete portfolio'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/export');
            },
          ),
          
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete All Data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Remove all reflections and CPD entries'),
            onTap: _deleteAllData,
          ),
          
          const Divider(),
          
          // Danger zone
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Danger Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Permanently delete your account and all data'),
            onTap: _deleteAccount,
          ),
          
          const SizedBox(height: 24),
          
          // App info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Metanoia v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'NHS Appraisal Assistant',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

