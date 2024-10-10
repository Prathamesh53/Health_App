import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initializes the notification service for Android
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedules a daily notification at the specified time
  Future<void> scheduleDailyNotification(
      Time time, String title, String body) async {
    final now = DateTime.now();
    final scheduledNotificationDateTime = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
      tz.local,
    ).add(Duration(
        days: 1)); // Schedule for tomorrow if it's already passed today

    print(
        'Scheduled Notification DateTime: $scheduledNotificationDateTime'); // Log for debugging

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      title,
      body,
      scheduledNotificationDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Optional, for repeated notifications
    );
  }
}
