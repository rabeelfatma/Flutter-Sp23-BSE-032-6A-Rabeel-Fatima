// notification_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

class NotificationService {
  NotificationService._private();
  static final NotificationService instance = NotificationService._private();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  Future<void> init() async {
    // Ensure timezones are initialized
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (e) {
      debugPrint("Warning: Could not set local timezone. Using UTC. $e");
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    if (!kIsWeb && Platform.isAndroid) {
      // 1. Request runtime notification permission (Android 13+/API 33)
      final androidImplementation =
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // 2. Request exact alarm permission (Android 12+/API 31+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        debugPrint('Exact Alarm permission denied. Trying to request.');
        final result = await Permission.scheduleExactAlarm.request();
        if (result.isDenied) {
          // Open exact alarm settings if the request failed (user must toggle manually)
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
    // Opens system settings page where user can grant exact alarms for your app
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    try {
      await intent.launch();
      debugPrint('Opened Exact Alarm settings screen.');
    } catch (e) {
      debugPrint('Could not open Exact Alarm settings: $e');
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    debugPrint('Notification tapped in background: ${response.payload}');
    // You can handle background taps here if needed (open specific screen, etc.)
  }

  NotificationDetails _getNotificationDetails(String soundAsset) {
    final soundName = path.basenameWithoutExtension(soundAsset);

    final androidDetails = AndroidNotificationDetails(
      'task_channel_with_sound',
      'Tasks Reminders',
      channelDescription: 'Task reminders with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundName),
      fullScreenIntent: true, // Used for high-priority alerts
    );

    final iosDetails = DarwinNotificationDetails(
      sound: soundAsset, // e.g. 'bell.mp3' (iOS bundles must be added to Runner)
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Schedule a one-time notification
  Future<int> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String soundAsset = 'bell.mp3',
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzDate.isBefore(tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)))) {
      debugPrint('Cannot schedule notification $id: Date is in the past.');
      return -1;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _getNotificationDetails(soundAsset),
      // Uses the compliant, exact scheduling mode for API 31+
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );

    return id;
  }

  /// Schedule notifications with repeat rules
  Future<int> scheduleAdvancedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundAsset,
    String repeatRule = 'None',
    List<int>? customDays,
  }) async {
    if (repeatRule == 'None' || repeatRule.isEmpty) {
      return await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        soundAsset: soundAsset,
      );
    }

    DateTimeComponents? matchComponent;

    switch (repeatRule) {
      case 'Daily':
        matchComponent = DateTimeComponents.time;
        break;
      case 'Weekly':
        matchComponent = DateTimeComponents.dayOfWeekAndTime;
        break;
      case 'Monthly':
        matchComponent = DateTimeComponents.dayOfMonthAndTime;
        break;
      case 'CustomDay':
        return await _scheduleCustomDayNotifications(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          soundAsset: soundAsset,
          customDays: customDays,
        );
      default:
        return await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          soundAsset: soundAsset,
        );
    }

    final tzDate = _nextInstanceOfDateAndTime(scheduledTime);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      _getNotificationDetails(soundAsset),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponent,
      payload: id.toString(),
    );

    return id;
  }

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

    // Clear old schedules
    for (int i = 1; i <= 7; i++) {
      await cancel(baseId + i);
    }

    for (int day in customDays) {
      final dayId = baseId + day;
      tz.TZDateTime scheduledDate = _nextInstanceOfTimeOnDay(scheduledTime, day);

      await _plugin.zonedSchedule(
        dayId,
        '$title (Every ${_dayOfWeekName(day)})',
        body,
        scheduledDate,
        _getNotificationDetails(soundAsset),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: id.toString(),
      );
    }

    return id;
  }

  tz.TZDateTime _nextInstanceOfDateAndTime(DateTime scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTimeOnDay(DateTime scheduledTime, int dayOfWeek) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int diff = dayOfWeek - now.weekday;
    if (diff <= 0) diff += 7;

    tz.TZDateTime nextDay = now.add(Duration(days: diff));
    return tz.TZDateTime(
      tz.local,
      nextDay.year,
      nextDay.month,
      nextDay.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
  }

  String _dayOfWeekName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelTaskNotifications(int taskId) async {
    await cancel(taskId);
    final baseId = taskId * 100;
    for (int i = 1; i <= 7; i++) {
      await cancel(baseId + i);
    }
    debugPrint('Cancelled all notifications for Task ID: $taskId');
  }
}

// Global helper
Future<int> scheduleAdvancedNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  required String soundAsset,
  String repeatRule = 'None',
  List<int>? customDays,
}) async {
  return await NotificationService.instance.scheduleAdvancedNotification(
    id: id,
    title: title,
    body: body,
    scheduledTime: scheduledTime,
    soundAsset: soundAsset,
    repeatRule: repeatRule,
    customDays: customDays,
  );
}
