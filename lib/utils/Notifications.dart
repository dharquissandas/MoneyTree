import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

notificationInit(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    InitializationSettings initializationSettings) async {
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
}

tz.TZDateTime _nextInstance(int time) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, time - 1, 33);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

scheduleRecorruingNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final time = 17;
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Money Tree Transactions',
      "Don't forget to add todays transactions.",
      _nextInstance(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily notification channel id',
            'daily notification channel name',
            'daily notification description'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

turnReoccuringNotificationOff(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancel(0);
}
