import 'package:sofia_test_app/models/NotificationEventArgs.dart';

abstract class INotificationManager {
  Stream<void> get notificationReceived;

  void initialize();
  void sendNotification(String title, String message, [DateTime? notifyTime]);
  void receiveNotification(NotificationEventArgs event);
}
