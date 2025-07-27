/// Configuration model for AutoNotify SDK with default values
/// This class holds all configurable parameters for the notification system
class AutoNotifyConfig {
  /// Master toggle. If 0, SDK does not run (no permission check, no scheduling)
  final int notifyInitialize;

  /// Titles randomly picked for notifications
  final List<String> titlePool;

  /// Bodies randomly picked for notifications (matched by index to titlePool)
  final List<String> bodyPool;

  /// Earliest possible hour for scheduling (0-23)
  final int hourStart;

  /// Latest hour for scheduling (0-23). Must be > hourStart
  final int hourEnd;

  /// Adds random minutes to avoid robotic notifications (0-59)
  final int minuteJitter;

  /// Minimum full days between notifications
  final int cooldownDays;

  /// Used on Android notification channel
  final String androidChannelId;

  /// Customizable notification icon
  final String iconPath;

  /// Callback for analytics events (notify_scheduled, notify_fired, etc.)
  final Function(String, Map<String, dynamic>?)? analytics;

  /// Creates a new configuration with specified values or defaults
  const AutoNotifyConfig({
    this.notifyInitialize = 0,
    this.titlePool = const ["Hey there!"],
    this.bodyPool = const ["Come back and have fun!"],
    this.hourStart = 9,
    this.hourEnd = 21,
    this.minuteJitter = 0,
    this.cooldownDays = 1,
    this.androidChannelId = "daily_reminder",
    this.iconPath = "@mipmap/ic_launcher",
    this.analytics,
  }) : assert(hourEnd > hourStart, 'hourEnd must be greater than hourStart');

  /// Creates a copy of this configuration with specified values replaced
  AutoNotifyConfig copyWith({
    int? notifyInitialize,
    List<String>? titlePool,
    List<String>? bodyPool,
    int? hourStart,
    int? hourEnd,
    int? minuteJitter,
    int? cooldownDays,
    String? androidChannelId,
    String? iconPath,
    Function(String, Map<String, dynamic>?)? analytics,
  }) {
    return AutoNotifyConfig(
      notifyInitialize: notifyInitialize ?? this.notifyInitialize,
      titlePool: titlePool ?? this.titlePool,
      bodyPool: bodyPool ?? this.bodyPool,
      hourStart: hourStart ?? this.hourStart,
      hourEnd: hourEnd ?? this.hourEnd,
      minuteJitter: minuteJitter ?? this.minuteJitter,
      cooldownDays: cooldownDays ?? this.cooldownDays,
      androidChannelId: androidChannelId ?? this.androidChannelId,
      iconPath: iconPath ?? this.iconPath,
      analytics: analytics ?? this.analytics,
    );
  }
}