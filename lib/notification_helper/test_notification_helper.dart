import 'package:medicine_try1/model/testappointment.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:medicine_try1/local_notifications.dart';

Future<void> scheduleTestAppointmentNotification(
    TestAppointment appointment) async {
  final DateTime scheduledDateTime = DateTime(
    appointment.date.year,
    appointment.date.month,
    appointment.date.day,
    appointment.time.hour,
    appointment.time.minute,
  ).subtract(const Duration(minutes: 10));

  final tz.TZDateTime tzScheduledDate =
      tz.TZDateTime.from(scheduledDateTime, tz.local);

  final int id = scheduledDateTime.millisecondsSinceEpoch ~/ 1000;

  await LocalNotificationService().scheduleNotification(
    id,
    "Test Appointment",
    "${appointment.testName} at ${appointment.laboratoryName}",
    tzScheduledDate,
  );

  debugPrint(
      '✅ Scheduled test appointment notification at $tzScheduledDate (ID: $id)');
}
