import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

class NotificationService {
  NotificationService._private();
  static final NotificationService instance = NotificationService._private();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  Future<void> init() async {
    // Initialize time zones
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (e) {
      debugPrint("Warning: Could not set local timezone. Using UTC. $e");
      tz.setLocalLocation(tz.UTC);
    }

    // --- Android/iOS Initialization Settings ---
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iOSInit);

    // --- Android Runtime Permission Checks ---
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // 1. Request POST_NOTIFICATIONS permission (for Android 13+)
      await androidImplementation?.requestNotificationsPermission();

      // 2. Check and request EXACT ALARM permission (USE_EXACT_ALARM)
      if (await Permission.scheduleExactAlarm.isDenied) {
        debugPrint('Exact Alarm permission denied. Attempting to request.');

        // Request permission. If denied, open settings for manual check.
        if (await Permission.scheduleExactAlarm.request().isDenied) {
          await _openExactAlarmSettings();
        }
      }
    }

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null) {
          debugPrint('Notification tapped with payload: $payload');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }
  Future<void> _openExactAlarmSettings() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      package: 'com.example.task_management', // Must match your app ID
    );
    try {
      await intent.launch();
      debugPrint('Opened Exact Alarm settings screen.');
    } catch (e) {
      debugPrint('Could not open Exact Alarm settings screen: $e');
    }
  }


  /// Background notification tap handler
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    debugPrint('Notification tapped in background: ${response.payload}');
  }
  NotificationDetails _getNotificationDetails(String soundAsset) {
    final soundName = path.basenameWithoutExtension(soundAsset);
    final iOSSoundName = soundAsset;

    final androidDetails = AndroidNotificationDetails(
      'task_channel_with_sound',
      'Tasks Reminders',
      channelDescription: 'Task reminders with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundName),
      fullScreenIntent: true,
    );

    final iOSDetails = DarwinNotificationDetails(
      sound: iOSSoundName,
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iOSDetails);
  }

  /// Schedule a single-time notification
  Future<int> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String soundAsset = 'bell.mp3',
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzDate.isBefore(tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)))) {
      if (kDebugMode) {
        debugPrint('Cannot schedule notification $id: Date is in the past or too soon.');
      }
      return -1;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _getNotificationDetails(soundAsset),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: id.toString(),
    );

    return id;
  }
  Future<int> scheduleAdvancedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundAsset,
    String repeatRule = 'None',
    List<int>? customDays,
  }) async {
    // 1. Check for single, non-repeating task
    if (repeatRule == 'None' || repeatRule.isEmpty) {
      return await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        soundAsset: soundAsset,
      );
    }

    // 2. Handle Simple Repeats (Daily/Monthly/Weekly)
    DateTimeComponents? matchComponent;

    switch (repeatRule) {
      case 'Daily':
        matchComponent = DateTimeComponents.time; // Match time every day
        break;
      case 'Weekly':
        matchComponent = DateTimeComponents.dayOfWeekAndTime; // Match Day of Week and Time
        break;
      case 'Monthly':
        matchComponent = DateTimeComponents.dayOfMonthAndTime; // Match Day of Month and Time
        break;
      case 'CustomDay':
      // Custom Day needs individual notification per selected day
        return await _scheduleCustomDayNotifications(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          soundAsset: soundAsset,
          customDays: customDays,
        );
      default:
      // Default to a single schedule if rule is unrecognized but not 'None'
        return await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          soundAsset: soundAsset,
        );
    }

    // Handle Daily/Weekly/Monthly repetition
    final tzDate = _nextInstanceOfDateAndTime(scheduledTime);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _getNotificationDetails(soundAsset),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponent,
      payload: id.toString(),
    );
    return id;
  }

  // Helper for Custom Day logic (schedules separate notifications for each day)
  Future<int> _scheduleCustomDayNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundAsset,
    required List<int>? customDays,
  }) async {
    if (customDays == null || customDays.isEmpty) return -1;
    final baseId = id * 100;
    for (int i = 1; i <= 7; i++) {
      await cancel(baseId + i);
    }

    for (int day in customDays) {
      final dayId = baseId + day;
      tz.TZDateTime scheduledDate = _nextInstanceOfTimeOnDay(scheduledTime, day);

      await _plugin.zonedSchedule(
        dayId, // Use unique ID for each day
        '$title (Every ${_dayOfWeekName(day)})',
        body,
        scheduledDate,
        _getNotificationDetails(soundAsset),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Match Day of Week and Time
        payload: id.toString(),
      );
    }
    // Return the base task ID
    return id;
  }

  // Helper to get the next date instance for repeating schedules (Daily/Weekly/Monthly)
  tz.TZDateTime _nextInstanceOfDateAndTime(DateTime scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
      0,
    );

    // If the scheduled time is already past today, move it to tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Helper to find the next occurrence of a specific day and time (used for Custom Days)
  tz.TZDateTime _nextInstanceOfTimeOnDay(DateTime scheduledTime, int dayOfWeek) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Calculate difference in days: dayOfWeek is 1 (Mon) to 7 (Sun), now.weekday is 1 to 7
    int diff = dayOfWeek - now.weekday;

    // If the day is today or in the past, move to next week
    if (diff <= 0) {
      diff += 7;
    }

    tz.TZDateTime nextDay = now.add(Duration(days: diff));

    // Set the specific time
    tz.TZDateTime finalSchedule = tz.TZDateTime(
      tz.local,
      nextDay.year,
      nextDay.month,
      nextDay.day,
      scheduledTime.hour,
      scheduledTime.minute,
      0,
    );

    // If the calculated time is still in the past (e.g., calculation ran over midnight), reschedule for next week
    if (finalSchedule.isBefore(now)) {
      finalSchedule = finalSchedule.add(const Duration(days: 7));
    }

    return finalSchedule;
  }

  // Helper to get the day name for custom day notification titles
  String _dayOfWeekName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  // Helper function to calculate the next occurrence time for a simple daily/weekly repeating task (Original function, kept for compatibility if needed)
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule a repeating notification (Daily/Weekly) - NOTE: Replaced by scheduleAdvancedNotification, but kept here if used elsewhere.
  Future<int> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
    required RepeatInterval interval,
    String soundAsset = 'bell.mp3',
  }) async {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(scheduledTime);

    // Using zonedSchedule for fixed time repetition
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _getNotificationDetails(soundAsset),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // Match component for daily/weekly repeat
      matchDateTimeComponents: interval == RepeatInterval.daily
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
      payload: id.toString(),
    );

    return id;
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
  Future<void> cancelTaskNotifications(int taskId) async {
    await cancel(taskId); // Cancel the main single notification ID

    // Also cancel all potential custom day repeat IDs (10001 to 10007 if taskId=100)
    final baseId = taskId * 100;
    for (int i = 1; i <= 7; i++) {
      await cancel(baseId + i);
    }

    debugPrint('Cancelled all notifications for Task ID: $taskId');
  }
}