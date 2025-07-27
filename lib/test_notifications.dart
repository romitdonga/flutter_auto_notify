import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Utility class for testing notifications
class NotificationTester {
  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Constructor that takes the plugin instance
  NotificationTester(this._flutterLocalNotificationsPlugin);

  /// Send an immediate test notification
  Future<void> sendImmediateTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
    String? payload,
  }) async {
    // Create Android notification details
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Channel for test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Create iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create notification details for all platforms
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification immediately
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Send a test notification scheduled for a few seconds from now
  Future<void> sendDelayedTestNotification({
    String title = 'Delayed Test Notification',
    String body = 'This is a delayed test notification',
    String? payload,
    int delaySeconds = 5,
  }) async {
    // Create Android notification details
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Channel for test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Create iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Create notification details for all platforms
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate scheduled time (a few seconds from now)
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Notification ID
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}