import 'package:flutter/material.dart';
import 'package:flutter_auto_notify/flutter_auto_notify.dart';

import 'test_notifications.dart';

class NotificationTestApp extends StatefulWidget {
  const NotificationTestApp({super.key});

  @override
  State<NotificationTestApp> createState() => _NotificationTestAppState();
}

class _NotificationTestAppState extends State<NotificationTestApp> {
  late NotificationTester _notificationTester;
  String _status = 'Ready to test';

  @override
  void initState() {
    super.initState();
    // Get the plugin instance from the AutoNotifyManager
    final plugin = autoNotify.getNotificationPlugin();
    _notificationTester = NotificationTester(plugin);
  }

  // Send an immediate test notification
  Future<void> _sendImmediateNotification() async {
    setState(() {
      _status = 'Sending immediate notification...';
    });

    try {
      await _notificationTester.sendImmediateTestNotification(
        title: 'Immediate Test',
        body: 'This notification appears immediately',
      );
      setState(() {
        _status = 'Immediate notification sent!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  // Send a notification with a short delay
  Future<void> _sendDelayedNotification() async {
    setState(() {
      _status = 'Scheduling notification in 5 seconds...';
    });

    try {
      await _notificationTester.sendDelayedTestNotification(
        title: 'Delayed Test',
        body: 'This notification appears after a short delay',
        delaySeconds: 5,
      );
      setState(() {
        _status = 'Notification scheduled for 5 seconds from now!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  // Cancel all notifications
  Future<void> _cancelNotifications() async {
    setState(() {
      _status = 'Cancelling all notifications...';
    });

    try {
      await _notificationTester.cancelAllNotifications();
      setState(() {
        _status = 'All notifications cancelled!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Tester')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Status: $_status',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _sendImmediateNotification,
              child: const Text('Send Immediate Notification'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendDelayedNotification,
              child: const Text('Send Notification in 5 seconds'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _cancelNotifications,
              child: const Text('Cancel All Notifications'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Note: Make sure notifications are enabled in system settings',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
