import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedAction receivedAction) async {
    print('Notification displayed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Action received: ${receivedAction.id}');
  }
}
