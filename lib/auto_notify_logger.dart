import 'package:flutter/foundation.dart';

/// Logger utility for AutoNotify SDK
/// Handles debug logging and analytics events
class AutoNotifyLogger {
  /// Function to handle analytics events
  final Function(String, Map<String, dynamic>?)? analyticsCallback;

  /// Whether to enable debug logging
  final bool enableDebugLogs;

  /// Creates a new logger with specified analytics callback and debug logging flag
  const AutoNotifyLogger({
    this.analyticsCallback,
    this.enableDebugLogs = kDebugMode,
  });

  /// Logs a debug message if debug logging is enabled
  void debug(String message) {
    if (enableDebugLogs) {
      debugPrint('AutoNotify: $message');
    }
  }

  /// Logs an error message if debug logging is enabled
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableDebugLogs) {
      debugPrint('AutoNotify ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Tracks an analytics event with optional parameters
  void trackEvent(String eventName, [Map<String, dynamic>? params]) {
    debug('Event: $eventName ${params ?? ''}');
    analyticsCallback?.call(eventName, params);
  }

  /// Predefined analytics events
  static const String eventPermissionDenied = 'notify_permission_denied';
  static const String eventScheduled = 'notify_scheduled';
  static const String eventFired = 'notify_fired';
  static const String eventOpened = 'notify_opened';
}
