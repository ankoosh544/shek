import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:rxdart/subjects.dart';
import 'package:sofia_test_app/interfaces/i_notification_manager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationManager implements INotificationManager {
  final String channelId = 'default';
  final String channelName = 'Default';
  final String channelDescription = 'The default channel for notifications.';

  int messageId = 0;
  int pendingIntentId = 0;
  final _notificationReceivedSubject = PublishSubject<void>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationManager() {
    initialize();
  }

  @override
  void initialize() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  @override
  Future<void> sendNotification(String title, String message,
      [DateTime? notifyTime]) async {
    if (notifyTime != null) {
      await _scheduleNotification(title, message, notifyTime);
    } else {
      await showNotification(title, message);
    }
  }

  Future<void> _scheduleNotification(
      String title, String message, DateTime notifyTime) async {
    tz.initializeTimeZones();
    final location = tz.local;
    final scheduledDate = tz.TZDateTime.from(notifyTime, location);

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound('beep'));
    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        messageId++, title, message, scheduledDate, platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$title\n$message');
  }

  Future<void> showNotification(String title, String message) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('beep'),
    );
    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      messageId++,
      title,
      message,
      platformChannelSpecifics,
      payload: '$title\n$message',
    );
  }

  @override
  void receiveNotification(String title, String message) {
    // Handle received notification
  }

  @override
  Stream<void> get notificationReceived => _notificationReceivedSubject.stream;
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sofia_test_app/interfaces/i_notification_manager.dart';

// class NotificationManager implements INotificationManager {
//   final String channelId = 'default';
//   final String channelName = 'Default';
//   final String channelDescription = 'The default channel for notifications.';

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void initializeNotifications() {
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }
// }
