import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:medicine_try1/model/testappointment.dart';
import 'package:medicine_try1/screens/add_test.dart';
import 'package:medicine_try1/screens/viewtest.dart';
import '../ui_colors/green.dart';

class TestAppointmentScreen extends StatefulWidget {
  const TestAppointmentScreen({super.key});

  @override
  State<TestAppointmentScreen> createState() => _TestAppointmentScreenState();
}

class _TestAppointmentScreenState extends State<TestAppointmentScreen> {
  late Box<TestAppointment> _appointmentsBox;

  // ✅ Store key + appointment together
  late ValueNotifier<List<MapEntry<dynamic, TestAppointment>>>
      _appointmentsNotifier;

  @override
  void initState() {
    super.initState();

    _appointmentsBox = Hive.box<TestAppointment>('testAppointmentsBox');
    _appointmentsNotifier = ValueNotifier([]);

    _loadAppointments();

    _appointmentsBox.watch().listen((event) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _appointmentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final entries = _appointmentsBox.toMap().entries.toList();

    // ✅ Sort by date then time
    entries.sort((a, b) {
      int dateComparison = a.value.date.compareTo(b.value.date);
      if (dateComparison != 0) return dateComparison;

      return _timeOfDayToMinutes(a.value.time)
          .compareTo(_timeOfDayToMinutes(b.value.time));
    });

    _appointmentsNotifier.value = entries;
  }

  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  void _addAppointment(TestAppointment testAppointment) async {
    await _appointmentsBox.add(testAppointment);
    _loadAppointments();
  }

  void _deleteAppointment(dynamic key) async {
    await _appointmentsBox.delete(key);
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 226, 226),
        title: const Center(
          child: Text(
            'Test Appointments       ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<MapEntry<dynamic, TestAppointment>>>(
        valueListenable: _appointmentsNotifier,
        builder: (context, entries, _) {
          if (entries.isEmpty) {
            return const Center(child: Text("No Test Appointments"));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final key = entry.key;
              final testAppointment = entry.value;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      width: 2,
                      color: greencolor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 5, top: 10, bottom: 10, right: 5),
                    child: ListTile(
                      title: Text(
                        "Test: ${testAppointment.testName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Date: ${DateFormat('dd-MM-yyyy').format(testAppointment.date)}\n'
                        'Time: ${testAppointment.time.format(context)}',
                      ),
                      leading: const Icon(
                        IcoFontIcons.laboratory,
                        color: Color.fromARGB(255, 244, 54, 203),
                        size: 40,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTestAppointmentScreen(
                              testAppointment: testAppointment,
                              appointmentKey: key, // ✅ pass key
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAppointment(key),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: greencolor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestAppointmentAdd(
                onSave: _addAppointment,
                appointmentKey: null,
              ),
            ),
          );
        },
        label: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text(
              "Add",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
