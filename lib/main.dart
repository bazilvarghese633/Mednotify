import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medicine_try1/local_notifications.dart';
import 'package:medicine_try1/model/dochistory.dart';
import 'package:medicine_try1/model/test_history.dart';
import 'package:medicine_try1/model/testappointment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medicine_try1/screens/welcome_screen.dart';
import 'package:medicine_try1/model/medicine_model.dart';
import 'package:medicine_try1/model/appointment_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(TestAppointmentAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(DoctorHistoryAdapter());
  Hive.registerAdapter(TestHistoryAdapter());

  await Hive.openBox<Medicine>('medicine-database');
  await Hive.openBox<Appointment>('appointmentBox');
  await Hive.openBox<TestAppointment>('testAppointmentsBox');
  await Hive.openBox<DoctorHistory>('dochistory');
  await Hive.openBox<TestHistory>('testhistory');
  await Hive.openBox<bool>('medicine-intake');

  tz.initializeTimeZones();

  // Initialize notification service
  await LocalNotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine App',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const WelcomeScreen(),
    );
  }
}
