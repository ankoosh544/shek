import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        AndroidFlutterLocalNotificationsPlugin,
        AndroidInitializationSettings,
        AndroidNotificationDetails,
        DateTimeComponents,
        FlutterLocalNotificationsPlugin,
        Importance,
        InitializationSettings,
        NotificationAppLaunchDetails,
        NotificationDetails,
        Priority,
        RawResourceAndroidNotificationSound,
        ReceivedNotification,
        TZDateTime,
        UILocalNotificationDateInterpretation,
        tz;
import 'package:rxdart/subjects.dart';
import 'package:sofia_test_app/interfaces/i_notification_manager.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  void initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload = notificationAppLaunchDetails!.payload;
      if (payload != null) {
        final title = payload.split('\n')[0];
        final body = payload.split('\n')[1];
        receiveNotification(title, body);
      }
    }
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
