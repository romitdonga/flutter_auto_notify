import 'package:flutter/material.dart';
import 'auto_notify_sdk.dart';
import 'notification_test_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    ),
    enableDebugLogs: true,
  );
  
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Auto Notify Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Auto Notify SDK Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Enable notifications:'),
            Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            const SizedBox(height: 20),
            if (autoNotify.nextScheduledTime != null)
              Text(
                'Next scheduled: ${autoNotify.nextScheduledTime.toString()}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationTestApp(),
                  ),
                );
              },
              child: const Text('Open Notification Tester'),
            ),
          ],
        ),
      ),
    );
  }
}