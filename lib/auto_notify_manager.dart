import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import 'auto_notify_config.dart';
import 'auto_notify_logger.dart';
import 'auto_notify_util.dart';
import 'notify_analytics.dart';

/// Core manager class for AutoNotify SDK
/// Handles initialization, scheduling, and toggle functionality
class AutoNotifyManager {
  /// Singleton instance
  static final AutoNotifyManager _instance = AutoNotifyManager._internal();

  /// Factory constructor to return the singleton instance
  factory AutoNotifyManager() => _instance;

  /// Internal constructor
  AutoNotifyManager._internal();

  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  /// Get the notification plugin instance for testing purposes
  FlutterLocalNotificationsPlugin getNotificationPlugin() {
    return _flutterLocalNotificationsPlugin;
  }

  /// Configuration for the notification system
  late AutoNotifyConfig _config;

  /// Logger for debug and analytics
  late AutoNotifyLogger _logger;
  
  /// Analytics for tracking events
  NotifyAnalytics? _analytics;

  /// Whether notifications are enabled by the user
  bool _isEnabled = false;

  /// Whether the SDK has been initialized
  bool _isInitialized = false;

  /// Last time a notification was fired
  DateTime? _lastFireDate;

  /// Next scheduled notification time
  DateTime? _nextScheduledTime;
  
  /// Last time permission was requested
  DateTime? _lastPermissionRequest;
  
  /// Whether a notification is currently scheduled
  bool _isNotificationScheduled = false;

  /// Shared preferences key for enabled state
  static const String _prefKeyEnabled = 'auto_notify_enabled';

  /// Shared preferences key for last fire date
  static const String _prefKeyLastFire = 'auto_notify_last_fire';
  
  /// Shared preferences key for next scheduled time
  static const String _prefKeyNextScheduled = 'auto_notify_next_scheduled';
  
  /// Shared preferences key for last permission request
  static const String _prefKeyLastPermissionRequest = 'auto_notify_last_permission_request';

  /// Notification ID for the daily reminder
  static const int _notificationId = 1;

  /// Returns whether notifications are enabled by the user
  bool get isEnabled => _isEnabled;

  /// Returns whether the SDK has been initialized
  bool get isInitialized => _isInitialized;

  /// Returns the last time a notification was fired
  DateTime? get lastFireDate => _lastFireDate;

  /// Returns the next scheduled notification time
  DateTime? get nextScheduledTime => _nextScheduledTime;

  /// Initializes the SDK with the provided configuration
  /// Returns a Future that completes when initialization is done
  Future<void> init({
    AutoNotifyConfig? config,
    bool enableDebugLogs = false,
    NotifyAnalytics? analytics,
  }) async {
    try {
      // Set configuration and logger
      _config = config ?? const AutoNotifyConfig();
      _analytics = analytics;
      _logger = AutoNotifyLogger(
        analyticsCallback: _config.analytics,
        enableDebugLogs: enableDebugLogs,
      );

      _logger.debug('Initializing AutoNotify SDK');
      
      // Initialize timezone (even if SDK is disabled, to avoid errors)
      tz_data.initializeTimeZones();
      
      // Load preferences (even if SDK is disabled, to maintain state)
      await _loadPreferences();

      // Check master toggle - exit early but after initializing timezone and loading prefs
      if (_config.notifyInitialize == 0) {
        _logger.debug('SDK disabled via notifyInitialize=0');
        _isInitialized = false;
        return;
      }
      
      // Set initialized to true for non-zero notifyInitialize
      _isInitialized = true;
      
      // Log initialization with analytics
      _analytics?.logInitialized({
        'notifyInitialize': _config.notifyInitialize,
        'hourStart': _config.hourStart,
        'hourEnd': _config.hourEnd,
        'minuteJitter': _config.minuteJitter,
        'cooldownDays': _config.cooldownDays,
      });

      // Initialize notifications plugin
      await _initializeLocalNotifications();

      // Check notification permission
      final permissionStatus = await _checkNotificationPermission();

      if (permissionStatus) {
        _logger.debug('Notification permission granted');
        _analytics?.logPermissionGranted();
        
        if (_isEnabled) {
          // Only schedule a new notification if one isn't already scheduled
          // or if the scheduled time is in the past
          if (!_isNotificationScheduled || 
              (_nextScheduledTime != null && _nextScheduledTime!.isBefore(DateTime.now()))) {
            await _scheduleNotification();
          } else {
            _logger.debug('Notification already scheduled for: ${_nextScheduledTime != null ? AutoNotifyUtil.formatDateTime(_nextScheduledTime!) : "unknown"}');
          }
        } else {
          _logger.debug('Notifications disabled by user preference');
        }
      } else {
        _logger.debug('Notification permission denied');
        _logger.trackEvent(AutoNotifyLogger.eventPermissionDenied);
        _analytics?.logPermissionDenied();
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize SDK', e, stackTrace);
    }
  }

  /// Loads user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load enabled state (default to true for first-time users)
      _isEnabled = prefs.getBool(_prefKeyEnabled) ?? true;
      
      // Load last fire date
      final lastFireMillis = prefs.getInt(_prefKeyLastFire);
      if (lastFireMillis != null) {
        _lastFireDate = DateTime.fromMillisecondsSinceEpoch(lastFireMillis);
        _logger.debug('Last notification fired at: ${AutoNotifyUtil.formatDateTime(_lastFireDate!)}');
      }
      
      // Load next scheduled time
      final nextScheduledMillis = prefs.getInt(_prefKeyNextScheduled);
      if (nextScheduledMillis != null) {
        _nextScheduledTime = DateTime.fromMillisecondsSinceEpoch(nextScheduledMillis);
        _isNotificationScheduled = true;
        _logger.debug('Next notification scheduled for: ${AutoNotifyUtil.formatDateTime(_nextScheduledTime!)}');
      }
      
      // Load last permission request time
      final lastPermissionRequestMillis = prefs.getInt(_prefKeyLastPermissionRequest);
      if (lastPermissionRequestMillis != null) {
        _lastPermissionRequest = DateTime.fromMillisecondsSinceEpoch(lastPermissionRequestMillis);
        _logger.debug('Last permission request at: ${AutoNotifyUtil.formatDateTime(_lastPermissionRequest!)}');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to load preferences', e, stackTrace);
      // Default values if preferences can't be loaded
      _isEnabled = true;
      _lastFireDate = null;
      _nextScheduledTime = null;
      _lastPermissionRequest = null;
      _isNotificationScheduled = false;
    }
  }

