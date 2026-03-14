import 'package:flutter/material.dart';
import 'package:medicine_try1/local_notifications.dart';
import 'package:medicine_try1/model/appointment_model.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleDoctorAppointmentNotification(
    Appointment appointment) async {
  // Combine date and time
  final TimeOfDay time = appointment.appointmentTimeOfDay;
  final DateTime appointmentDateTime = DateTime(
    appointment.appointmentDate.year,
    appointment.appointmentDate.month,
    appointment.appointmentDate.day,
    time.hour,
    time.minute,
  );

  // Schedule 10 minutes before the appointment
  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
    appointmentDateTime.subtract(const Duration(minutes: 10)),
    tz.local,
  );

  // Use Hive key or generate unique ID
  final int notificationId =
      appointment.key ?? scheduledDate.millisecondsSinceEpoch ~/ 1000;

  // Schedule the notification
  await LocalNotificationService().scheduleNotification(
    notificationId,
    'Doctor Appointment',
    'Appointment with ${appointment.doctorName} at ${appointment.appointmentTime}',
    scheduledDate,
  );

  debugPrint(
      '✅ Scheduled doctor appointment notification at $scheduledDate (ID: $notificationId)');
}
