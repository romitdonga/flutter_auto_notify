import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auto_notify/auto_notify_config.dart';
import 'package:flutter_auto_notify/auto_notify_util.dart';

void main() {
  group('AutoNotifyConfig Tests', () {
    test('Default values are set correctly', () {
      const config = AutoNotifyConfig();
      
      expect(config.notifyInitialize, 0);
      expect(config.titlePool, ["Hey there!"]);
      expect(config.bodyPool, ["Come back and have fun!"]);
      expect(config.hourStart, 9);
      expect(config.hourEnd, 21);
      expect(config.minuteJitter, 0);
      expect(config.cooldownDays, 1);
      expect(config.androidChannelId, "daily_reminder");
      expect(config.iconPath, "@mipmap/ic_launcher");
      expect(config.analytics, null);
    });
    
    test('Custom values are set correctly', () {
      final mockAnalytics = (String event, Map<String, dynamic>? params) {};
      
      const config = AutoNotifyConfig(
        notifyInitialize: 1,
        titlePool: ["Custom Title"],
        bodyPool: ["Custom Body"],
        hourStart: 10,
        hourEnd: 20,
        minuteJitter: 15,
        cooldownDays: 2,
        androidChannelId: "custom_channel",
        iconPath: "@drawable/custom_icon",
      );
      
      expect(config.notifyInitialize, 1);
      expect(config.titlePool, ["Custom Title"]);
      expect(config.bodyPool, ["Custom Body"]);
      expect(config.hourStart, 10);
      expect(config.hourEnd, 20);
      expect(config.minuteJitter, 15);
      expect(config.cooldownDays, 2);
      expect(config.androidChannelId, "custom_channel");
      expect(config.iconPath, "@drawable/custom_icon");
    });
    
    test('copyWith creates a new instance with updated values', () {
      const original = AutoNotifyConfig();
      final updated = original.copyWith(
        notifyInitialize: 1,
        hourStart: 10,
      );
      
      expect(updated.notifyInitialize, 1);
      expect(updated.hourStart, 10);
      
      // Other values should remain the same
      expect(updated.titlePool, original.titlePool);
      expect(updated.bodyPool, original.bodyPool);
      expect(updated.hourEnd, original.hourEnd);
    });
    
    test('assert validates hourEnd > hourStart', () {
      expect(() => AutoNotifyConfig(hourStart: 12, hourEnd: 10), 
          throwsA(isA<AssertionError>()));
    });
  });
  
  group('AutoNotifyUtil Tests', () {
    test('randomInt returns value within range', () {
      for (int i = 0; i < 100; i++) {
        final value = AutoNotifyUtil.randomInt(5, 10);
        expect(value, greaterThanOrEqualTo(5));
        expect(value, lessThanOrEqualTo(10));
      }
    });
    
    test('randomItem returns item from list', () {
      final list = [1, 2, 3, 4, 5];
      final item = AutoNotifyUtil.randomItem(list);
      expect(list.contains(item), true);
    });
    
    test('randomItem throws on empty list', () {
      expect(() => AutoNotifyUtil.randomItem([]), throwsArgumentError);
    });
    
    test('randomTitleBody returns matching pairs', () {
      final titles = ['Title 1', 'Title 2', 'Title 3'];
      final bodies = ['Body 1', 'Body 2', 'Body 3'];
      
      final result = AutoNotifyUtil.randomTitleBody(titles, bodies);
      
      expect(result.containsKey('title'), true);
      expect(result.containsKey('body'), true);
      expect(titles.contains(result['title']), true);
      expect(bodies.contains(result['body']), true);
    });
    
    test('randomTitleBody handles empty pools', () {
      final result = AutoNotifyUtil.randomTitleBody([], []);
      
      expect(result['title'], "Hey there!");
      expect(result['body'], "Come back and have fun!");
    });
    
    test('calculateNextNotificationTime respects cooldown', () {
      final now = DateTime.now();
      final lastFire = now.subtract(const Duration(hours: 12)); // Less than 1 day ago
      
      final nextTime = AutoNotifyUtil.calculateNextNotificationTime(
        hourStart: 9,
        hourEnd: 21,
        minuteJitter: 0,
        cooldownDays: 1,
        lastFireDate: lastFire,
      );
      
      // Should be scheduled for tomorrow (cooldown = 1 day)
      final expectedMinimum = lastFire.add(const Duration(days: 1));
      expect(nextTime.year, expectedMinimum.year);
      expect(nextTime.month, expectedMinimum.month);
      expect(nextTime.day, expectedMinimum.day);
      
      // Hour should be between hourStart and hourEnd
      expect(nextTime.hour, greaterThanOrEqualTo(9));
      expect(nextTime.hour, lessThanOrEqualTo(21));
    });
  });
}