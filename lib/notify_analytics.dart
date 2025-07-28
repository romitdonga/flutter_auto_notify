import 'package:flutter/foundation.dart';

/// A callback function type for handling analytics events
typedef AnalyticsCallback = void Function(String eventName, Map<String, dynamic> parameters);

/// Analytics events for the auto notification system
class NotifyAnalytics {
  /// Callback function for handling analytics events
  final AnalyticsCallback? onEvent;

  /// Creates a new NotifyAnalytics instance
  const NotifyAnalytics({this.onEvent});

  /// Logs an event with the given name and parameters
  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    final callback = onEvent;
    if (callback != null) {
      callback(eventName, parameters ?? {});
    }
  }

  /// Logs when a notification is scheduled
  void logScheduled(DateTime scheduledTime) {
    logEvent('notify_scheduled', {
      'scheduled_time': _formatDateTime(scheduledTime),
    });
  }

  /// Logs when a notification is fired/shown
  void logFired() {
    logEvent('notify_fired');
  }

  /// Logs when a notification is opened by the user
  void logOpened() {
    logEvent('notify_opened');
  }

  /// Logs when notification permission is denied
  void logPermissionDenied() {
    logEvent('notify_permission_denied');
  }

  /// Logs when notification permission is granted
  void logPermissionGranted() {
    logEvent('notify_permission_granted');
  }

  /// Logs when notification permission is requested
  void logPermissionRequested() {
    logEvent('notify_permission_requested');
  }

  /// Logs when notifications are enabled by the user
  void logEnabled() {
    logEvent('notify_enabled');
  }

  /// Logs when notifications are disabled by the user
  void logDisabled() {
    logEvent('notify_disabled');
  }

  /// Logs when the notification feature is initialized
  void logInitialized(Map<String, dynamic> config) {
    logEvent('notify_initialized', config);
  }

  /// Formats a DateTime for logging
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_pad(dateTime.month)}-${_pad(dateTime.day)} '
           '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}:${_pad(dateTime.second)}';
  }

  /// Pads a number with leading zero if needed
  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}