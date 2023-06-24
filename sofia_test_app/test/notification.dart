// import 'dart:html';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class AndroidNotificationManager {
//   static const String channelId = 'default';
//   static const String channelName = 'Default';
//   static const String channelDescription = 'The default channel for notifications.';

//   static const String titleKey = 'title';
//   static const String messageKey = 'message';

//   bool channelInitialized = false;
//   int messageId = 0;
//   int pendingIntentId = 0;

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static AndroidNotificationManager? _instance;
//   static AndroidNotificationManager get instance =>
//       _instance ??= AndroidNotificationManager._();

//   AndroidNotificationManager._();

//   Future<void> initialize() async {
//     if (!channelInitialized) {
//       await createNotificationChannel();
//       channelInitialized = true;
//     }
//   }

//   Future<void> sendNotification(
//       String title, String message, DateTime? notifyTime) async {
//     // Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);

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

//       final utcTime = notifyTime.toUtc();
//       final epochDiff = DateTime(1970).difference(DateTime(1, 1, 1)).inSeconds;
//       final utcAlarmTime =
//           utcTime.subtract(Duration(seconds: epochDiff)).millisecondsSinceEpoch;

//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         pendingIntentId++,
//         title,
//         message,
//         tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, utcAlarmTime),
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: '$title|$message',
//       );
//     } else {
//       show(title, message);
//     }
//   }



//    @override
//   void receiveNotification(String title, String message) {
//     final event = NotificationEvent(title, message);
//     _notificationReceivedController.add(event);
//   }

//   Future<void> show(String title, String message) async {
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       channelId,
//       channelName,
 
//       importance: Importance.max,
//       priority: Priority.high,
//       enableLights: true,
//       enableVibration: true,
//       sound: RawResourceAndroidNotificationSound('beep'),
//       playSound: true,
//     );

//     final platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       messageId++,
//       title,
//       message,
//       platformChannelSpecifics,
//       payload: '$title|$message',
//     );
//   }

//   Future<void> createNotificationChannel() async {
//     const initializationSettingsAndroid =
//         AndroidInitializationSettings('@drawable/xamagonBlue');
//     final initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (payload) async {
//       if (payload != null) {
//         final splitData = payload.split('|');
//         final title = splitData[0];
//         final message = splitData[1];
//         receiveNotification(title, message);
//       }
//     });

//     const androidPlatformChannelSpecifics = AndroidNotificationChannel(
//       channelId,
//       channelName,
//       channelDescription,
//       importance: Importance.max,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('beep'),
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(androidPlatformChannelSpecifics);
//   }
// }
