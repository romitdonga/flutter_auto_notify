import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auto_notify/auto_notify_sdk.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('AutoNotify SDK with notifyInitialize=0', () {
    late AutoNotifyConfig config;
    
    setUp(() {
      // Create a config with notifyInitialize set to 0
      config = const AutoNotifyConfig(
        notifyInitialize: 0,
        hourStart: 9,
        hourEnd: 21,
        cooldownDays: 1,
      );
    });
    
    test('SDK should not be initialized when notifyInitialize=0', () async {
      // Initialize the SDK with notifyInitialize=0
      await autoNotify.init(config: config);
      
      // Verify that the SDK is not initialized
      expect(autoNotify.isInitialized, false);
    });
    
    test('Timezone functionality should still work when notifyInitialize=0', () async {
      // Initialize the SDK with notifyInitialize=0
      await autoNotify.init(config: config);
      
      // Verify that timezone functionality works
      // This should not throw an exception
      final now = tz.TZDateTime.now(tz.local);
      expect(now, isNotNull);
    });
    
    test('Notification scheduling should not work when notifyInitialize=0', () async {
      // Initialize the SDK with notifyInitialize=0
      await autoNotify.init(config: config);
      
      // Try to enable notifications
      await autoNotify.setEnabled(true);
      
      // Verify that the next scheduled time is still null
      expect(autoNotify.nextScheduledTime, isNull);
    });
    
    test('SDK should work normally when notifyInitialize is non-zero', () async {
      // Create a config with notifyInitialize set to 1
      final enabledConfig = config.copyWith(notifyInitialize: 1);
      
      // Initialize the SDK with notifyInitialize=1
      await autoNotify.init(config: enabledConfig);
      
      // Verify that the SDK is initialized
      expect(autoNotify.isInitialized, true);
    });
  });
}