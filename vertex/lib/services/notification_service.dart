import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    // Request runtime notification permission on Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Registers an OS-level wake alarm 10 minutes before contest start time
  Future<bool> scheduleContestReminder({
    required int id,
    required String title,
    required String platform,
    required DateTime startTime,
  }) async {
    final scheduledDate = startTime.subtract(const Duration(minutes: 10));

    // Refuse scheduling if the 10-minute window has already elapsed
    if (scheduledDate.isBefore(DateTime.now())) {
      return false;
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'contest_reminders_channel',
      'Contest Reminders',
      channelDescription: 'Alerts triggered 10 minutes prior to scheduled contests',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "Contest Alert: $platform",
      "'$title' starts in 10 minutes! Prepare your workspace.",
      tzDateTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    return true;
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<List<int>> getPendingNotificationIds() async {
    final pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pending.map((e) => e.id).toList();
  }
}