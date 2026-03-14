import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_try1/local_notifications.dart';
import 'package:medicine_try1/model/medicine_model.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleMedicineNotifications(Medicine medicine) async {
  // ✅ If user didn't add notification times
  if (medicine.notifications.trim().isEmpty) {
    debugPrint('❌ Notifications OFF for ${medicine.medicineName}');
    return;
  }

  // ✅ Parse start and end dates (you saved as ISO now)
  if (medicine.startdate.isEmpty || medicine.enddate.isEmpty) {
    debugPrint('❌ Start date / End date missing for ${medicine.medicineName}');
    return;
  }

  final DateTime startDate = DateTime.parse(medicine.startdate);
  final DateTime endDate = DateTime.parse(medicine.enddate);

  // ✅ Split notification times
  final List<String> timeStrings = medicine.notifications.split(', ');

  // Convert each time string into TimeOfDay
  final List<TimeOfDay> times = timeStrings.map((timeStr) {
    final dt = DateFormat.jm().parse(timeStr);
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }).toList();

  // ✅ Loop through each day between start and end
  DateTime currentDate = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
  );

  final DateTime lastDate = DateTime(
    endDate.year,
    endDate.month,
    endDate.day,
  );

  while (!currentDate.isAfter(lastDate)) {
    for (final time in times) {
      final DateTime scheduledDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        time.hour,
        time.minute,
      );

      // Skip past times
      if (scheduledDateTime.isBefore(DateTime.now())) {
        continue;
      }

      final tz.TZDateTime tzScheduled =
          tz.TZDateTime.from(scheduledDateTime, tz.local);

      // ✅ Unique notification id
      final int id = scheduledDateTime.millisecondsSinceEpoch ~/ 1000;

      await LocalNotificationService().scheduleNotification(
        id,
        "Medicine Reminder",
        "${medicine.medicineName} - ${medicine.dosage} ${medicine.medicineUnit}",
        tzScheduled,
      );

      debugPrint(
          '✅ Scheduled ${medicine.medicineName} at $tzScheduled (ID: $id)');
    }

    // Next day
    currentDate = currentDate.add(const Duration(days: 1));
  }
}
