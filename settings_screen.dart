import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Daily Workout Reminder'),
            subtitle: const Text('Get reminded to workout every day'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              if (value) {
                await NotificationService.instance.scheduleDailyReminder(
                  hour: _reminderTime.hour,
                  minute: _reminderTime.minute,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daily reminder enabled')),
                  );
                }
              } else {
                await NotificationService.instance.cancelDailyReminder();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daily reminder disabled')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(_reminderTime.format(context)),
            leading: const Icon(Icons.access_time),
            enabled: _notificationsEnabled,
            onTap: _notificationsEnabled
                ? () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (time != null) {
                      setState(() => _reminderTime = time);
                      await NotificationService.instance.scheduleDailyReminder(
                        hour: time.hour,
                        minute: time.minute,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reminder time updated to ${time.format(context)}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                : null,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
            leading: Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            leading: const Icon(Icons.notifications),
            onTap: () async {
              await NotificationService.instance.showNotification(
                id: 999,
                title: 'Test Notification',
                body: 'This is a test notification from Fitness Tracker!',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
