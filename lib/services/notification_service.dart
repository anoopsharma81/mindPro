import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../core/logger.dart';

/// Service for managing local notifications and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      Logger.info('NotificationService initialized');
    } catch (e, stack) {
      Logger.error('Failed to initialize notifications', e, stack);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate page based on payload
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      Logger.error('Failed to request notification permissions', e);
      return false;
    }
  }

  /// Schedule weekly reflection reminder
  Future<void> scheduleWeeklyReminder({
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required int hour, // 0-23
    required int minute, // 0-59
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Cancel existing weekly reminder
      await _notifications.cancel(1);

      // Schedule new weekly reminder
      await _notifications.zonedSchedule(
        1, // ID for weekly reminder
        'Time to Reflect',
        'Take a few minutes to capture your learning from this week',
        _nextInstanceOfWeekday(dayOfWeek, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reminder',
            'Weekly Reminders',
            channelDescription: 'Weekly reflection reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      Logger.info('Scheduled weekly reminder: Day $dayOfWeek at $hour:$minute');
    } catch (e, stack) {
      Logger.error('Failed to schedule weekly reminder', e, stack);
    }
  }

  /// Calculate next instance of a weekday/time
  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Find next occurrence of the day
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Send nudge notification (domain coverage, appraisal countdown, etc.)
  Future<void> sendNudge({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nudges',
            'Nudges',
            channelDescription: 'Helpful reminders and insights',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );

      Logger.info('Sent nudge: $title');
    } catch (e, stack) {
      Logger.error('Failed to send nudge', e, stack);
    }
  }

  /// Cancel weekly reminder
  Future<void> cancelWeeklyReminder() async {
    try {
      await _notifications.cancel(1);
      Logger.info('Cancelled weekly reminder');
    } catch (e) {
      Logger.error('Failed to cancel weekly reminder', e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      Logger.info('Cancelled all notifications');
    } catch (e) {
      Logger.error('Failed to cancel all notifications', e);
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}

/// Riverpod provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

