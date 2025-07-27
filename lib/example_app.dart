import 'package:flutter/material.dart';
import 'auto_notify_sdk.dart';

/// Example app demonstrating how to use the AutoNotify SDK
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoNotify Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotificationSettingsScreen(),
    );
  }
}

/// Example settings screen with notification toggle
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  // Load the current notification state
  Future<void> _loadNotificationState() async {
    final enabled = autoNotify.isEnabled;
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  // Toggle notifications on/off
  Future<void> _toggleNotifications(bool value) async {
    await autoNotify.setEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Daily reminder toggle
            ListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Receive a friendly reminder once per day'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
            
            const Divider(),
            
            // System settings button
            ListTile(
              title: const Text('System Notification Settings'),
              subtitle: const Text('Manage all app notifications in system settings'),
              trailing: const Icon(Icons.settings),
              onTap: () => autoNotify.openSystemSettings(),
            ),
            
            const SizedBox(height: 32),
            
            // Next notification info
            if (autoNotify.nextScheduledTime != null) ...[  
              const Text(
                'Next Notification:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                autoNotify.nextScheduledTime.toString(),
              ),
            ],
            
            const Spacer(),
            
            // SDK info
            const Center(
              child: Text(
                'Flutter Auto Notify SDK',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to initialize the SDK
void initializeAutoNotify() async {
  // Initialize the AutoNotify SDK with configuration
  await autoNotify.init(
    config: const AutoNotifyConfig(
      notifyInitialize: 1, // Enable the SDK
      titlePool: [
        'Hey there!',
        'Miss you!',
        'Come back!',
      ],
      bodyPool: [
        'Come back and have fun!',
        'We have new content for you!',
        'Your friends are waiting for you!',
      ],
      hourStart: 9,
      hourEnd: 21,
      minuteJitter: 30,
      cooldownDays: 1,
      // Custom analytics callback
      analytics: _trackAnalyticsEvent,
    ),
    enableDebugLogs: true, // Set to false in production
  );
}

/// Example analytics callback
void _trackAnalyticsEvent(String eventName, Map<String, dynamic>? params) {
  // Integrate with your analytics system
  print('Analytics event: $eventName, params: $params');
}