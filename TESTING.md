# Testing the Auto Notify SDK

This document provides guidance on how to test the Auto Notify SDK functionality without waiting for scheduled notifications.

## Testing Options

### 1. Using the Notification Test App

We've included a test application that allows you to send immediate and short-delayed notifications to verify that your notification setup is working correctly.

#### How to run the test app:

```bash
flutter run -t lib/test_main.dart
```

This will launch a test application with the following features:

- Toggle to enable/disable notifications
- Button to open the notification tester
- Display of the next scheduled notification time

In the notification tester screen, you can:

- Send an immediate notification
- Send a notification with a 5-second delay
- Cancel all pending notifications

### 2. Modifying the Scheduled Time for Testing

If you want to test the actual scheduled notification functionality but don't want to wait for the calculated time, you can temporarily modify the `calculateNextNotificationTime` method in your test environment:

```dart
// Add this method to your test code
DateTime testCalculateNextNotificationTime() {
  // Return a time just a few seconds in the future
  return DateTime.now().add(const Duration(seconds: 10));
}

// Then replace the normal calculation with this test version
// in your test environment
```

### 3. Manual Testing with System Clock

You can also test by changing your device's system time:

1. Schedule a notification using the SDK
2. Note the scheduled time
3. Change your device's system time to a few minutes before the scheduled time
4. Wait for the notification to appear

**Note:** This method may not work on all devices and can have side effects on other apps.

## Debugging Notifications

### Check Notification Permissions

Ensure that your app has the necessary permissions:

- On Android: Settings > Apps > Your App > Permissions > Notifications
- On iOS: Settings > Your App > Notifications

### Enable Debug Logs

Enable debug logs when initializing the SDK:

```dart
await autoNotify.init(
  config: yourConfig,
  enableDebugLogs: true,
);
```

### Check for Errors

Monitor the console for any error messages related to notifications.

## Testing on Different Platforms

### Android

- Test on different Android versions (especially Android 8+ with notification channels)
- Test with app in foreground, background, and killed states

### iOS

- Test with app in foreground, background, and killed states
- Verify that notification permissions are properly requested

## Troubleshooting

### Notifications Not Appearing

1. Verify that notifications are enabled in system settings
2. Check that the SDK is properly initialized
3. Ensure that the notification channel is created (Android)
4. Verify that permissions are granted

### Scheduling Issues

1. Check that the timezone initialization is working correctly
2. Verify that the cooldown period is being respected
3. Check that the hour range is valid

## Integration Testing

For automated testing, you can use Flutter's integration testing framework to verify that notifications are properly scheduled and displayed.

Refer to the `test` directory for examples of unit tests for the SDK components.