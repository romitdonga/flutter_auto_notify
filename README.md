# Flutter Auto Notify SDK

A reusable Flutter SDK to send one friendly, non-intrusive local notification per day (Android & iOS) to remind users your app exists.

## Features

✅ 100% user-respect (only sends if permission granted)  
✅ Zero Firebase dependencies  
✅ Totally configurable  
✅ Non-intrusive and automatic  
✅ Settings toggle support  
✅ No crash even if user denies permission or notification fails  
✅ Fully loggable  

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_auto_notify: ^1.0.0
```

## Usage

### Initialize the SDK

Initialize the SDK in your `main.dart` file:

```dart
import 'package:flutter_auto_notify/auto_notify_sdk.dart';

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
    enableDebugLogs: true, // Set to false in production
  );
  
  runApp(const MyApp());
}
```

### Add a Toggle in Settings

Add a toggle in your settings screen to allow users to enable/disable notifications:

```dart
Switch(
  value: autoNotify.isEnabled,
  onChanged: (value) async {
    await autoNotify.setEnabled(value);
    setState(() {}); // Refresh UI
  },
),
```

### Open System Settings

Provide a way for users to open system notification settings:

```dart
ElevatedButton(
  onPressed: () => autoNotify.openSystemSettings(),
  child: const Text('Open System Settings'),
),
```

## Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| notifyInitialize | int (0/1) | 0 | Master toggle. If 0, SDK does not run |
| titlePool | List<String> | ["Hey there!"] | Titles randomly picked |
| bodyPool | List<String> | ["Come back and have fun!"] | Bodies randomly picked |
| hourStart | int (0-23) | 9 | Earliest possible hour for scheduling |
| hourEnd | int (0-23) | 21 | Latest hour. Must be > hourStart |
| minuteJitter | int (0-59) | 0 | Adds random minutes to avoid robotic notifications |
| cooldownDays | int | 1 | Minimum full days between notifications |
| androidChannelId | String | "daily_reminder" | Used on Android notification channel |
| iconPath | String | "@mipmap/ic_launcher" | Customizable notification icon |
| analytics | Function(String, Map?)? | null | Callback for analytics events |

## Analytics Events

The SDK provides the following analytics events:

| Event Name | Parameters | Description |
|------------|------------|--------------|
| notify_permission_denied | {} | User denied notification permission |
| notify_scheduled | {fire_time} | Notification scheduled successfully |
| notify_fired | {} | Notification was displayed |
| notify_opened | {} | User tapped on notification |

## Permission & Toggle Logic

- If `notifyInitialize == 0` → SDK does nothing
- If permission denied → Log event and re-ask after 24 hours
- If permission granted → Schedule notification based on config
- User can toggle notifications on/off via `setEnabled()`

## License

MIT
