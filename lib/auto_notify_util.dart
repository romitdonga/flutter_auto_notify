import 'dart:math';

/// Utility functions for AutoNotify SDK
class AutoNotifyUtil {
  /// Random number generator
  static final Random _random = Random();

  /// Returns a random integer between min (inclusive) and max (inclusive)
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Returns a random item from a list
  static T randomItem<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot select a random item from an empty list');
    }
    return items[_random.nextInt(items.length)];
  }

  /// Returns a random pair of title and body from the pools
  /// If pools are empty, returns default values
  static Map<String, String> randomTitleBody(List<String> titlePool, List<String> bodyPool) {
    // Use defaults if pools are empty
    final titles = titlePool.isEmpty ? ["Hey there!"] : titlePool;
    final bodies = bodyPool.isEmpty ? ["Come back and have fun!"] : bodyPool;
    
    // Select a random index that exists in both lists
    final maxIndex = min(titles.length, bodies.length) - 1;
    final index = maxIndex >= 0 ? _random.nextInt(maxIndex + 1) : 0;
    
    return {
      'title': titles[index],
      'body': bodies[index >= bodies.length ? 0 : index],
    };
  }

  /// Calculates the next notification time based on configuration
  static DateTime calculateNextNotificationTime({
    required int hourStart,
    required int hourEnd,
    required int minuteJitter,
    required int cooldownDays,
    DateTime? lastFireDate,
  }) {
    // Ensure valid hour range
    final validHourStart = hourStart.clamp(0, 23);
    final validHourEnd = hourEnd.clamp(validHourStart + 1, 23);
    final validMinuteJitter = minuteJitter.clamp(0, 59);
    
    // Start with current date
    final now = DateTime.now();
    DateTime scheduledDate;
    
    // If we have a last fire date, respect cooldown period
    if (lastFireDate != null) {
      // Calculate minimum date based on cooldown
      final minimumDate = lastFireDate.add(Duration(days: cooldownDays));
      
      // If minimum date is in the future, use it as base
      if (minimumDate.isAfter(now)) {
        scheduledDate = DateTime(
          minimumDate.year,
          minimumDate.month,
          minimumDate.day,
        );
      } else {
        // Otherwise use today
        scheduledDate = DateTime(now.year, now.month, now.day);
      }
    } else {
      // No previous notification, use today
      scheduledDate = DateTime(now.year, now.month, now.day);
    }
    
    // If it's already past the end hour today, schedule for tomorrow
    if (now.hour >= validHourEnd) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Add random hour and minute
    final randomHour = randomInt(validHourStart, validHourEnd);
    final randomMinute = validMinuteJitter > 0 ? randomInt(0, validMinuteJitter) : 0;
    
    return scheduledDate.add(Duration(
      hours: randomHour,
      minutes: randomMinute,
    ));
  }

  /// Formats a DateTime for display or logging
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_pad(dateTime.month)}-${_pad(dateTime.day)} '
           '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}:${_pad(dateTime.second)}';
  }

  /// Pads a number with leading zero if needed
  static String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}