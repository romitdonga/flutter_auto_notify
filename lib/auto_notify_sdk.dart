/// Flutter Auto Notify SDK
/// A reusable Flutter SDK to send one friendly, non-intrusive local notification per day
/// Works for both Android & iOS without Firebase dependencies
library;

export 'auto_notify_config.dart';
export 'auto_notify_manager.dart';
export 'notify_analytics.dart';

import 'auto_notify_manager.dart';

/// Convenience access to the singleton manager instance
AutoNotifyManager get autoNotify => AutoNotifyManager();
