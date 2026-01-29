import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medicine_try1/model/appointment_model.dart';
import 'package:medicine_try1/screens/docappointment_add_screen.dart';
import 'package:medicine_try1/ui_colors/green.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  @override
  _DoctorAppointmentScreenState createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  late Box<Appointment> _appointmentBox;

  @override
  void initState() {
    super.initState();
    _appointmentBox = Hive.box<Appointment>('appointmentBox');
  }

  void _addAppointment(Appointment appointment) {
    setState(() {
      _appointmentBox.add(appointment);
    });
  }

  void _deleteAppointment(int index) {
    setState(() {
      _appointmentBox.deleteAt(index);
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 226, 226),
        title: Center(
          child: Text(
            'Next Appointment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _appointmentBox.listenable(),
        builder: (context, Box<Appointment> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text("No Appointments"));
          } else {
            final appointments = box.values.toList()
              ..sort((a, b) {
                int dateComparison =
                    a.appointmentDate.compareTo(b.appointmentDate);
                if (dateComparison != 0) {
                  return dateComparison;
                } else {
                  int aTotalMinutes = a.appointmentTimeOfDay.hour * 60 +
                      a.appointmentTimeOfDay.minute;
                  int bTotalMinutes = b.appointmentTimeOfDay.hour * 60 +
                      b.appointmentTimeOfDay.minute;
                  return aTotalMinutes.compareTo(bTotalMinutes);
                }
              });

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
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
                          left: 5, top: 5, bottom: 5, right: 5),
                      child: ListTile(
                        title: Text(
                          "Doctor: ${appointment.doctorName}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Hospital: ${appointment.hospitalName}\n"
                          "Date: ${DateFormat('dd-MM-yyyy').format(appointment.appointmentDate)}\n"
                          "Time: ${formatTimeOfDay(appointment.appointmentTimeOfDay)}",
                        ),
                        leading: Icon(
                          IcoFontIcons.doctor,
                          color: docColor,
                          size: 40,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AppointmentAdd(
                                      onSave: (updatedAppointment) {
                                        setState(() {});
                                      },
                                      appointment: appointment,
                                      index: index,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Confirm"),
                                    content: Text(
                                        "Are you sure you want to delete this appointment?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text("CANCEL")),
                                      TextButton(
                                          onPressed: () {
                                            _deleteAppointment(index);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("DELETE")),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: greencolor,
        onPressed: () async {
          final newAppointment = await Navigator.push<Appointment>(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentAdd(onSave: _addAppointment),
            ),
          );

          if (newAppointment != null) {
            _addAppointment(newAppointment);
          }
        },
        label: Row(
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
