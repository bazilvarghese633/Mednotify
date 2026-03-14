import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_try1/local_notifications.dart'
    show LocalNotificationService;

import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    // Request notification permission (Android 13+)
    final status = await Permission.notification.request();
    debugPrint('Notification permission status: $status');

    // Check if exact alarms can be scheduled
    final androidImpl = LocalNotificationService()
        .flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final canSchedule = await androidImpl?.canScheduleExactNotifications();
    debugPrint('Can schedule exact alarms: $canSchedule');

    if (canSchedule == false) {
      await androidImpl?.requestExactAlarmsPermission();
      debugPrint('Requested exact alarms permission');
    }
  }
}
