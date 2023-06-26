import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sofia/models/NotificationEventArgs.dart';
import 'package:timezone/timezone.dart' as tz;

import '../interfaces/i_notification_manager.dart';

class AndroidNotificationManager implements INotificationManager {
  static const String channelId = 'com.audio_channel';
  static const String channelName = 'com.audio_channel';

  bool channelInitialized = false;
  int messageId = 0;
  int pendingIntentId = 0;
  bool _notificationsEnabled = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static AndroidNotificationManager? _instance;
  factory AndroidNotificationManager() =>
      _instance ??= AndroidNotificationManager._internal();

  AndroidNotificationManager._internal();

  Future<void> initialize() async {
    _isAndroidPermissionGranted();
    _requestPermissions();
    // if (!channelInitialized) {
    //   await createNotificationChannel();
    //   channelInitialized = true;
    // }

    // Register the method call handler to handle notification selection
    // const MethodChannel platform =
    //     MethodChannel('dexterx.dev/flutter_local_notifications_example');
    // platform.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == 'onSelectNotification') {
    //     final payload = call.arguments as String?;
    //     if (payload != null) {
    //       final splitData = payload.split('|');
    //       final title = splitData[0];
    //       final message = splitData[1];
    //       receiveNotification(title, message);
    //     }
    //   }
    // });
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      _notificationsEnabled = granted;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();

      _notificationsEnabled = granted ?? false;
    }
  }

  @override
  void sendNotification(String title, String message,
      [DateTime? notifyTime]) async {
    if (!channelInitialized) {
      await createNotificationChannel();
    }

    if (notifyTime != null) {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('beep'),
        playSound: true,
      );

      final platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        pendingIntentId++,
        title,
        message,
        tz.TZDateTime.from(notifyTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$title|$message',
      );
    } else {
      show(title, message);
    }
  }

  @override
  void receiveNotification(NotificationEventArgs event) {
    _notificationReceivedController.add(
        event); // Add a placeholder value since the stream is of type Stream<void>
  }

  @override
  void show(String title, String message) async {
    final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('beep'),
      playSound: true,
    );

    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      messageId++,
      title,
      message,
      platformChannelSpecifics,
      payload: '$title|$message',
    );
  }

  @override
  Stream<void> get notificationReceived =>
      _notificationReceivedController.stream;
  final _notificationReceivedController = StreamController<void>.broadcast();

  Future<void> createNotificationChannel() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Register the method call handler to handle notification selection
    // const MethodChannel platform =
    //     MethodChannel('dexterx.dev/flutter_local_notifications_example');
    // platform.setMethodCallHandler((MethodCall call) async {
    //   if (call.method == 'onSelectNotification') {
    //     final payload = call.arguments as String?;
    //     if (payload != null) {
    //       final splitData = payload.split('|');
    //       final title = splitData[0];
    //       final message = splitData[1];
    //       receiveNotification(title, message);
    //     }
    //   }
    // });

    const androidPlatformChannelSpecifics = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('beep'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidPlatformChannelSpecifics);
  }
}

// import 'dart:async';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sofia_test_app/interfaces/i_notification_manager.dart';

// class NotificationManagerService extends INotificationManager {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   StreamController<void> _notificationReceivedController =
//       StreamController<void>.broadcast();

//   @override
//   Stream<void> get notificationReceived =>
//       _notificationReceivedController.stream;

//   @override
//   void initialize() {
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }

//   @override
//   void sendNotification(String title, String message,
//       [DateTime? notifyTime]) async {
//     if (!channelInitialized) {
//       await createNotificationChannel();
//     }

//     if (notifyTime != null) {
//       final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         channelId,
//         channelName,
//         importance: Importance.max,
//         priority: Priority.high,
//         enableLights: true,
//         enableVibration: true,
//         sound: RawResourceAndroidNotificationSound('beep'),
//         playSound: true,
//       );

//       final platformChannelSpecifics =
//           NotificationDetails(android: androidPlatformChannelSpecifics);

//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         pendingIntentId++,
//         title,
//         message,
//         tz.TZDateTime.from(notifyTime, tz.local),
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: '$title|$message',
//       );
//     } else {
//       show(title, message);
//     }

//     _notificationReceivedController.add(null);
//   }

//   @override
//   void receiveNotification(String title, String message) {
//     // Handle the received notification
//     // You can use the provided title and message parameters to perform any necessary actions
//     // For example, displaying an alert dialog or navigating to a specific screen in your app
//   }

//   // Dispose the stream controller when the service is no longer needed
//   void dispose() {
//     _notificationReceivedController.close();
//   }
// }