  /// Saves user preferences to SharedPreferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save enabled state
      await prefs.setBool(_prefKeyEnabled, _isEnabled);
      
      // Save last fire date if available
      if (_lastFireDate != null) {
        await prefs.setInt(_prefKeyLastFire, _lastFireDate!.millisecondsSinceEpoch);
      }
      
      // Save next scheduled time if available
      if (_nextScheduledTime != null) {
        await prefs.setInt(_prefKeyNextScheduled, _nextScheduledTime!.millisecondsSinceEpoch);
      } else {
        await prefs.remove(_prefKeyNextScheduled);
      }
      
      // Save last permission request time if available
      if (_lastPermissionRequest != null) {
        await prefs.setInt(_prefKeyLastPermissionRequest, _lastPermissionRequest!.millisecondsSinceEpoch);
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to save preferences', e, stackTrace);
    }
  }

  /// Initializes the local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      // Initialize settings for Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Initialize settings for iOS
      const iosSettings = DarwinInitializationSettings();
      
      // Initialize settings for all platforms
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      
      _logger.debug('Local notifications plugin initialized');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize local notifications', e, stackTrace);
      rethrow;
    }
  }

  /// Handles notification responses (taps)
  void _onNotificationResponse(NotificationResponse response) {
    try {
      _logger.debug('Notification tapped: ${response.id}');
      _logger.trackEvent(AutoNotifyLogger.eventOpened);
      _analytics?.logOpened();
    } catch (e, stackTrace) {
      _logger.error('Error handling notification response', e, stackTrace);
    }
  }

  /// Checks if notification permission is granted
  /// Returns true if granted, false otherwise
  Future<bool> _checkNotificationPermission() async {
    try {
      // Check if we should request permission based on last request time
      final now = DateTime.now();
      final shouldRequestPermission = _lastPermissionRequest == null || 
          now.difference(_lastPermissionRequest!).inHours >= 24;
      
      if (Platform.isAndroid) {
        // Android permissions are granted at install time for older versions
        // For Android 13+ (API 33+), we need to request permission
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // For Android 13+, check if we should request permission
          if (shouldRequestPermission) {
            return await _requestPermission();
          } else {
            // Check current permission status without requesting
            final status = await _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.areNotificationsEnabled();
            return status ?? false;
          }
        }
        return true; // For Android < 13, permissions are granted at install time
      } else if (Platform.isIOS) {
        // For iOS, check if we should request permission
        if (shouldRequestPermission) {
          return await _requestPermission();
        } else {
          // On iOS, there's no direct way to check permission status without requesting
          // We'll assume it's the same as the last time we checked
          return _isEnabled;
        }
      }
      return false;
    } catch (e, stackTrace) {
      _logger.error('Error checking notification permission', e, stackTrace);
      return false;
    }
  }

  /// Requests notification permission
  /// Returns true if granted, false otherwise
  Future<bool> _requestPermission() async {
    try {
      _logger.debug('Requesting notification permission');
      _analytics?.logPermissionRequested();
      
      // Update last permission request time
      _lastPermissionRequest = DateTime.now();
      await _savePreferences();
      
      // Request permission on iOS
      if (Platform.isIOS) {
        final settings = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return settings ?? false;
      }
      
      // Request permission on Android (API 33+)
      if (Platform.isAndroid) {
        final granted = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? false;
      }
      
      return false;
    } catch (e, stackTrace) {
      _logger.error('Error requesting notification permission', e, stackTrace);
      return false;
    }
  }

  /// Schedules a notification based on configuration
  Future<void> _scheduleNotification() async {
    try {
      // If we already have a scheduled notification in the future, don't reschedule
      final now = DateTime.now();
      if (_isNotificationScheduled && _nextScheduledTime != null && _nextScheduledTime!.isAfter(now)) {
        _logger.debug('Notification already scheduled for future time: ${AutoNotifyUtil.formatDateTime(_nextScheduledTime!)}');
        return;
      }
      
      // Cancel any existing notifications
      await _cancelNotifications();
      
      // Calculate next notification time
      final nextNotificationTime = AutoNotifyUtil.calculateNextNotificationTime(
        hourStart: _config.hourStart,
        hourEnd: _config.hourEnd,
        minuteJitter: _config.minuteJitter,
        cooldownDays: _config.cooldownDays,
        lastFireDate: _lastFireDate,
      );
      
      // Ensure the notification time is in the future and within the specified hour range
      final hour = nextNotificationTime.hour;
      if (hour < _config.hourStart || hour > _config.hourEnd) {
        _logger.error('Calculated notification time outside allowed hours: $hour');
        return;
      }
      
      if (nextNotificationTime.isBefore(now)) {
        _logger.error('Calculated notification time is in the past');
        return;
      }
      
      _nextScheduledTime = nextNotificationTime;
      _isNotificationScheduled = true;
      await _savePreferences();
      
      _logger.debug('Scheduling notification for: ${AutoNotifyUtil.formatDateTime(nextNotificationTime)}');
      
      // Get random title and body
      final content = AutoNotifyUtil.randomTitleBody(
        _config.titlePool,
        _config.bodyPool,
      );
      
      // Create Android notification details
      final androidDetails = AndroidNotificationDetails(
        _config.androidChannelId,
        'Daily Reminder',
        channelDescription: 'Daily reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: _config.iconPath,
      );
      
      // Create iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Create notification details for all platforms
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _notificationId,
        content['title'],
        content['body'],
        tz.TZDateTime.from(nextNotificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      // Track the scheduled event
      _logger.trackEvent(
        AutoNotifyLogger.eventScheduled,
        {'fire_time': AutoNotifyUtil.formatDateTime(nextNotificationTime)},
      );
      
      // Log with analytics
      _analytics?.logScheduled(nextNotificationTime);
    } catch (e, stackTrace) {
      _logger.error('Failed to schedule notification', e, stackTrace);
    }
  }

  /// Cancels all pending notifications
  Future<void> _cancelNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(_notificationId);
      _isNotificationScheduled = false;
      _nextScheduledTime = null;
      await _savePreferences();
      _logger.debug('Cancelled existing notifications');
    } catch (e, stackTrace) {
      _logger.error('Failed to cancel notifications', e, stackTrace);
    }
  }

  /// Sets whether notifications are enabled by the user
  /// Updates preferences and schedules or cancels notifications accordingly
  Future<void> setEnabled(bool enabled) async {
    try {
      // Check if SDK is initialized
      if (!_isInitialized) {
        _logger.debug('SDK not initialized, cannot set enabled state');
        return;
      }
      
      if (_isEnabled == enabled) {
        return; // No change
      }
      
      _isEnabled = enabled;
      await _savePreferences();
      
      if (_isEnabled) {
        _logger.debug('Notifications enabled by user');
        _analytics?.logEnabled();
        
        // Check permission and schedule if granted
        final permissionStatus = await _checkNotificationPermission();
        if (permissionStatus) {
          await _scheduleNotification();
        } else {
          _logger.trackEvent(AutoNotifyLogger.eventPermissionDenied);
          _analytics?.logPermissionDenied();
        }
      } else {
        _logger.debug('Notifications disabled by user');
        _analytics?.logDisabled();
        await _cancelNotifications();
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to set enabled state', e, stackTrace);
    }
  }

  /// Opens the system settings for notifications
  Future<void> openSystemSettings() async {
    try {
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(AndroidNotificationChannel(
              'auto_notify_channel',
              'Auto Notifications',
              description: 'Channel for Auto Notifications',
              importance: Importance.high,
            ));
      } else if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to open system settings', e, stackTrace);
    }
  }


}